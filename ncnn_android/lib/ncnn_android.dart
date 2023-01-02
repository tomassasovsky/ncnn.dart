// Copyright (c) 2022, SportsVisio, Inc.
// https://sportsvisio.com/
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter/foundation.dart';
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
  Future<DetectionResult> detect({
    required Uint8List imageData,
    required ModelType modelType,
    double threshold = 0.4,
    double nmsThreshold = 0.6,
  }) async {
    final stopwatch = Stopwatch()..start();

    final result = await methodChannel.invokeMapMethod<String, dynamic>(
      'detect',
      <String, dynamic>{
        'imageData': imageData,
        'modelType': modelType.name,
        'threshold': threshold,
        'nmsThreshold': nmsThreshold,
      },
    );

    stopwatch.stop();

    if (result == null) {
      throw Exception('Detection failed');
    }

    return DetectionResult.fromMap(
      result,
      bytes: imageData,
      fullDetectionTime: stopwatch.elapsed,
    );
  }
}
