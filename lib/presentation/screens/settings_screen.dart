import 'package:auto_route/auto_route.dart';
import 'package:material_ui/material_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Internal dependencies
import 'package:unyo/application/cubits/settings_cubit.dart';
import 'package:unyo/application/states/settings_state.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/episode_service.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/i18n/locale_switcher.dart';
import 'package:unyo/core/services/effects/app_effect_handler.dart';
import 'package:unyo/core/services/media/episode_service.dart';
import 'package:unyo/core/services/media/media_service.dart';
import 'package:unyo/presentation/widgets/styled/unyo_language_dropdown.dart';
import 'package:unyo/presentation/widgets/styled/unyo_settings_category.dart';
import 'package:unyo/presentation/widgets/styled/unyo_settings_selection_dialog.dart';
import 'package:unyo/presentation/widgets/styled/unyo_settings_selection_dropdown.dart';
import 'package:unyo/presentation/widgets/styled/unyo_settings_selection_slider.dart';
import 'package:unyo/presentation/widgets/styled/unyo_settings_selection_toggle.dart';
import 'package:unyo/presentation/widgets/styled/unyo_settings_update_badge.dart';
import 'package:unyo/presentation/widgets/text/text_body_large.dart';
import 'package:unyo/presentation/widgets/text/text_headline_medium.dart';
import 'package:unyo/presentation/widgets/text/text_utils.dart';

@RoutePage()
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SettingsCubit>(),
      child: const _SettingsListener(),
    );
  }
}

