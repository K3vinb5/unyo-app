// External dependencies
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/core/services/update/release_page_launcher.dart';
import 'package:unyo/presentation/widgets/styled/dark_unyo_button.dart';
import 'package:unyo/presentation/widgets/text/text_body_large.dart';
import 'package:unyo/presentation/widgets/text/text_headline_medium.dart';

/// The one notice a newer GitHub release earns: what changed, rendered from the
/// release `body` markdown, with a link to the release page.
///
/// Shown once per process launch by the tabs shell; it never downloads or
/// installs anything.
class UpdateAvailableDialog extends StatelessWidget {
  static const String title = "There's a new release";

  final String latestVersion;
  final String releaseNotes;
  final VoidCallback onOpenReleasePage;

  const UpdateAvailableDialog({
    super.key,
    required this.latestVersion,
    required this.releaseNotes,
    required this.onOpenReleasePage,
  });

  @override
  Widget build(BuildContext context) {
    final notes = releaseNotes.trim();
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
                        const TextHeadlineMedium(text: title),
                        TextBodyLarge(
                          text:
                              "Unyo v$latestVersion is out — here's what changed.",
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
                      ? const TextBodyLarge(
                          text:
                              "This release was published without notes. "
                              "Open the release page for the full changelog.",
                        )
                      : MarkdownBody(
                          data: notes,
                          styleSheet: _styleSheet,
                          // Links inside release notes open in the system
                          // browser, like the explicit button below.
                          onTapLink: (_, href, _) => openReleasePage(href),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DarkUnyoButton(
                    text: "Later",
                    minWidth: 100,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  DarkUnyoButton(
                    text: "Open release page",
                    minWidth: 180,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onOpenReleasePage();
                    },
                  ),
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
