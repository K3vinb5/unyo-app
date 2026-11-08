// External dependencies
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/services/api/dto/github/github_release_entity.dart';
import 'package:unyo/core/services/update/app_version_provider.dart';
import 'package:unyo/core/services/update/update_check_result.dart';
import 'package:unyo/presentation/dialogs/about_dialog.dart';

import '../../support/localized_app.dart';

/// The verdict the tabs shell already computed for this launch.
UpdateAvailable newerRelease() => UpdateAvailable(
  release: GithubReleaseEntity()
    ..tagName = 'v0.9.0'
    ..htmlUrl = 'https://github.com/K3vinb5/Unyo/releases/tag/v0.9.0'
    ..body = ''
    ..assets = <GithubReleaseAssets>[],
  latestVersion: '0.9.0',
);

void main() {
  const AppBuildInfo buildInfo = AppBuildInfo(
    version: '1.0.0',
    buildNumber: '42',
  );

  Future<void> openAbout(
    WidgetTester tester, {
    AppBuildInfo? build = buildInfo,
    UpdateCheckResult updateResult = const UpToDate(),
    List<String>? opened,
    Size surface = const Size(1280, 800),
  }) async {
    tester.view.physicalSize = surface;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1920, 1080),
        minTextAdapt: true,
        child: localizedApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => ElevatedButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => UnyoAboutDialog(
                    buildInfoLoader: () async => build,
                    updateResult: updateResult,
                    openUrl: (String url) async {
                      opened?.add(url);
                      return true;
                    },
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows identity, version, licence and credits', (
    WidgetTester tester,
  ) async {
    await openAbout(tester);

    expect(find.text('About Unyo'), findsOneWidget);
    expect(find.text('Version 1.0.0 · build 42'), findsOneWidget);
    expect(find.textContaining('BSD 3-Clause License'), findsOneWidget);
    expect(
      find.text('Created and maintained by Kevin Rodrigues Borges (K3vinb5).'),
      findsOneWidget,
    );
    expect(find.textContaining('Aniyomi and Tachiyomi'), findsOneWidget);
    // The running build never fabricates a version it could not read.
    expect(find.text('Version unavailable'), findsNothing);
  });

  testWidgets('drops the build half when the platform reports none', (
    WidgetTester tester,
  ) async {
    await openAbout(
      tester,
      build: const AppBuildInfo(version: '1.0.0', buildNumber: ''),
    );

    expect(find.text('Version 1.0.0'), findsOneWidget);
    expect(find.textContaining('build'), findsNothing);
  });

  testWidgets('reports an unreadable version instead of a made-up one', (
    WidgetTester tester,
  ) async {
    await openAbout(tester, build: null);

    expect(find.text('Version unavailable'), findsOneWidget);
  });

  testWidgets('every canonical link goes through the external launcher', (
    WidgetTester tester,
  ) async {
    final List<String> opened = <String>[];
    await openAbout(tester, opened: opened);

    for (final String label in <String>['Source code', 'Documentation', 'Issue tracker', 'Releases']) {
      await tester.ensureVisible(find.text(label));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }

    expect(opened, <String>[
      config.unyoSourceUrl,
      config.unyoDocumentationUrl,
      config.unyoIssuesUrl,
      config.unyoReleasesUrl,
    ]);
  });

  testWidgets('the licence browser opens Flutter\'s own licence page', (
    WidgetTester tester,
  ) async {
    await openAbout(tester);

    await tester.ensureVisible(find.text('Open third-party licences'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open third-party licences'));
    await tester.pumpAndSettle();

    expect(find.byType(LicensePage), findsOneWidget);
    expect(find.text('Unyo'), findsOneWidget);
  });

  testWidgets('surfaces a pending update and its release page', (
    WidgetTester tester,
  ) async {
    await openAbout(tester, updateResult: newerRelease());

    expect(find.text('Update available: v0.9.0'), findsOneWidget);
    expect(find.text('Open releases page'), findsOneWidget);
  });

  testWidgets('Esc dismisses the card', (WidgetTester tester) async {
    await openAbout(tester);
    expect(find.text('About Unyo'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.text('About Unyo'), findsNothing);
  });

  testWidgets('scrolls instead of clipping on a short window', (
    WidgetTester tester,
  ) async {
    await openAbout(tester, surface: const Size(900, 520));

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);

    // The last section is reachable by scrolling the card body.
    final Finder releases = find.text('Releases');
    await tester.scrollUntilVisible(
      releases,
      120,
      scrollable: find.descendant(
        of: find.byType(SingleChildScrollView),
        matching: find.byType(Scrollable),
      ),
    );
    expect(releases, findsOneWidget);
  });
}
