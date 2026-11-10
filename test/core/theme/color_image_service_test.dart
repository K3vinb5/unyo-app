// External dependencies
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

// Internal dependencies
import 'package:unyo/core/theme/color_image_service.dart';

/// An [ImageProvider] that always resolves to the same already-decoded image,
/// so the palette can be computed without any network or asset access.
class _FixedImageProvider extends ImageProvider<_FixedImageProvider> {
  _FixedImageProvider(this.image);

  final ui.Image image;

  @override
  Future<_FixedImageProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<_FixedImageProvider>(this);

  @override
  ImageStreamCompleter loadImage(
    _FixedImageProvider key,
    ImageDecoderCallback decode,
  ) => OneFrameImageStreamCompleter(
    SynchronousFuture<ImageInfo>(ImageInfo(image: image)),
  );
}

Future<ui.Image> _decodeTransparentPixel() {
  final Completer<ui.Image> completer = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    Uint8List.fromList(<int>[0, 0, 0, 0]),
    1,
    1,
    ui.PixelFormat.rgba8888,
    completer.complete,
  );
  return completer.future;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'getColorsFromPalleteGenerator returns no colours for an image with an '
    'empty palette instead of padding forever',
    () async {
      final ui.Image image = await _decodeTransparentPixel();
      addTearDown(image.dispose);

      // A fully transparent image yields zero palette entries; the old padding
      // loop (`while (sortedColors.length < 20) addAll([])`) never terminated.
      final List<Color> colors = await ColorImageService()
          .getColorsFromPalleteGenerator(_FixedImageProvider(image))
          .timeout(const Duration(seconds: 5));

      expect(colors, isEmpty);
    },
  );
}
