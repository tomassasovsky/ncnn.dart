// Copyright (c) 2022, SportsVisio, Inc.
// https://sportsvisio.com/
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:ncnn_platform_interface/ncnn_platform_interface.dart';

/// The iOS implementation of [NcnnPlatform].
class NcnnIOS extends NcnnPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ncnn_ios');

  /// Registers this class as the default instance of [NcnnPlatform]
  static void registerWith() {
    NcnnPlatform.instance = NcnnIOS();
  }

  @override
  Future<String?> getPlatformName() {
    return methodChannel.invokeMethod<String>('getPlatformName');
  }
}
