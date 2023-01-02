// Copyright (c) 2022, SportsVisio, Inc.
// https://sportsvisio.com/
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter/foundation.dart';
import 'package:ncnn_platform_interface/ncnn_platform_interface.dart';
import 'package:ncnn_platform_interface/src/method_channel_ncnn.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

export 'src/box.dart';
export 'src/detection_result.dart';
export 'src/model_types.dart';

/// The interface that implementations of ncnn must implement.
///
/// Platform implementations should extend this class
/// rather than implement it as `Ncnn`.
/// Extending this class (using `extends`) ensures that the subclass will get
/// the default implementation, while platform implementations that `implements`
/// this interface will be broken by newly added [NcnnPlatform] methods.
abstract class NcnnPlatform extends PlatformInterface {
  /// Constructs a NcnnPlatform.
  NcnnPlatform() : super(token: _token);

  static final Object _token = Object();

  static NcnnPlatform _instance = MethodChannelNcnn();

  /// The default instance of [NcnnPlatform] to use.
  ///
  /// Defaults to [MethodChannelNcnn].
  static NcnnPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [NcnnPlatform] when they register themselves.
  static set instance(NcnnPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Return the current platform name.
  Future<String?> getPlatformName();

  /// Initializes a model.
  Future<void> initialize({
    required String binFile,
    required String paramFile,
    ModelType modelType,
    bool useGPU,
  });

  /// Detects an image using an initialized model.
  Future<DetectionResult> detect({
    required Uint8List imageData,
    required ModelType modelType,
    double threshold,
    double nmsThreshold,
  });
}
