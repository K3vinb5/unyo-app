import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart' show sl;
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/presentation/widgets/styled/unyo_banner_carousel.dart';

import '../skeleton/support/widget_harness.dart';

/// Tail-review sweep on PR #188: the banner carousel printed the raw 0–100
/// `meanScore` next to a star ("90"), the same display bug the details pages
/// had before `TextUtils.scoreOutOfTen` existed. Every user-facing score goes
/// through that helper, so the banner must show "9.0" and never "90".
void main() {
  // Each banner title resolves through the logged-user notifier
  // (`displayMediaTitle`), so the display seam needs the app's registration —
  // same wiring as skeleton_swap_test.
  setUp(() {
    sl.reset();
    sl.registerSingleton<Logger>(Logger(filter: ProductionFilter()));
    sl.registerSingleton<UserNotifier>(
      UserNotifier(),
      instanceName: config.loggedUserNotifier,
    );
  });

  tearDown(() => sl.reset());

  testWidgets('banner score shows the 0-10 form, not the raw 0-100 int', (
    tester,
  ) async {
    await pumpSkeletonHarness(
      tester,
      UnyoBannerCarousel(
        animeList: [AnimeModel.empty().copyWith(id: 1, meanScore: 90)],
      ),
    );

    expect(find.text('9.0'), findsOneWidget);
    expect(
      find.text('90'),
      findsNothing,
      reason: 'the raw 0-100 int must never render beside the star',
    );

    // "9.0" is one glyph wider than the raw "90"; the badge must grow to fit
    // rather than clip it (this overflowed the old fixed 50px box).
    expect(tester.takeException(), isNull);

    // Unmount so the auto-scroll timer is cancelled before teardown.
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
