// External dependencies
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/core/services/api/dto/github/github_release_entity.dart';
import 'package:unyo/core/services/update/release_asset_selector.dart';
import 'package:unyo/presentation/dialogs/update_available_dialog.dart';

GithubReleaseAssets asset(String name) => GithubReleaseAssets()
  ..name = name
  ..browserDownloadUrl =
      'https://github.com/K3vinb5/Unyo/releases/download/v0.9.0/$name';

/// The release the dialog renders: notes, assets and page URL all come from this
/// one bean, exactly like the verdict carries it.
GithubReleaseEntity release({
  String notes = '- something changed',
  List<GithubReleaseAssets> assets = const [],
}) => GithubReleaseEntity()
  ..tagName = 'v0.9.0'
  ..htmlUrl = 'https://github.com/K3vinb5/Unyo/releases/tag/v0.9.0'
  ..body = notes
  ..assets = assets;

final List<GithubReleaseAssets> releaseAssets = [
  asset('Unyo-v0.9.0-linux.zip'),
  asset('Unyo-v0.9.0-linux.AppImage'),
  asset('Unyo-v0.9.0-windows-setup.exe'),
  asset('Unyo-v0.9.0-macos.dmg'),
];

void main() {
  Future<void> openDialog(
    WidgetTester tester, {
    String releaseNotes = '- something changed',
    required VoidCallback onOpenReleasePage,
    List<GithubReleaseAssets>? assets,
    UpdatePlatform? platform,
    Future<bool> Function(String url)? openUrl,
  }) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1920, 1080),
        minTextAdapt: true,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => UpdateAvailableDialog(
                    release: release(
                      notes: releaseNotes,
                      assets: assets ?? const [],
                    ),
                    latestVersion: '0.9.0',
                    onOpenReleasePage: onOpenReleasePage,
                    platform: platform,
                    openUrl: openUrl ?? (_) async => true,
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('renders the published release notes as markdown', (
    tester,
  ) async {
    await openDialog(
      tester,
      releaseNotes:
          "## What's changed\n\n- Release notes now open in a dialog.",
      onOpenReleasePage: () {},
    );

    expect(find.text(UpdateAvailableDialog.title), findsOneWidget);
    expect(find.textContaining('Unyo v0.9.0'), findsOneWidget);
    final MarkdownBody markdown = tester.widget<MarkdownBody>(find.byType(MarkdownBody));
    expect(markdown.data, contains('Release notes now open in a dialog.'));
    // The heading is rendered as rich text, not as the raw `##` markdown.
    expect(find.textContaining("## What's changed"), findsNothing);
    expect(find.text("What's changed"), findsOneWidget);
  });

  testWidgets('explains itself when the release was published without notes', (
    tester,
  ) async {
    await openDialog(tester, releaseNotes: '  ', onOpenReleasePage: () {});

    expect(find.byType(MarkdownBody), findsNothing);
    expect(find.textContaining('published without notes'), findsOneWidget);
  });

  testWidgets('opens the release page and dismisses itself', (tester) async {
    int opened = 0;
    await openDialog(
      tester,
      releaseNotes: '- something changed',
      onOpenReleasePage: () => opened++,
      assets: releaseAssets,
    );

    await tester.tap(find.text('Open release page'));
    await tester.pumpAndSettle();

    expect(opened, 1);
    expect(find.byType(UpdateAvailableDialog), findsNothing);
  });

  for (final (platform, expectedAsset) in [
    (UpdatePlatform.windows, 'Unyo-v0.9.0-windows-setup.exe'),
    (UpdatePlatform.macOS, 'Unyo-v0.9.0-macos.dmg'),
    (UpdatePlatform.linux, 'Unyo-v0.9.0-linux.AppImage'),
  ]) {
    testWidgets(
      'downloads the ${platform.label} asset from the dedicated button',
      (tester) async {
        final List<String> openedUrls = <String>[];
        await openDialog(
          tester,
          onOpenReleasePage: () {},
          assets: releaseAssets,
          platform: platform,
          openUrl: (url) async {
            openedUrls.add(url);
            return true;
          },
        );

        await tester.tap(find.text('Download for ${platform.label}'));
        await tester.pumpAndSettle();

        expect(openedUrls, [
          'https://github.com/K3vinb5/Unyo/releases/download/v0.9.0/$expectedAsset',
        ]);
        expect(find.byType(UpdateAvailableDialog), findsNothing);
      },
    );
  }

  testWidgets('hides the download button when the release has no matching asset', (
    tester,
  ) async {
    await openDialog(
      tester,
      onOpenReleasePage: () {},
      assets: [asset('Unyo-v0.9.0-windows-setup.exe')],
      platform: UpdatePlatform.macOS,
    );

    expect(find.textContaining('Download for'), findsNothing);
    expect(find.text('Open release page'), findsOneWidget);
    expect(find.text('Later'), findsOneWidget);
  });

  testWidgets('hides the download button when the release has no assets', (
    tester,
  ) async {
    await openDialog(tester, onOpenReleasePage: () {});

    expect(find.textContaining('Download for'), findsNothing);
  });
}
