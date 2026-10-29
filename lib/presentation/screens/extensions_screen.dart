import 'package:auto_route/auto_route.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:unyo/application/cubits/extensions_cubit.dart';
import 'package:unyo/application/states/extensions_state.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/domain/entities/extension/extension.dart';
import 'package:unyo/core/services/effects/app_effect_handler.dart';
import 'package:unyo/presentation/widgets/skeleton/skeletons.dart';
import 'package:unyo/presentation/widgets/styled/unyo_dropdown.dart';
import 'package:unyo/presentation/widgets/styled/unyo_extension_button.dart';
import 'package:unyo/presentation/widgets/styled/unyo_textfield.dart';
import 'package:unyo/presentation/widgets/text/text_body_large.dart';
import 'package:unyo/presentation/widgets/text/text_headline_medium.dart';
import 'package:unyo/presentation/widgets/text/text_utils.dart';

@RoutePage()
class ExtensionsScreen extends StatelessWidget {
  const ExtensionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => sl<ExtensionsCubit>(), child: const _ExtensionsListener());
  }
}

class _ExtensionsListener extends StatelessWidget {
  const _ExtensionsListener();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExtensionsCubit, ExtensionsState>(
      listener: (context, state) {
        if (state.effects.isNotEmpty) {
          sl<AppEffectHandler>().handleEffects(
            context,
            state.effects,
            context.read<ExtensionsCubit>().clearEffects,
          );
        }
      },
      child: const SkeletonScope(child: _ExtensionsView()),
    );
  }
}

class _ExtensionsView extends StatefulWidget {
  const _ExtensionsView();

  @override
  State<_ExtensionsView> createState() => _ExtensionsViewState();
}

class _ExtensionsViewState extends State<_ExtensionsView> with TickerProviderStateMixin {
  late TabController tabController;
  String _searchQuery = '';
  String? _selectedRepo;

  List<Extension> _filter(List<Extension> extensions) {
    var filtered = extensions;
    if (_selectedRepo != null) {
      filtered = filtered.where((e) => TextUtils.extractRepoName(e.repositoryUrl) == _selectedRepo).toList();
    }
    if (_searchQuery.isEmpty) return filtered;
    final results = extractTop(
      query: _searchQuery,
      choices: filtered,
      limit: filtered.length,
      cutoff: 30,
      getter: (e) => '${e.name} ${e.lang}',
    );
    return results.map((r) => r.choice).toList();
  }

