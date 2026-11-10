// External dependencies
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/core/services/api/dto/github/github_release_entity.dart';
import 'package:unyo/core/services/update/update_check_result.dart';
import 'package:unyo/presentation/widgets/styled/unyo_settings_update_badge.dart';

import '../../../support/localized_app.dart';

UpdateAvailable newerRelease() => UpdateAvailable(
  release: GithubReleaseEntity()
    ..htmlUrl = 'https://github.com/K3vinb5/Unyo/releases/tag/v0.9.0',
  latestVersion: '0.9.0',
);

void main() {
  Future<void> pumpBadge(WidgetTester tester, UpdateCheckResult result) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1920, 1080),
        minTextAdapt: true,
        child: localizedApp(
          home: Scaffold(
            body: UnyoSettingsUpdateBadge(result: result),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders nothing when the app is up to date', (
    WidgetTester tester,
  ) async {
    await pumpBadge(tester, const UpToDate());

    expect(find.textContaining('v0.9.0'), findsNothing);
    expect(tester.getSize(find.byType(UnyoSettingsUpdateBadge)), Size.zero);
  });

  testWidgets('shows the newer version when a release is pending', (
    WidgetTester tester,
  ) async {
    await pumpBadge(tester, newerRelease());

    expect(find.text('v0.9.0'), findsOneWidget);
  });
}
