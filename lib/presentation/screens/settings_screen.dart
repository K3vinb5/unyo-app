import 'package:auto_route/auto_route.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Internal dependencies
import 'package:unyo/application/cubits/settings_cubit.dart';
import 'package:unyo/application/cubits/tabs_cubit.dart';
import 'package:unyo/application/states/settings_state.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/episode_service.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/services/effects/app_effect_handler.dart';
import 'package:unyo/core/services/media/episode_service.dart';
import 'package:unyo/core/services/media/media_service.dart';
import 'package:unyo/presentation/widgets/styled/shikimori_account_settings.dart';
import 'package:unyo/presentation/widgets/styled/unyo_settings_category.dart';
import 'package:unyo/presentation/widgets/styled/unyo_settings_selection_dialog.dart';
import 'package:unyo/presentation/widgets/styled/unyo_settings_selection_dropdown.dart';
import 'package:unyo/presentation/widgets/styled/unyo_settings_selection_slider.dart';
import 'package:unyo/presentation/widgets/styled/unyo_settings_selection_toggle.dart';
import 'package:unyo/presentation/widgets/styled/unyo_settings_version.dart';
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const TextHeadlineMedium(
                            text: "Manage your ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextHeadlineMedium(
                            text: "Settings!",
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
                            text: "You can find and change your settings here",
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
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0.w, vertical: 20.0.h),
                child: ListView(
                  children: [
                    UnyoSettingsCategory(
                      title: "Accounts",
                      description: "Manage your connected accounts",
                      icon: Icons.person_rounded,
                      alignment: "top",
                      childAlignment: "center",
                      settingsOptions: [
                        const UnyoSettingsCategory(
                          title: "Anilist",
                          description: "Manage your Anilist connected accounts",
                          icon: Icons.format_list_bulleted_rounded,
                          alignment: "",
                          childAlignment: "",
                          isChild: true,
                          settingsOptions: [
                            // TODO - Anilist account settings go here
                          ],
                        ),
                        const UnyoSettingsCategory(
                          title: "MyAnimeList",
                          description: "Manage your MyAnimeList connected accounts",
                          icon: Icons.format_list_bulleted_rounded,
                          alignment: "",
                          childAlignment: "",
                          isChild: true,
                          settingsOptions: [
                            // TODO - MyAnimeList account settings go here
                          ],
                        ),
                        UnyoSettingsCategory(
                          title: "Shikimori",
                          description: "Manage your Shikimori connected accounts",
                          icon: Icons.format_list_bulleted_rounded,
                          alignment: "",
                          childAlignment: "",
                          isChild: true,
                          settingsOptions: [
                            ShikimoriAccountSettings(
                              loggedUser: state.loggedUser,
                              onLogout: () => context.read<TabsCubit>().logoutUser(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    UnyoSettingsCategory(
                      title: "Common",
                      description: "General application settings",
                      icon: Icons.lightbulb_rounded,
                      alignment: "",
                      childAlignment: "",
                      settingsOptions: [
                        UnyoSettingsSelectionDropdown(
                          title: "Media metadata service",
                          description: "Provider that owns details: synopsis, covers, genres and scores",
                          icon: Icons.image_search_rounded,
                          label: "Select a service",
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
                          title: "Episode Metadata Service",
                          description: "Select the Episode Metadata service to use",
                          icon: Icons.movie_filter_rounded,
                          label: "Select a service",
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
                          title: "Language Settings",
                          description: "Manage your language preferences",
                          icon: Icons.chat_bubble_rounded,
                          alignment: "",
                          childAlignment: "",
                          isChild: true,
                          settingsOptions: [
                            UnyoSettingsSelectionDropdown(
                              title: "Language",
                              description: "Select the application language",
                              icon: Icons.language_rounded,
                              label: "Select a language",
                              defaultValue: "English",
                              children: const ["English"],
                              onPressed: (value) {},
                            ),
                            UnyoSettingsSelectionDropdown(
                              title: "Default Media Title Language",
                              description: "Select the default media title language",
                              icon: Icons.text_fields_rounded,
                              label: "Select a language",
                              defaultValue: state.loggedUser.settings.mediaTitleLanguage,
                              children: MediaServiceFactory.getMediaService(state.loggedUser.settings.metadataService).titleLanguages,
                              onPressed: context.read<SettingsCubit>().updateMediaTitleLanguage,
                            ),
                            UnyoSettingsSelectionDropdown(
                              title: "Default Episode Title Language",
                              description: "Select the default episode title language",
                              icon: Icons.text_fields_rounded,
                              label: "Select a language",
                              defaultValue: state.loggedUser.settings.episodeTitleLanguage,
                              children: EpisodeMediaServiceFactory.getEpisodeMediaService(state.loggedUser.settings.episodeService).titleLanguages,
                              onPressed: context.read<SettingsCubit>().updateEpisodeTitleLanguage,
                            ),
                          ],
                        ),
                        UnyoSettingsSelectionToggle(
                          title: "Discord RPC",
                          description: "Enable or disable Discord Rich Presence",
                          icon: Icons.discord_rounded,
                          initiallySelected: state.loggedUser.settings.enableDiscordRichPresence,
                          onPressed: context.read<SettingsCubit>().enableDiscordRichPresence,
                        ),
                        UnyoSettingsSelectionToggle(
                          title: "NSFW Content",
                          icon: Icons.warning_rounded,
                          description: "Enable or disable NSFW content throughout the app",
                          initiallySelected: state.loggedUser.settings.enableNsfwContent,
                          onPressed: context.read<SettingsCubit>().enableNSFWContent,
                        ),
                      ],
                    ),
                    UnyoSettingsCategory(
                      title: "Theme",
                      description: "Appearance settings",
                      icon: Icons.edit_rounded,
                      alignment: "",
                      childAlignment: "",
                      settingsOptions: [
                        UnyoSettingsSelectionDialog(
                            title: "Choose Color",
                            description: "Choose Theme based on a color",
                            icon: Icons.color_lens_rounded,
                            openDialog: () => context.read<SettingsCubit>().openColorPickerDialog(context)
                        ),
                        UnyoSettingsSelectionToggle(
                          title: "Use wallpaper as theme color",
                          description: "Automatically set the theme color based on your wallpaper colors",
                          icon: Icons.wallpaper_rounded,
                          initiallySelected: state.loggedUser.settings.useWallpaperAsThemeColor,
                          onPressed: context.read<SettingsCubit>().enableUseWallpaperAsThemeColor,
                        ),
                      ],
                    ),
                    UnyoSettingsCategory(
                      title: "Player",
                      description: "Video player settings",
                      icon: Icons.play_arrow_rounded,
                      alignment: "",
                      childAlignment: "",
                      settingsOptions: [
                        UnyoSettingsSelectionToggle(
                          title: "Skip opening automatically (when available)",
                          description: "Automatically skip the opening of episodes",
                          icon: Icons.skip_next_rounded,
                          initiallySelected: state.loggedUser.settings.automaticallySkipOpening,
                          onPressed: context.read<SettingsCubit>().enableAutomaticallySkipOpening,
                        ),
                        UnyoSettingsSelectionToggle(
                          title: "Skip ending automatically (when available)",
                          description: "Automatically skip the ending of episodes",
                          icon: Icons.skip_previous_rounded,
                          initiallySelected: state.loggedUser.settings.automaticallySkipEnding,
                          onPressed: context.read<SettingsCubit>().enableAutomaticallySkipEnding,
                        ),
                        UnyoSettingsSelectionSlider(
                          title: "Default manual skip time",
                          description: "Set the default time for manual skips",
                          icon: Icons.fast_forward_rounded,
                          initialValue: state.loggedUser.settings.manualSkipTime,
                          minValue: 60,
                          maxValue: 120,
                          onChanged: context.read<SettingsCubit>().manualSkipTimeUpdate,
                        ),
                        UnyoSettingsSelectionToggle(
                          title: "Enable auto-play next episode",
                          description: "Automatically accept next episode pop-up when the current one ends",
                          icon: Icons.navigate_next_rounded,
                          initiallySelected: state.loggedUser.settings.autoPlayNextEpisode,
                          onPressed: context.read<SettingsCubit>().enableAutoPlayNextEpisode,
                        ),
                        UnyoSettingsSelectionToggle(
                          title: "Enable OpenSubtitles.org integration (When available)",
                          description: "Enable OpenSubtitles.org integration for automatic subtitle fetching",
                          icon: Icons.subtitles_rounded,
                          initiallySelected: state.loggedUser.settings.enableOpenSubtitlesIntegration,
                          onPressed: context.read<SettingsCubit>().enableOpenSubtitlesIntegration,
                        ),
                      ],
                    ),
                    const UnyoSettingsCategory(
                      title: "Reader",
                      description: "Manga reader settings",
                      icon: Icons.my_library_books_rounded,
                      alignment: "",
                      childAlignment: "",
                      settingsOptions: [],
                    ),
                    UnyoSettingsCategory(
                      title: "Extensions",
                      description: "Extensions management settings",
                      icon: Icons.extension_rounded,
                      alignment: "",
                      childAlignment: "",
                      settingsOptions: [
                        UnyoSettingsSelectionDialog(
                          title: "Aniyomi Extensions Repository",
                          description: "Change the Aniyomi extensions repository URL",
                          icon: Icons.link_rounded,
                          openDialog: context.read<SettingsCubit>().openAniyomiExtensionsDialog,
                        ),
                        UnyoSettingsSelectionDialog(
                          title: "Tachiyomi Extensions Repository",
                          description: "Change the Tachiyomi extensions repository URL",
                          icon: Icons.link_rounded,
                          openDialog: context.read<SettingsCubit>().openTachiyomiExtensionsDialog,
                        ),
                      ],
                    ),
                    // Probably have a custom widget here with my information and a link to my social media and ko-fi
                    const UnyoSettingsCategory(
                      title: "About",
                      description: "About the app",
                      icon: Icons.info_rounded,
                      alignment: "bottom",
                      childAlignment: "bottom",
                      settingsOptions: [UnyoSettingsVersion()],
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