  @override
  void initState() {
    tabController = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExtensionsCubit, ExtensionsState>(
      builder: (context, state) {
        return Column(
          children: [
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Row(
                children: [
                  SizedBox(width: 40.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const TextHeadlineMedium(
                            text: "Manage your ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextHeadlineMedium(
                            text: "Extensions!",
                            style: TextStyle(
                              color: ColorScheme.of(context).tertiary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextBodyLarge(
                            text: "You can find and install your favorite extensions here",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TabBar(
                labelColor: Colors.white,
                dividerColor: ColorScheme.of(context).secondary.withValues(alpha: 0.5),
                indicatorColor: ColorScheme.of(context).primary,
                unselectedLabelColor: Colors.grey,
                isScrollable: true,
                controller: tabController,
                tabs: const [
                  Tooltip(
                    waitDuration: Duration(milliseconds: 1000),
                    message: "Available Anime",
                    child: SizedBox(width: 150, child: Tab(text: "Available Anime")),
                  ),
                  Tooltip(
                    waitDuration: Duration(milliseconds: 1000),
                    message: "Available Manga",
                    child: SizedBox(width: 150, child: Tab(text: "Available Manga")),
                  ),
                  Tooltip(
                    waitDuration: Duration(milliseconds: 1000),
                    message: "Installed Anime",
                    child: SizedBox(width: 150, child: Tab(text: "Installed Anime")),
                  ),
                  Tooltip(
                    waitDuration: Duration(milliseconds: 1000),
                    message: "Installed Manga",
                    child: SizedBox(width: 150, child: Tab(text: "Installed Manga")),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 32.w, right: 32.w, top: 16.h),
              child: Row(
                children: [
                  Expanded(
                    flex: 8,
                    child: UnyoTextfield(
                      label: "Search extensions...",
                      debounceMilliseconds: 300,
                      onChange: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 8.w),
                    Expanded(
                    flex: 2,
                    child: UnyoDropdown(
                      label: "Repository...",
                      selectedValue: _selectedRepo,
                      reactOnCancel: true,
                      children: context.read<ExtensionsCubit>().getAvailableRepositories().toList(),
                      onPressed: (repo) => setState(() {
                        _selectedRepo = repo;
                      }),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 15.0.w, right: 15.0.w, top: 15.0.h),
                child: TabBarView(
                  controller: tabController,
                  children: [
                    ListView(
                      scrollDirection: Axis.vertical,
                      children: [
                        if (!state.extensionsLoaded)
                          ...List.generate(
                            8,
                            (index) => const ExtensionRowSkeleton(),
                          )
                        else
                        ..._filter(state.availableAnimeExtensions).map(
                          (extension) => UnyoExtensionButton(
                            iconUrl: extension.icon,
                            name: extension.name,
                            lang: extension.lang,
                            version: extension.version,
                            nsfw: extension.nsfw,
                            repoUrl: extension.repositoryUrl,
                            onDownloadPressed: () =>
                                context.read<ExtensionsCubit>().downloadExtension(extension),
                          ),
                        ),
                      ],
                    ),
                    ListView(
                      scrollDirection: Axis.vertical,
                      children: [
                        if (!state.extensionsLoaded)
                          ...List.generate(
                            8,
                            (index) => const ExtensionRowSkeleton(),
                          )
                        else
                        ..._filter(state.availableMangaExtensions).map(
                          (extension) => UnyoExtensionButton(
                            iconUrl: extension.icon,
                            name: extension.name,
                            lang: extension.lang,
                            version: extension.version,
                            nsfw: extension.nsfw,
                            repoUrl: extension.repositoryUrl,
                            onDownloadPressed: () =>
                                context.read<ExtensionsCubit>().downloadExtension(extension),
                          ),
                        ),
                      ],
                    ),
                    ListView(
                      scrollDirection: Axis.vertical,
                      children: [
                        if (!state.extensionsLoaded)
                          ...List.generate(
                            8,
                            (index) => const ExtensionRowSkeleton(),
                          )
                        else
                        ..._filter(state.installedAnimeExtensions).map(
                          (extension) => UnyoExtensionButton(
                            iconUrl: extension.icon,
                            name: extension.name,
                            lang: extension.lang,
                            version: extension.version,
                            nsfw: extension.nsfw,
                            repoUrl: extension.repositoryUrl,
                            onUpdatePressed: state.animeExtensionUpdates.containsKey(extension.pkg)
                                ? () => context.read<ExtensionsCubit>().updateExtension(extension)
                                : null,
                            onDeletePressed: () => context.read<ExtensionsCubit>().removeExtension(extension),
                            onSettingsPressed: () => context.read<ExtensionsCubit>().openExtensionPreferences(extension),
                          ),
                        ),
                      ],
                    ),
                    ListView(
                      scrollDirection: Axis.vertical,
                      children: [
                        if (!state.extensionsLoaded)
                          ...List.generate(
                            8,
                            (index) => const ExtensionRowSkeleton(),
                          )
                        else
                        ..._filter(state.installedMangaExtensions).map(
                          (extension) => UnyoExtensionButton(
                            iconUrl: extension.icon,
                            name: extension.name,
                            lang: extension.lang,
                            version: extension.version,
                            nsfw: extension.nsfw,
                            repoUrl: extension.repositoryUrl,
                            onUpdatePressed: state.mangaExtensionUpdates.containsKey(extension.pkg)
                                ? () => context.read<ExtensionsCubit>().updateExtension(extension)
                                : null,
                            onDeletePressed: () => context.read<ExtensionsCubit>().removeExtension(extension),
                            onSettingsPressed: () => context.read<ExtensionsCubit>().openExtensionPreferences(extension),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
