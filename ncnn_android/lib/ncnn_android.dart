// Copyright (c) 2022, SportsVisio, Inc.
// https://sportsvisio.com/
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:ncnn_platform_interface/ncnn_platform_interface.dart';

/// The Android implementation of [NcnnPlatform].
class NcnnAndroid extends NcnnPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ncnn_android');

  /// Registers this class as the default instance of [NcnnPlatform]
  static void registerWith() {
    NcnnPlatform.instance = NcnnAndroid();
  }

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
