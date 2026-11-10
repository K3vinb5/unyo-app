import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/update/app_version_provider.dart';
import 'package:unyo/core/services/update/release_page_launcher.dart';
import 'package:unyo/core/services/update/update_check_result.dart';
import 'package:unyo/core/services/update/update_checker_service.dart';
import 'package:unyo/presentation/dialogs/unyo_dialog_theme.dart';
import 'package:unyo/presentation/widgets/styled/brand_mark.dart';
import 'package:unyo/presentation/widgets/styled/dark_unyo_button.dart';
import 'package:unyo/presentation/widgets/styled/light_unyo_button.dart';

/// The About card behind the Settings → About row (WP #150).
///
/// Built only from data already on the device: the build stamp comes from
/// [AppVersionProvider] (`package_info_plus`, no network) and the update
/// verdict is the one this launch's startup check already produced. Opening the
/// card never triggers a request; the licence browser is Flutter's own
/// [LicenseRegistry] page, so package notices are shown verbatim instead of
/// being paraphrased here.
///
/// Colours come from [UnyoDialogScheme]; the identity block reuses [BrandMark]
/// so the app icon has one source. Credits name only what the repository
/// actually records: the copyright holder in `LICENSE` and the extension
/// ecosystem the default repositories point at.
class UnyoAboutDialog extends StatefulWidget {
  /// Width of the card, matching the profile dialog's family proportions.
  static const double width = 540;

  /// Height cap: the body scrolls past it instead of growing off-screen.
  static const double maxHeight = 560;

  /// The close action, for keyboard-driven tests and the driven run.
  static const Key closeKey = ValueKey<String>('about-dialog-close');

  /// The third-party licence browser entry point.
  static const Key licencesKey = ValueKey<String>('about-dialog-licences');

  /// Injected in tests; defaults to the DI'd build stamp reader.
  final Future<AppBuildInfo?> Function()? buildInfoLoader;

  /// Opens a URL externally. Defaults to the shared external launcher so About
  /// uses the same mechanism as the update notice.
  final Future<bool> Function(String url) openUrl;

  /// The startup check's verdict. Injected by tests so the card can be exercised
  /// with and without a pending update; defaults to the DI'd verdict, which is
  /// read from memory and never re-queried.
  final UpdateCheckResult? updateResult;

  const UnyoAboutDialog({
    super.key,
    this.buildInfoLoader,
    this.openUrl = ReleasePageLauncher.openPage,
    this.updateResult,
  });

  @override
  State<UnyoAboutDialog> createState() => _UnyoAboutDialogState();
}

class _UnyoAboutDialogState extends State<UnyoAboutDialog> {
  AppBuildInfo? _buildInfo;

  @override
  void initState() {
    super.initState();
    final Future<AppBuildInfo?> Function() loader =
        widget.buildInfoLoader ?? sl<AppVersionProvider>().readBuildInfo;
    loader().then((AppBuildInfo? buildInfo) {
      if (!mounted) return;
      setState(() => _buildInfo = buildInfo);
    });
  }

  /// "Version 1.0.0 · build 42" when the platform reports both halves.
  String _versionLine(BuildContext context) {
    final AppBuildInfo? buildInfo = _buildInfo;
    if (buildInfo == null) return context.tr('settings_version_unavailable');
    if (!buildInfo.hasBuildNumber) {
      return context.tr('dialog_about_version', namedArgs: <String, String>{
        'version': buildInfo.version,
      });
    }
    return context.tr('dialog_about_version_build', namedArgs: <String, String>{
      'version': buildInfo.version,
      'build': buildInfo.buildNumber,
    });
  }

