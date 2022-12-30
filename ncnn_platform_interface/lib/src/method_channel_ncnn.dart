// Copyright (c) 2022, SportsVisio, Inc.
// https://sportsvisio.com/
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:ncnn_platform_interface/ncnn_platform_interface.dart';

/// An implementation of [NcnnPlatform] that uses method channels.
class MethodChannelNcnn extends NcnnPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ncnn');

  @override
  Future<String?> getPlatformName() {
    return methodChannel.invokeMethod<String>('getPlatformName');
  }

  @override
  Future<void> initialize({
    required String binFile,
    required String paramFile,
    ModelType modelType = ModelType.YOLOv4,
    bool useGPU = false,
  }) {
    return methodChannel.invokeMethod<String>(
      'init',
      <String, dynamic>{
        'useGPU': useGPU.toString(),
        'modelType': modelType.name,
        'paramFile': paramFile,
        'binFile': binFile,
      },
    );
  }

  /// Detects an image using an initialized model.

  @override
  Future<List<Box>?> detect({
    required Uint8List imageData,
    Format format = Format.rgba,
    required ModelType modelType,
    double threshold = 0.4,
    double nmsThreshold = 0.6,
  }) async {
    final decodedImage = await decodeImageFromList(imageData);
    final image = Image.fromBytes(
      decodedImage.width,
      decodedImage.height,
      imageData,
      format: format,
    );

    final result = await methodChannel.invokeListMethod<Map<dynamic, dynamic>>(
      'detect',
      <String, dynamic>{
        'imageData': image.getBytes(),
        'imageWidth': image.width,
        'imageHeight': image.height,
        'modelType': modelType.name,
        'threshold': threshold,
        'nmsThreshold': nmsThreshold,
      },
    );

    return result?.map((e) => Box.fromMap(e.cast())).toList();
  }
}
