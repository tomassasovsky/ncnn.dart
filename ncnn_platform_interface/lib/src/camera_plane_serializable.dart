import 'package:camera/camera.dart';

/// Serializes a [CameraImage] to a JSON-encodable map.
Map<String, dynamic> serializeCameraImage(CameraImage image) {
  return <String, dynamic>{
    'width': image.width,
    'height': image.height,
    'format': image.format.raw,
    'yPlane': serializeCameraPlane(image.planes[0]),
    'uPlane': serializeCameraPlane(image.planes[1]),
    'vPlane': serializeCameraPlane(image.planes[2]),
  };
}

/// Serializes a [Plane] to a JSON-encodable map.
Map<String, dynamic> serializeCameraPlane(Plane plane) {
  return <String, dynamic>{
    'width': plane.width,
    'height': plane.height,
    'bytesPerPixel': plane.bytesPerPixel,
    'bytesPerRow': plane.bytesPerRow,
    'bytes': plane.bytes,
  };
}
