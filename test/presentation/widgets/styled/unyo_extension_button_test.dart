import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/styled/unyo_extension_button.dart';
import 'package:unyo/presentation/widgets/styled/unyo_network_image.dart';

import '../skeleton/support/fake_image_http.dart';
import '../skeleton/support/widget_harness.dart';

/// WP #91: the extension icon is a rounded square. It used to be a `ClipOval`
/// around a skeleton-tinted slot, which cropped the artwork into a circle and
/// let the grey placeholder show through the PNG's transparent corners.
void main() {
  testWidgets('icon slot is a rounded square, never a circle', (tester) async {
    await withFakeImages(() async {
      await pumpSkeletonHarness(
        tester,
        UnyoExtensionButton(
          iconUrl: 'https://example.test/animeonsen.png',
          name: 'AnimeOnsen',
          lang: 'all',
          version: '14.10',
          nsfw: 0,
          repoUrl: 'https://gitea.k3vinb5.dev/Unyo/animeonsen',
          onDownloadPressed: () {},
        ),
      );

      expect(
        find.byType(ClipOval),
        findsNothing,
        reason: 'a ClipOval crops the rounded-square artwork into a circle',
      );

      final Finder iconSlot = find.byType(UnyoNetworkImage);
      expect(tester.getSize(iconSlot), const Size(52, 52));

      final ClipRRect clip = tester.widget<ClipRRect>(
        find.descendant(of: iconSlot, matching: find.byType(ClipRRect)),
      );
      expect(
        clip.borderRadius,
        BorderRadius.circular(UnyoExtensionButton.iconBorderRadius),
      );
      expect(UnyoExtensionButton.iconBorderRadius, greaterThan(0));

      expect(
        find.descendant(of: iconSlot, matching: find.byType(ColoredBox)),
        findsNothing,
        reason: 'the skeleton colour must not paint behind the artwork',
      );
      expect(tester.takeException(), isNull);
    });
  });
}
