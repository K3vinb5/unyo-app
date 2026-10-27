import 'dart:async';
import 'dart:io';
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
import 'package:unyo/core/router/app_router.dart';
import 'package:unyo/core/theme/theme_service.dart';
import 'package:unyo/hive_registrar.g.dart';
import 'package:unyo/domain/services/media_id_resolver.dart';

final _appRouter = AppRouter();

void main() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await windowManager.ensureInitialized();
  // Inject dependencies before running the app
  setupLocator();
  // Initialize Hive and register adapters
  await sl.isReady<Directory>(instanceName: config.applicationSupportDirectory);
  Hive
    ..init(sl<Directory>(instanceName: config.applicationSupportDirectory).path)
    ..registerAdapter(ColorAdapter())
    ..registerAdapters();
  // Inject the remaining dependencies that rely on Hive and are not Lazy
  setupLocatorAfterHiveInit();
  // Unresolved MAL mappings are remembered for one session only; drop last
  // session's misses so the resolution chain retries them.
  unawaited(sl<MediaIdResolver>().purgeUnresolved());
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
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'GB')],
      path: 'assets/i18n',
      fallbackLocale: const Locale('en', 'GB'),
      useOnlyLangCode: true,
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
    return StreamBuilder<ThemeData>(
      stream: sl<ThemeService>().theme$,
      builder: (BuildContext context, AsyncSnapshot<ThemeData> snapshot) {
        // Handle loading and error states
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
            debugShowCheckedModeBanner: false,
          );
        }

        if (snapshot.hasError) {
          sl<Logger>().e("Theme stream error: ${snapshot.error}");
          return MaterialApp(
            theme: ThemeData.dark(),
            home: const Scaffold(body: Center(child: Text("Error loading theme"))),
            debugShowCheckedModeBanner: false,
          );
        }
        return MaterialApp.router(
          localizationsDelegates: context.localizationDelegates,
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