  void _openLicences() {
    showLicensePage(
      context: context,
      applicationName: config.unyoAppName,
      applicationVersion: _buildInfo?.version,
      applicationLegalese: config.unyoLicenceName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = ColorScheme.of(context);
    final UpdateCheckResult? updateResult =
        widget.updateResult ?? sl<UpdateCheckerService>().lastResult;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(unyoDialogCardRadius),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: UnyoAboutDialog.width,
          maxHeight: UnyoAboutDialog.maxHeight,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[scheme.dialogWashTop, scheme.dialogSurface],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _IdentityBlock(versionLine: _versionLine(context)),
                const SizedBox(height: 20),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          context.tr('dialog_about_description'),
                          style: TextStyle(
                            color: scheme.dialogBody,
                            fontSize: 13,
                            height: 1.45,
                          ),
                        ),
                        if (updateResult is UpdateAvailable) ...<Widget>[
                          const SizedBox(height: 16),
                          _AboutSection(
                            title: context.tr('settings_update_available', namedArgs: <String, String>{
                              'version': updateResult.latestVersion,
                            }),
                            children: <Widget>[
                              Text(
                                context.tr('settings_update_available_description'),
                                style: TextStyle(
                                  color: scheme.dialogBody,
                                  fontSize: 13,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DarkUnyoButton(
                                text: context.tr('settings_open_releases_page'),
                                minWidth: 180,
                                height: 40,
                                onPressed: () =>
                                    ReleasePageLauncher.openPage(updateResult.release.htmlUrl),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 20),
                        _AboutSection(
                          title: context.tr('dialog_about_licence_title'),
                          children: <Widget>[
                            Text(
                              context.tr('dialog_about_licence_body'),
                              style: TextStyle(
                                color: scheme.dialogBody,
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 10),
                            DarkUnyoButton(
                              key: UnyoAboutDialog.licencesKey,
                              text: context.tr('dialog_about_open_licences'),
                              minWidth: 220,
                              height: 40,
                              onPressed: _openLicences,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _AboutSection(
                          title: context.tr('dialog_about_credits_title'),
                          children: <Widget>[
                            Text(
                              context.tr('dialog_about_credits_maintainer'),
                              style: TextStyle(
                                color: scheme.dialogBody,
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              context.tr('dialog_about_credits_upstream'),
                              style: TextStyle(
                                color: scheme.dialogBody,
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _AboutSection(
                          title: context.tr('dialog_about_links_title'),
                          children: <Widget>[
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: <Widget>[
                                _LinkButton(
                                  label: context.tr('dialog_about_link_source'),
                                  url: config.unyoSourceUrl,
                                  openUrl: widget.openUrl,
                                ),
                                _LinkButton(
                                  label: context.tr('dialog_about_link_docs'),
                                  url: config.unyoDocumentationUrl,
                                  openUrl: widget.openUrl,
                                ),
                                _LinkButton(
                                  label: context.tr('dialog_about_link_issues'),
                                  url: config.unyoIssuesUrl,
                                  openUrl: widget.openUrl,
                                ),
                                _LinkButton(
                                  label: context.tr('dialog_about_link_releases'),
                                  url: config.unyoReleasesUrl,
                                  openUrl: widget.openUrl,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                LightUnyoButton(
                  key: UnyoAboutDialog.closeKey,
                  text: context.tr('common_close'),
                  width: double.infinity,
                  height: 44,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Icon, name, version and the one-line pitch — the top of the card.
class _IdentityBlock extends StatelessWidget {
  const _IdentityBlock({required this.versionLine});

  final String versionLine;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = ColorScheme.of(context);
    return Row(
      children: <Widget>[
        const BrandMark(size: 56),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                context.tr('dialog_about_title'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: scheme.dialogText,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                versionLine,
                style: TextStyle(color: scheme.dialogDim, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One eyebrow-titled block, separated from its neighbours by a hairline rule.
class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = ColorScheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(height: 1, color: scheme.dialogRule),
        const SizedBox(height: 12),
        Text(
          title,
          style: TextStyle(
            color: scheme.dialogDim,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
}

/// One canonical destination: hands its URL to the external launcher, the same
/// one the update notice uses.
class _LinkButton extends StatelessWidget {
  const _LinkButton({
    required this.label,
    required this.url,
    required this.openUrl,
  });

  final String label;
  final String url;
  final Future<bool> Function(String url) openUrl;

  @override
  Widget build(BuildContext context) {
    return DarkUnyoButton(
      text: label,
      minWidth: 150,
      height: 40,
      onPressed: () => openUrl(url),
    );
  }
}
