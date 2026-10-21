import 'package:auto_route/auto_route.dart';
import 'package:material_ui/material_ui.dart';
import 'package:unyo/core/router/app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  // @override
  // RouteType get defaultRouteType => RouteType.custom();

  @override
  List<AutoRoute> get routes => [
    CustomRoute(
      page: RootRoute.page,
      path: '/',
      transitionsBuilder: TransitionsBuilders.noTransition,
      duration: Duration.zero,
      reverseDuration: Duration.zero,
      children: [
        CustomRoute(
          page: LoginRoute.page,
          path: 'login',
          initial: true,
          transitionsBuilder: TransitionsBuilders.noTransition,
          duration: Duration.zero,
          reverseDuration: Duration.zero,
        ),
        CustomRoute(
          page: TabsRoute.page,
          path: 'tabs',
          transitionsBuilder: TransitionsBuilders.noTransition,
          duration: Duration.zero,
          reverseDuration: Duration.zero,
          children: [
            CustomRoute(
              page: HomeRoute.page,
              path: 'home',
              transitionsBuilder: TransitionsBuilders.noTransition,
              duration: Duration.zero,
              reverseDuration: Duration.zero,
            ),
            CustomRoute(
              page: AnimeRoute.page,
              path: 'anime',
              transitionsBuilder: TransitionsBuilders.noTransition,
              duration: Duration.zero,
              reverseDuration: Duration.zero,
            ),
            CustomRoute(
              page: MangaRoute.page,
              path: 'manga',
              transitionsBuilder: TransitionsBuilders.noTransition,
              duration: Duration.zero,
              reverseDuration: Duration.zero,
            ),
            CustomRoute(
              page: ExtensionsRoute.page,
              path: 'extensions',
              transitionsBuilder: TransitionsBuilders.noTransition,
              duration: Duration.zero,
              reverseDuration: Duration.zero,
            ),
            CustomRoute(
              page: SettingsRoute.page,
              path: 'settings',
              transitionsBuilder: TransitionsBuilders.noTransition,
              duration: Duration.zero,
              reverseDuration: Duration.zero,
            ),
          ],
        ),
        CustomRoute(
          page: MediaListRoute.page,
          path: 'userlist',
          transitionsBuilder:
              (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) => SlideTransition(
                position: Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(animation),
                child: FadeTransition(opacity: CurvedAnimation(parent: animation, curve: Curves.easeInQuad), child: child),
              ),
          duration: const Duration(milliseconds: 250),
          reverseDuration: const Duration(milliseconds: 250),
        ),
        CustomRoute(
          page: CalendarRoute.page,
          path: 'calendar',
          transitionsBuilder: TransitionsBuilders.slideRightWithFade,
          duration: const Duration(milliseconds: 250),
          reverseDuration: const Duration(milliseconds: 250),
        ),
        CustomRoute(
          page: AnimeAdvancedSearchRoute.page,
          path: 'animesearch',
          transitionsBuilder: TransitionsBuilders.slideLeftWithFade,
          duration: const Duration(milliseconds: 250),
          reverseDuration: const Duration(milliseconds: 250),
        ),
        CustomRoute(
          page: MangaAdvancedSearchRoute.page,
          path: 'mangasearch',
          transitionsBuilder: TransitionsBuilders.slideLeftWithFade,
          duration: const Duration(milliseconds: 250),
          reverseDuration: const Duration(milliseconds: 250),
        ),
        CustomRoute(
          page: AnimeDetailsRoute.page,
          path: 'animedetails',
          transitionsBuilder:
              (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) => ScaleTransition(
                scale: CurvedAnimation(parent: animation, curve: Curves.decelerate),
                child: FadeTransition(opacity: CurvedAnimation(parent: animation, curve: Curves.easeInCubic), child: child),
              ),
          duration: const Duration(milliseconds: 250),
          reverseDuration: const Duration(milliseconds: 250),
        ),
        CustomRoute(
          page: MangaDetailsRoute.page,
          path: 'mangadetails',
          transitionsBuilder:
              (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) => ScaleTransition(
            scale: CurvedAnimation(parent: animation, curve: Curves.decelerate),
            child: FadeTransition(opacity: CurvedAnimation(parent: animation, curve: Curves.easeInCubic), child: child),
          ),
          duration: const Duration(milliseconds: 250),
          reverseDuration: const Duration(milliseconds: 250),
        ),
        CustomRoute(
          page: VideoRoute.page,
          path: 'video',
          transitionsBuilder:
              (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) => ScaleTransition(
            scale: CurvedAnimation(parent: animation, curve: Curves.decelerate),
            child: FadeTransition(opacity: CurvedAnimation(parent: animation, curve: Curves.easeInCubic), child: child),
          ),
          duration: const Duration(milliseconds: 250),
          reverseDuration: const Duration(milliseconds: 250),
        ),
      ],
    ),
  ];

  @override
  List<AutoRouteGuard> get guards => [
    // guards can be added here
  ];
}
