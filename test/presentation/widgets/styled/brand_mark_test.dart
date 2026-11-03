// External dependencies
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/presentation/widgets/styled/brand_mark.dart';

import '../../../support/localized_app.dart';

/// WP #84: the login screen used to draw `assets/logo.png` at `scale: 2.5` —
/// the old flat 100x100 export. The brand mark is now generated from
/// `packaging/icons/source/unyo_1024.png` and drawn at an explicit size, so the
/// window icon, the packaging icons and the in-app logo cannot drift apart.
void main() {
  testWidgets('BrandMark renders the generated brand-mark asset at 40x40', (WidgetTester tester) async {
    await tester.pumpWidget(
      localizedApp(
        home: const Scaffold(body: Center(child: BrandMark())),
      ),
    );
    await tester.pump();

    final Finder image = find.byType(Image);
    expect(image, findsOneWidget);

    final Image widget = tester.widget<Image>(image);
    expect(widget.image, isA<AssetImage>());
    expect((widget.image as AssetImage).assetName, 'assets/logo.png');
    expect(widget.width, 40);
    expect(widget.height, 40);
  });

  testWidgets('BrandMark honours an explicit size', (WidgetTester tester) async {
    await tester.pumpWidget(
      localizedApp(
        home: const Scaffold(body: Center(child: BrandMark(size: 64))),
      ),
    );
    await tester.pump();

    final Image widget = tester.widget<Image>(find.byType(Image));
    expect(widget.width, 64);
    expect(widget.height, 64);
  });

  test('assets/logo.png ships in the bundle and is a PNG', () async {
    final ByteData data = await rootBundle.load(BrandMark.assetPath);
    expect(data.lengthInBytes, greaterThan(1024));
    // PNG magic: 89 50 4E 47 0D 0A 1A 0A
    expect(
      data.buffer.asUint8List(data.offsetInBytes, 8),
      <int>[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A],
    );
  });
}
