import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unyo/core/i18n/app_locales.dart';
import 'package:unyo/core/i18n/underscore_asset_loader.dart';

/// WP #124 regression: at a non-English locale the Settings screen's four
/// `DropdownMenu`s render as red "No MaterialLocalizations found" ErrorWidgets
/// while `context.tr` copy renders fine — so the user cannot switch back.
/// Evidence: `research/unyo-124-i18n-proof/shots/09-es_ES-settings-immediate.png`,
/// `logs/wave3-runtime.log`.
///
/// `test/core/i18n/material_localizations_probe_test.dart` proves the delegate
/// list is fine under a plain `MaterialApp`. The app runs `MaterialApp.router`
/// inside `ScreenUtilInit` inside `EasyLocalization` — this test reproduces
/// that shape.

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
        localizationsDelegates: context.localizationDelegates,
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
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  testWidgets('EasyLocalization > ScreenUtilInit > MaterialApp.router keeps MaterialLocalizations at es_ES', (WidgetTester tester) async {
    BuildContext? probe;
    await tester.pumpWidget(
      _appLike(
        locale: const Locale('es', 'ES'),
        home: Builder(builder: (BuildContext c) {
          probe = c;
          return Scaffold(
            body: Column(
              children: <Widget>[
                DropdownMenu<String>(
                  dropdownMenuEntries: const <DropdownMenuEntry<String>>[
                    DropdownMenuEntry<String>(value: 'a', label: 'A'),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
    await tester.pumpAndSettle();

    final MaterialLocalizations? material =
        probe == null ? null : Localizations.of<MaterialLocalizations>(probe!, MaterialLocalizations);
    expect(probe, isNotNull, reason: 'the router home never built');
    expect(material, isNotNull,
        reason: 'MaterialLocalizations missing under MaterialApp.router at es_ES');

    final Finder menu = find.byWidgetPredicate((Widget w) => w is DropdownMenu);
    expect(menu, findsOneWidget);
    await tester.tap(menu);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('A'), findsWidgets);
  });

}
