// Copyright (c) 2022, SportsVisio, Inc.
// https://sportsvisio.com/
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter/foundation.dart';
import 'package:ncnn_platform_interface/ncnn_platform_interface.dart';

/// A class that represents the result of a detection.
class DetectionResult {
  /// Creates a new [DetectionResult] item.
  DetectionResult.fromBytes(
    this.boxes,
    this.detectiontime,
    this.imageConversionTime,
    this.fullDetectionTime,
    this.bytes,
    this.imageHeight,
    this.imageWidth,
  );

  /// Creates a new [DetectionResult] item.
  factory DetectionResult.fromMap(
    Map<String, dynamic> result, {
    required Uint8List bytes,
    required Duration fullDetectionTime,
  }) {
    final boxList =
        (result['boxes'] as List<dynamic>).cast<Map<dynamic, dynamic>>();
    final boxes = boxList.map((box) => Box.fromMap(box.cast())).toList();

    return DetectionResult.fromBytes(
      boxes,
      Duration(milliseconds: result['time'] as int),
      Duration(milliseconds: result['imageConversionTime'] as int),
      fullDetectionTime,
      bytes,
      result['imageHeight'] as int,
      result['imageWidth'] as int,
    );
  }

  /// The list of boxes detected.
  final List<Box>? boxes;

  /// The time of the detection.
  final Duration detectiontime;

  /// The time of the image conversion.
  final Duration imageConversionTime;

  /// The bytes of the image.
  final Uint8List bytes;

  /// The height of the image.
  final int imageHeight;

  /// The width of the image.
  final int imageWidth;

  /// The full detection time.
  /// This is the sum of the detection time and the image conversion time, plus
  /// the time it takes for Flutter to call the native code and it to respond.
  final Duration fullDetectionTime;

  @override
  String toString([List<String>? labels, bool includeBytes = false]) {
    return 'DetectionResult{boxes: '
        '${labels == null ? '' : boxes?.toStringWithLabels(labels)}, '
        'detectiontime: $detectiontime, imageConversionTime: '
        '$imageConversionTime,${includeBytes ? ' bytes: $bytes,' : ''} '
        'imageHeight: $imageHeight, imageWidth: $imageWidth}';
  }
}
