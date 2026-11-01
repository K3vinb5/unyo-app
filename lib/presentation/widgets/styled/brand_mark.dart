//External dependencies
import 'package:material_ui/material_ui.dart';

/// The Unyo brand mark (the glossy 3D octopus).
///
/// `assets/logo.png` is generated from `packaging/icons/source/unyo_1024.png`
/// by `packaging/icons/generate.py` (WP #84), so the in-app logo, the Linux
/// packaging icons and the GTK window icon all come from one master.
///
/// The export is 256px. Size it with [size] rather than `Image.asset`'s
/// `scale:`, which would have to track the export's pixel dimensions.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 40});

  /// Rendered edge length in logical pixels (the pre-#84 login logo occupied
  /// 40x40: a 100px export drawn at `scale: 2.5`).
  final double size;

  static const String assetPath = 'assets/logo.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
    );
  }
}