class _SettingsListener extends StatelessWidget {
  const _SettingsListener();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state.effects.isNotEmpty) {
          sl<AppEffectHandler>().handleEffects(
            context,
            state.effects,
            context.read<SettingsCubit>().clearEffects,
          );
        }
      },
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
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
                      TextHeadlineMedium(
                        text: context.tr("settings_header_title"),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextBodyLarge(
                        text: context.tr("settings_header_subtitle"),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0.w, vertical: 20.0.h),
                child: ListView(
                  children: [
                    UnyoSettingsCategory(
                      title: context.tr("settings_common_title"),
                      description: context.tr("settings_common_description"),
                      icon: Icons.lightbulb_rounded,
                      // First row of the list: keeps the rounded top the
                      // removed Accounts section used to own (WP #151).
                      alignment: "top",
                      childAlignment: "",
                      settingsOptions: [
                        UnyoSettingsSelectionDropdown(
                          title: context.tr("settings_media_metadata_service_title"),
                          description: context.tr("settings_media_metadata_service_description"),
                          icon: Icons.image_search_rounded,
                          label: context.tr("settings_select_service"),
                          defaultValue:
                              TextUtils.capitalize(state.loggedUser.settings.metadataService.name),
                          children:
                              ProviderCapabilities.metadataProviders
                                  .map(
                                    (service) => TextUtils.capitalize(service.name),
                                  )
                                  .toList(),
                          onPressed: context.read<SettingsCubit>().updateMediaMetadataService,
                        ),
                        UnyoSettingsSelectionDropdown(
                          title: context.tr("settings_episode_metadata_service_title"),
                          description: context.tr("settings_episode_metadata_service_description"),
                          icon: Icons.movie_filter_rounded,
                          label: context.tr("settings_select_service"),
                          defaultValue:
                              TextUtils.capitalize(state.loggedUser.settings.episodeService.name),
                          children:
                              EpisodeService.values
                                  .map(
                                    (service) => TextUtils.capitalize(service.name),
                                  )
                                  .toList(),
                          onPressed: context.read<SettingsCubit>().updateEpisodeMetadataService,
                        ),
                        UnyoSettingsCategory(
                          title: context.tr("settings_language_section_title"),
                          description: context.tr("settings_language_section_description"),
                          icon: Icons.chat_bubble_rounded,
                          alignment: "",
                          childAlignment: "",
                          isChild: true,
                          settingsOptions: [
                            UnyoLanguageDropdown(
                              title: context.tr("settings_language_title"),
                              description: context.tr("settings_language_description"),
                              selectedCode: state.loggedUser.settings.language,
                              onSelected: (String code) async {
                                await context.read<SettingsCubit>().updateLanguage(code);
                                if (!context.mounted) return;
                                await applyUiLanguage(context, code);
                              },
                            ),
                            UnyoSettingsSelectionDropdown(
                              title: context.tr("settings_default_media_title_language_title"),
                              description: context.tr("settings_default_media_title_language_description"),
                              icon: Icons.text_fields_rounded,
                              label: context.tr("settings_language_label"),
                              defaultValue: state.loggedUser.settings.mediaTitleLanguage,
                              children: MediaServiceFactory.getMediaService(state.loggedUser.settings.metadataService).titleLanguages,
                              onPressed: context.read<SettingsCubit>().updateMediaTitleLanguage,
                            ),
                            UnyoSettingsSelectionDropdown(
                              title: context.tr("settings_default_episode_title_language_title"),
                              description: context.tr("settings_default_episode_title_language_description"),
                              icon: Icons.text_fields_rounded,
                              label: context.tr("settings_language_label"),
                              defaultValue: state.loggedUser.settings.episodeTitleLanguage,
                              children: EpisodeMediaServiceFactory.getEpisodeMediaService(state.loggedUser.settings.episodeService).titleLanguages,
                              onPressed: context.read<SettingsCubit>().updateEpisodeTitleLanguage,
                            ),
                          ],
                        ),
                        UnyoSettingsSelectionToggle(
                          title: context.tr("settings_discord_rpc_title"),
                          description: context.tr("settings_discord_rpc_description"),
                          icon: Icons.discord_rounded,
                          initiallySelected: state.loggedUser.settings.enableDiscordRichPresence,
                          onPressed: context.read<SettingsCubit>().enableDiscordRichPresence,
                        ),
                        UnyoSettingsSelectionToggle(
                          title: context.tr("settings_nsfw_content_title"),
                          icon: Icons.warning_rounded,
                          description: context.tr("settings_nsfw_content_description"),
                          initiallySelected: state.loggedUser.settings.enableNsfwContent,
                          onPressed: context.read<SettingsCubit>().enableNSFWContent,
                        ),
                      ],
                    ),
                    UnyoSettingsCategory(
                      title: context.tr("settings_theme_title"),
                      description: context.tr("settings_theme_description"),
                      icon: Icons.edit_rounded,
                      alignment: "",
                      childAlignment: "",
                      settingsOptions: [
                        UnyoSettingsSelectionDialog(
                            title: context.tr("settings_choose_color_title"),
                            description: context.tr("settings_choose_color_description"),
                            icon: Icons.color_lens_rounded,
                            openDialog: () => context.read<SettingsCubit>().openColorPickerDialog(context)
                        ),
                        UnyoSettingsSelectionToggle(
                          title: context.tr("settings_wallpaper_theme_color_title"),
                          description: context.tr("settings_wallpaper_theme_color_description"),
                          icon: Icons.wallpaper_rounded,
                          initiallySelected: state.loggedUser.settings.useWallpaperAsThemeColor,
                          onPressed: context.read<SettingsCubit>().enableUseWallpaperAsThemeColor,
                        ),
                      ],
                    ),
                    UnyoSettingsCategory(
                      title: context.tr("settings_player_title"),
                      description: context.tr("settings_player_description"),
                      icon: Icons.play_arrow_rounded,
                      alignment: "",
                      childAlignment: "",
                      settingsOptions: [
                        UnyoSettingsSelectionToggle(
                          title: context.tr("settings_skip_opening_title"),
                          description: context.tr("settings_skip_opening_description"),
                          icon: Icons.skip_next_rounded,
                          initiallySelected: state.loggedUser.settings.automaticallySkipOpening,
                          onPressed: context.read<SettingsCubit>().enableAutomaticallySkipOpening,
                        ),
                        UnyoSettingsSelectionToggle(
                          title: context.tr("settings_skip_ending_title"),
                          description: context.tr("settings_skip_ending_description"),
                          icon: Icons.skip_previous_rounded,
                          initiallySelected: state.loggedUser.settings.automaticallySkipEnding,
                          onPressed: context.read<SettingsCubit>().enableAutomaticallySkipEnding,
                        ),
                        UnyoSettingsSelectionSlider(
                          title: context.tr("settings_manual_skip_time_title"),
                          description: context.tr("settings_manual_skip_time_description"),
                          icon: Icons.fast_forward_rounded,
                          initialValue: state.loggedUser.settings.manualSkipTime,
                          minValue: 60,
                          maxValue: 120,
                          onChanged: context.read<SettingsCubit>().manualSkipTimeUpdate,
                        ),
                        UnyoSettingsSelectionToggle(
                          title: context.tr("settings_auto_play_next_episode_title"),
                          description: context.tr("settings_auto_play_next_episode_description"),
                          icon: Icons.navigate_next_rounded,
                          initiallySelected: state.loggedUser.settings.autoPlayNextEpisode,
                          onPressed: context.read<SettingsCubit>().enableAutoPlayNextEpisode,
                        ),
                        UnyoSettingsSelectionToggle(
                          title: context.tr("settings_opensubtitles_title"),
                          description: context.tr("settings_opensubtitles_description"),
                          icon: Icons.subtitles_rounded,
                          initiallySelected: state.loggedUser.settings.enableOpenSubtitlesIntegration,
                          onPressed: context.read<SettingsCubit>().enableOpenSubtitlesIntegration,
                        ),
                      ],
                    ),
                    UnyoSettingsCategory(
                      title: context.tr("settings_reader_title"),
                      description: context.tr("settings_reader_description"),
                      icon: Icons.my_library_books_rounded,
                      alignment: "",
                      childAlignment: "",
                      // WP #148: the category has no settings until the manga
                      // reader ships; one explanatory row beats an empty box
                      // that reads like a rendering bug.
                      settingsOptions: [
                        UnyoSettingsSelectionDialog(
                          title: context.tr("settings_reader_title"),
                          description: context.tr("settings_reader_description"),
                          icon: Icons.my_library_books_rounded,
                          openDialog: context.read<SettingsCubit>().openReaderSettingsDialog,
                        ),
                      ],
                    ),
                    UnyoSettingsCategory(
                      title: context.tr("settings_extensions_title"),
                      description: context.tr("settings_extensions_description"),
                      icon: Icons.extension_rounded,
                      alignment: "",
                      childAlignment: "",
                      settingsOptions: [
                        UnyoSettingsSelectionDialog(
                          title: context.tr("settings_aniyomi_repository_title"),
                          description: context.tr("settings_aniyomi_repository_description"),
                          icon: Icons.link_rounded,
                          openDialog: context.read<SettingsCubit>().openAniyomiExtensionsDialog,
                        ),
                        UnyoSettingsSelectionDialog(
                          title: context.tr("settings_tachiyomi_repository_title"),
                          description: context.tr("settings_tachiyomi_repository_description"),
                          icon: Icons.link_rounded,
                          openDialog: context.read<SettingsCubit>().openTachiyomiExtensionsDialog,
                        ),
                      ],
                    ),
                    // WP #150: same row as before, but it activates the About
                    // card instead of expanding into a lone version string.
                    UnyoSettingsCategory(
                      title: context.tr("settings_about_title"),
                      description: context.tr("settings_about_description"),
                      icon: Icons.info_rounded,
                      alignment: "bottom",
                      childAlignment: "bottom",
                      badge: const UnyoSettingsUpdateBadge(),
                      onActivate: context.read<SettingsCubit>().openAboutDialog,
                      settingsOptions: const [],
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
