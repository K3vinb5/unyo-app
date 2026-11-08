import 'dart:io';
import 'package:audio_service_mpris/audio_service_mpris.dart';
import 'package:material_ui/material_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unyo/data/adapters/type_adapters/color_adapter.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hive_ce/hive.dart';
import 'package:logger/logger.dart';

//Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/i18n/app_locales.dart';
import 'package:unyo/core/i18n/app_localizations.dart';
import 'package:unyo/core/i18n/underscore_asset_loader.dart';
import 'package:unyo/core/router/app_router.dart';
import 'package:unyo/core/theme/theme_service.dart';
import 'package:unyo/hive_registrar.g.dart';
import 'package:unyo/data/adapters/type_adapters/settings_model_migration_adapter.dart';
import 'package:unyo/data/migrations/user_box_schema_migration.dart';
import 'package:unyo/domain/entities/user/settings.dart';

final _appRouter = AppRouter();

void main() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await windowManager.ensureInitialized();
  // audio_service ships no Linux platform implementation: this D-Bus MPRIS
  // backend is what playerctl and the KDE media widget talk to. Registered
  // before anything can call AudioService.init (first video screen open).
  if (Platform.isLinux) {
    AudioServiceMpris.registerWith();
  }
  // Inject dependencies before running the app
  setupLocator();
  // Initialize Hive and register adapters
  await sl.isReady<Directory>(instanceName: config.applicationSupportDirectory);
  Hive
    ..init(sl<Directory>(instanceName: config.applicationSupportDirectory).path)
    ..registerAdapter(ColorAdapter())
    ..registerAdapters()
    // The generated settings adapter cannot reconcile pre-split rows on read
    // nor mirror the legacy `service` field on write. Box data is binary, so
    // this adapter — not SettingsModel.fromJson — is what migrates real installs.
    ..registerAdapter<SettingsModel>(SettingsModelMigrationAdapter(), override: true);
  // Drop user frames written by another persisted-schema generation before the
  // repositories open their boxes: Hive deserialises every frame, stale ones
  // included, and one unreadable frame aborts the whole user list (WP #122).
  await UserBoxSchemaMigration(sl<Logger>()).runOrReport();
  // Inject the remaining dependencies that rely on Hive and are not Lazy
  setupLocatorAfterHiveInit();
  // Setup Window Manager options
  WindowOptions windowOptions = const WindowOptions(
    minimumSize: Size(1200, 675),
    center: false,
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.normal,
    title: "Unyo",
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    windowManager.setPreventClose(true);
  });
  // Run Flutter app with localization and screen utilities
  //
  // Locale resolution (WP #124): no `startLocale` and `saveLocale: false`, so
  // `easy_localization` picks the *system* locale at boot and falls back to
  // `en_GB` — that is what renders the pre-login "Who's Watching?" screen.
  // Once a user is selected the app calls `context.setLocale` from
  // `Settings.language` and persists changes there; easy_localization must not
  // keep a second, app-level copy of the choice.
  runApp(
    EasyLocalization(
      supportedLocales: kSupportedLocales,
      path: 'assets/i18n',
      fallbackLocale: enGb.locale,
      useOnlyLangCode: false,
      saveLocale: false,
      // A locale bundle with a missing or empty key must render the English
      // master, not the raw key name. The Wave 3 parity test is what guarantees
      // complete bundles at build time; this is the behaviour for anything that
      // slips through at runtime.
      useFallbackTranslations: true,
      useFallbackTranslationsForEmptyResources: true,
      assetLoader: const UnderscoreAssetLoader(),
      child: ScreenUtilInit(
        designSize: const Size(1280, 720),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return const MyApp();
        },
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // All three MaterialApps share one localization config — see
    // `core/i18n/app_localizations.dart` for why the delegate list is not just
    // `context.localizationDelegates` (short version: `material_ui` has its own
    // `MaterialLocalizations`, and without its delegates every DropdownMenu
    // red-screens at non-English locales).
    return StreamBuilder<ThemeData>(
      stream: sl<ThemeService>().theme$,
      builder: (BuildContext context, AsyncSnapshot<ThemeData> snapshot) {
        // Handle loading and error states
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            localizationsDelegates: appLocalizationDelegates(context.localizationDelegates),
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: const Scaffold(body: Center(child: CircularProgressIndicator())),
            debugShowCheckedModeBanner: false,
          );
        }

        if (snapshot.hasError) {
          sl<Logger>().e("Theme stream error: ${snapshot.error}");
          return MaterialApp(
            localizationsDelegates: appLocalizationDelegates(context.localizationDelegates),
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: ThemeData.dark(),
            home: const Scaffold(body: Center(child: Text("Error loading theme"))),
            debugShowCheckedModeBanner: false,
          );
        }
        return MaterialApp.router(
          localizationsDelegates: appLocalizationDelegates(context.localizationDelegates),
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          debugShowCheckedModeBanner: false,
          title: "Unyo",
          theme: snapshot.requireData,
          // Use fallback theme
          routerConfig: _appRouter.config(),
        );
      },
    );
  }
}
