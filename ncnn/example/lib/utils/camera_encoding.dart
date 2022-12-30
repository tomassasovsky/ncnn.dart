import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img_lib;

Future<Uint8List?> cameraImageToUint8List(CameraImage image) async {
  try {
    img_lib.Image img;
    if (image.format.group == ImageFormatGroup.yuv420) {
      img = _convertYUV420(image);
    } else if (image.format.group == ImageFormatGroup.bgra8888) {
      img = _convertBGRA8888(image);
    } else {
      throw Exception('Unknown image format');
    }

    final pngEncoder = img_lib.PngEncoder();

    final png = pngEncoder.encodeImage(img);
    return Uint8List.fromList(png);
  } catch (e) {
    debugPrint('>>>>>>>>>>>> ERROR:$e');
  }

  return null;
}

// CameraImage BGRA8888 -> PNG
img_lib.Image _convertBGRA8888(CameraImage image) {
  return img_lib.Image.fromBytes(
    image.width,
    image.height,
    image.planes[0].bytes,
    format: img_lib.Format.bgra,
  );
}

// CameraImage YUV420_888 -> PNG -> Image (compresion:0, filter: none)
img_lib.Image _convertYUV420(CameraImage image) {
  final img = img_lib.Image(image.width, image.height); // Create Image buffer
  final plane = image.planes[0];
  const shift = 0xFF << 24;

  // Fill image buffer with plane[0] from YUV420_888
  for (var x = 0; x < image.width; x++) {
    for (var planeOffset = 0;
        planeOffset < image.height * image.width;
        planeOffset += image.width) {
      final pixelColor = plane.bytes[planeOffset + x];
      // color: 0x FF  FF  FF  FF
      //           A   B   G   R
      // Calculate pixel color
      final newVal =
          shift | (pixelColor << 16) | (pixelColor << 8) | pixelColor;
      img.data[planeOffset + x] = newVal;
    }
  }

  return img;
}
