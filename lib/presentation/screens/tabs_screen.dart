// External dependencies
import 'package:material_ui/material_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unyo/application/cubits/tabs_cubit.dart';
import 'package:unyo/application/cubits/update_cubit.dart';
import 'package:unyo/application/states/tabs_state.dart';
import 'package:unyo/application/states/update_state.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/selected_menu_option.dart';
import 'package:unyo/core/router/app_router.gr.dart';
import 'package:unyo/core/services/effects/app_effect_handler.dart';
import 'package:unyo/presentation/widgets/styled/unyo_menu_bar.dart';
import 'package:unyo/presentation/widgets/styled/unyo_menu_icon.dart';

@RoutePage()
class TabsScreen extends StatelessWidget {
  const TabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TabsCubit>(),
      child: const _TabsListener(),
    );
  }
}

class _TabsListener extends StatefulWidget {
  const _TabsListener();

  @override
  State<_TabsListener> createState() => _TabsListenerState();
}

class _TabsListenerState extends State<_TabsListener> {
  /// The one-shot update notice can land before this screen's listener is
  /// attached (the check is kicked from `main`). Drain whatever the singleton
  /// already carries once the first frame is up; [AppEffectHandler] dedupes by
  /// effect instance, so a notice the listener already saw never shows twice.
  void _drainPendingUpdateEffects() {
    if (!mounted) return;
    final cubit = sl<UpdateCubit>();
    final effects = cubit.state.effects;
    if (effects.isEmpty) return;
    sl<AppEffectHandler>().handleEffects(context, effects, cubit.clearEffects);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _drainPendingUpdateEffects());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UpdateCubit>.value(
      value: sl<UpdateCubit>(),
      child: BlocListener<UpdateCubit, UpdateState>(
        // One-shot notice per launch: the cubit only ever adds this effect once.
        listener: (context, state) {
          if (state.effects.isNotEmpty) {
            sl<AppEffectHandler>().handleEffects(
              context,
              state.effects,
              context.read<UpdateCubit>().clearEffects,
            );
          }
        },
        child: BlocListener<TabsCubit, TabsState>(
          listener: (context, state) {
            if (state.effects.isNotEmpty) {
              sl<AppEffectHandler>().handleEffects(
                context,
                state.effects,
                context.read<TabsCubit>().clearEffects,
              );
            }
          },
          child: const _TabsView(),
        ),
      ),
    );
  }
}

class _TabsView extends StatelessWidget {
  const _TabsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TabsCubit, TabsState>(
      builder: (context, state) {
        return AutoTabsRouter(
          lazyLoad: true,
          routes: const [
            HomeRoute(),
            AnimeRoute(),
            MangaRoute(),
            ExtensionsRoute(),
            SettingsRoute()
          ],
          builder: (context, child) {
            sl<AppEffectHandler>().attachRootContext(context);
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                state.showMenuBar
                    ? UnyoMenuBar(
                      avatarImage: state.loggedUser.avatarImage,
                      onIconTap: () => context.read<TabsCubit>().showUserOptionsDrawer(),
                      icons: [
                        UnyoMenuIcon(
                          key: const ValueKey('menu-home'),
                          isSelected:
                              state.selectedMenuOption ==
                              SelectedMenuOption.home,
                          onPressed:
                              () => context.read<TabsCubit>().selectMenuOption(
                                SelectedMenuOption.home,
                                context,
                              ),
                          unselectedIcon: Icons.home_outlined,
                          selectedIcon: Icons.home,
                        ),
                        UnyoMenuIcon(
                          key: const ValueKey('menu-anime'),
                          isSelected:
                              state.selectedMenuOption ==
                              SelectedMenuOption.anime,
                          onPressed:
                              () => context.read<TabsCubit>().selectMenuOption(
                                SelectedMenuOption.anime,
                                context,
                              ),
                          unselectedIcon: Icons.movie_outlined,
                          selectedIcon: Icons.movie,
                        ),
                        UnyoMenuIcon(
                          key: const ValueKey('menu-manga'),
                          isSelected:
                              state.selectedMenuOption ==
                              SelectedMenuOption.manga,
                          onPressed:
                              () => context.read<TabsCubit>().selectMenuOption(
                                SelectedMenuOption.manga,
                                context,
                              ),
                          unselectedIcon: Icons.menu_book_outlined,
                          selectedIcon: Icons.menu_book,
                        ),
                        UnyoMenuIcon(
                          key: const ValueKey('menu-extensions'),
                          isSelected:
                              state.selectedMenuOption ==
                              SelectedMenuOption.extensions,
                          onPressed:
                              () => context.read<TabsCubit>().selectMenuOption(
                                SelectedMenuOption.extensions,
                                context,
                              ),
                          unselectedIcon: Icons.extension_outlined,
                          selectedIcon: Icons.extension,
                        ),
                        UnyoMenuIcon(
                          key: const ValueKey('menu-settings'),
                          isSelected:
                              state.selectedMenuOption ==
                              SelectedMenuOption.settings,
                          onPressed:
                              () => context.read<TabsCubit>().selectMenuOption(
                                SelectedMenuOption.settings,
                                context,
                              ),
                          unselectedIcon: Icons.settings_outlined,
                          selectedIcon: Icons.settings,
                        ),
                      ],
                    )
                    : const SizedBox.shrink(),
                Expanded(child: child),
              ],
            );
          },
        );
      },
    );
  }
}
