// External dependencies
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
// NOTE: deliberately NOT importing `package:flutter/material.dart`.
// `material_ui` ships its own `MaterialApp` and its own `MaterialLocalizations`,
// and that is the pair this bug lived in. Importing Flutter's material here
// would silently bind both names to the wrong classes and the test would pass
// against an app the product does not use — which is exactly how this regression
// survived the first round of probes.
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/core/i18n/app_locales.dart';
import 'package:unyo/core/i18n/app_localizations.dart';
import 'package:unyo/core/i18n/underscore_asset_loader.dart';

/// WP #124 / work package 126.
///
/// Regression: at every non-English locale, every `material_ui` `DropdownMenu`
/// painted a red `No MaterialLocalizations found` ErrorWidget — including the
/// language picker itself, so the user could not switch back. English was
/// unaffected because `material_ui`'s `DefaultMaterialLocalizations` is
/// `en`-only. See `research/unyo-124-i18n-proof/DIAGNOSIS.md`.

/// `MaterialLocalizations`-typed delegate covering [locale], if any.
bool _hasMaterialLocalizationsFor(
  List<LocalizationsDelegate<dynamic>> delegates,
  Locale locale,
) {
  return delegates.any((LocalizationsDelegate<dynamic> d) =>
      d.type == MaterialLocalizations && d.isSupported(locale));
}

class _StubRouterDelegate extends RouterDelegate<Object>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Object> {
  _StubRouterDelegate(this.home);

  final Widget home;

  @override
  GlobalKey<NavigatorState>? get navigatorKey => GlobalKey<NavigatorState>();

  @override
  Future<void> setNewRoutePath(Object configuration) async {}

  @override
  Widget build(BuildContext context) => Navigator(
        pages: <Page<Object?>>[MaterialPage<Object?>(child: home)],
        onDidRemovePage: (Page<Object?> page) {},
      );
}

class _StubRouteInformationParser extends RouteInformationParser<Object> {
  const _StubRouteInformationParser();

  @override
  Future<Object> parseRouteInformation(RouteInformation routeInformation) async => Object();

  @override
  RouteInformation? restoreRouteInformation(Object configuration) => null;
}

/// The app's real shape: `EasyLocalization` > `ScreenUtilInit` >
/// `material_ui`'s `MaterialApp.router`, at [locale], wired through
/// [appLocalizationDelegates] exactly as `main.dart` wires it.
Widget _appLike({required Locale locale, required Widget home}) {
  return EasyLocalization(
    key: ValueKey<String>(locale.toString()),
    supportedLocales: kSupportedLocales,
    path: 'assets/i18n',
    startLocale: locale,
    fallbackLocale: enGb.locale,
    saveLocale: false,
    useOnlyLangCode: false,
    assetLoader: const UnderscoreAssetLoader(),
    child: ScreenUtilInit(
      designSize: const Size(1280, 720),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? child) => MaterialApp.router(
        localizationsDelegates: appLocalizationDelegates(
          EasyLocalization.of(context)!.delegates,
        ),
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        debugShowCheckedModeBanner: false,
        routerConfig: RouterConfig<Object>(
          routeInformationProvider: PlatformRouteInformationProvider(
            initialRouteInformation: RouteInformation(uri: Uri.parse('/')),
          ),
          routeInformationParser: const _StubRouteInformationParser(),
          routerDelegate: _StubRouterDelegate(home),
        ),
      ),
    ),
  );
}

void main() {
  group('appLocalizationDelegates', () {
    // A pure test on purpose. `appLocalizationDelegates` takes the delegate list
    // rather than a `BuildContext` so this needs no widget at all: pumping a
    // second `EasyLocalization` into one test process makes the later one hang
    // on an already-cached locale load and never build its home.
    test('supplies a MaterialLocalizations delegate for every shipped locale', () {
      final List<LocalizationsDelegate<dynamic>> delegates =
          appLocalizationDelegates(const <LocalizationsDelegate<dynamic>>[]);

      final List<String> unsupported = kAppLocales
          .where((AppLocale l) => !_hasMaterialLocalizationsFor(delegates, l.locale))
          .map((AppLocale l) => l.code)
          .toList();

      expect(unsupported, isEmpty,
          reason: 'MaterialLocalizations has no delegate for these locales; '
              'every material_ui DropdownMenu/TabBar/Tooltip would red-screen '
              'with "No MaterialLocalizations found"');
    });

    test('material_ui delegates shadow any later delegate of the same type', () {
      // `Localizations` keeps the FIRST delegate per `type`. `material_ui`'s
      // `MaterialApp` appends its `en`-only `DefaultMaterialLocalizations` —
      // same `MaterialLocalizations` type — so if a non-supporting delegate ever
      // lands ahead of `material_ui`'s global one, every non-English
      // `DropdownMenu` red-screens again.
      final List<LocalizationsDelegate<dynamic>> delegates = appLocalizationDelegates(
        <LocalizationsDelegate<dynamic>>[DefaultMaterialLocalizations.delegate],
      );
      final LocalizationsDelegate<dynamic> first = delegates.firstWhere(
        (LocalizationsDelegate<dynamic> d) => d.type == MaterialLocalizations,
      );
      expect(first.isSupported(const Locale('es', 'ES')), isTrue,
          reason: 'a non-supporting MaterialLocalizations delegate must never '
              'shadow material_ui\'s GlobalMaterialLocalizations');
    });
  });

  testWidgets('a DropdownMenu opens at es_ES under material_ui MaterialApp', (WidgetTester tester) async {
    BuildContext? probe;
    await tester.pumpWidget(
      _appLike(
        locale: const Locale('es', 'ES'),
        home: Builder(builder: (BuildContext c) {
          probe = c;
          return Scaffold(
            body: Column(
              children: <Widget>[
                const Text('Idioma'),
                DropdownMenu<String>(
                  dropdownMenuEntries: const <DropdownMenuEntry<String>>[
                    DropdownMenuEntry<String>(value: 'es_ES', label: 'Español (España)'),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
    await tester.pumpAndSettle();

    expect(probe, isNotNull, reason: 'the home never built');
    expect(MaterialLocalizations.of(probe!), isNotNull);

    final Finder menu = find.byWidgetPredicate((Widget w) => w is DropdownMenu);
    expect(menu, findsOneWidget);
    await tester.tap(menu);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Español (España)'), findsWidgets);
  });
}
