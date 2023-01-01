// Copyright (c) 2022, SportsVisio, Inc.
// https://sportsvisio.com/
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:ncnn_platform_interface/ncnn_platform_interface.dart';

/// A class that represents the result of a detection.
class DetectionResult {
  /// Creates a new [DetectionResult] item.
  const DetectionResult(
    this.boxes,
    this.detectiontime,
    this.imageConversionTime,
    this.decodedImage,
  );

  /// The list of boxes detected.
  final List<Box>? boxes;

  /// The time of the detection.
  final Duration detectiontime;

  /// The time of the image conversion.
  final Duration imageConversionTime;

  /// The decoded image, from package:image.
  final Image decodedImage;

  @override
  String toString() {
    return 'DetectionResult{boxes: $boxes, detectiontime: $detectiontime '
        'imageConversionTime: $imageConversionTime}';
  }
}
