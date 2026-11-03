// External dependencies
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/core/services/api/dto/github/github_release_entity.dart';
import 'package:unyo/core/services/update/release_asset_selector.dart';
import 'package:unyo/core/services/update/release_page_launcher.dart';
import 'package:unyo/presentation/widgets/styled/dark_unyo_button.dart';
import 'package:unyo/presentation/widgets/text/text_body_large.dart';
import 'package:unyo/presentation/widgets/text/text_headline_medium.dart';

/// The one notice a newer GitHub release earns: what changed, rendered from the
/// release `body` markdown, with a link to the release page and — when the
/// release published an installer for this platform — a direct download.
///
/// Shown on every launch while a newer release exists; dismissing it only
/// silences the current run. It never downloads or installs anything by itself:
/// the download button hands the asset URL to the system browser.
class UpdateAvailableDialog extends StatelessWidget {
  /// Catalog key of the headline, so the dialog renders localized copy.
  static const String titleKey = 'dialog_update_title';

  /// English source of [titleKey], kept as the canonical string for tests.
  static const String title = "There's a new release";

  /// The published release the verdict was drawn from. Notes, assets and the
  /// release page URL are read straight off it.
  final GithubReleaseEntity release;

  /// The release tag without its leading `v`, i.e. the version that was
  /// compared against the running build.
  final String latestVersion;

  final VoidCallback onOpenReleasePage;

  /// The platform the download button offers. Null means "whatever is running
  /// now"; tests inject a value so every mapping is covered on one host.
  final UpdatePlatform? platform;

  /// Opens a URL externally. Defaults to the shared release-asset launcher so
  /// both actions go through `url_launcher`.
  final Future<bool> Function(String url) openUrl;

  const UpdateAvailableDialog({
    super.key,
    required this.release,
    required this.latestVersion,
    required this.onOpenReleasePage,
    this.platform,
    this.openUrl = ReleasePageLauncher.openAsset,
  });

  @override
  Widget build(BuildContext context) {
    final String notes = release.body.trim();
    final UpdatePlatform targetPlatform = platform ?? UpdatePlatformInfo.current;
    final String? downloadUrl = ReleaseAssetSelector.urlFor(
      release.assets,
      targetPlatform,
    );
    return Dialog(
      backgroundColor: const Color.fromARGB(255, 30, 30, 30),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.new_releases_rounded,
                    color: ColorScheme.of(context).tertiary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextHeadlineMedium(text: context.tr(titleKey)),
                        TextBodyLarge(
                          text: context.tr(
                            'dialog_update_subtitle',
                            namedArgs: <String, String>{'version': latestVersion},
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: notes.isEmpty
                      ? TextBodyLarge(
                          text: context.tr('dialog_update_no_notes'),
                        )
                      : MarkdownBody(
                          data: notes,
                          styleSheet: _styleSheet,
                          // Links inside release notes open in the system
                          // browser, like the explicit button below.
                          onTapLink: (_, href, _) =>
                              ReleasePageLauncher.openPage(href),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DarkUnyoButton(
                    text: context.tr('dialog_update_later'),
                    minWidth: 100,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  DarkUnyoButton(
                    text: context.tr('dialog_update_open_release_page'),
                    minWidth: 180,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onOpenReleasePage();
                    },
                  ),
                  if (downloadUrl != null) ...[
                    const SizedBox(width: 12),
                    DarkUnyoButton(
                      text: context.tr(
                        'dialog_update_download_for',
                        namedArgs: <String, String>{'platform': targetPlatform.label},
                      ),
                      minWidth: 200,
                      onPressed: () {
                        Navigator.of(context).pop();
                        openUrl(downloadUrl);
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The app renders on top of the `material_ui` fork, so the markdown package
  /// cannot derive its sheet from the app theme (`ThemeData` differs between the
  /// two libraries); spell the dark styles out instead.
  static const TextStyle _body = TextStyle(
    color: Colors.white70,
    fontSize: 14,
    height: 1.5,
  );
  static const TextStyle _heading = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );
  static const BoxDecoration _blockDecoration = BoxDecoration(
    color: Color.fromARGB(255, 20, 20, 20),
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );
  static final MarkdownStyleSheet _styleSheet = MarkdownStyleSheet(
    p: _body,
    a: _body.copyWith(color: Colors.lightBlueAccent),
    em: _body.copyWith(fontStyle: FontStyle.italic),
    strong: _body.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
    h1: _heading.copyWith(fontSize: 20),
    h2: _heading.copyWith(fontSize: 17),
    h3: _heading.copyWith(fontSize: 15),
    listBullet: _body,
    code: const TextStyle(
      color: Colors.amberAccent,
      fontFamily: 'monospace',
      fontSize: 13,
    ),
    codeblockDecoration: _blockDecoration,
    blockquoteDecoration: _blockDecoration,
  );
}
