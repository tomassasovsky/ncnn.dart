// Copyright (c) 2022, SportsVisio, Inc.
// https://sportsvisio.com/
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img_lib;
import 'package:ncnn_platform_interface/ncnn_platform_interface.dart';

class NcnnMock extends NcnnPlatform {
  static const mockPlatformName = 'Mock';

  @override
  Future<String?> getPlatformName() async => mockPlatformName;

  @override
  Future<void> initialize({
    required String binFile,
    required String paramFile,
    ModelType modelType = ModelType.YOLOv4,
    bool useGPU = false,
  }) async {}

  @override
  Future<DetectionResult> detect({
    required Uint8List imageData,
    img_lib.Format format = img_lib.Format.bgr,
    required ModelType modelType,
    double threshold = 0.4,
    double nmsThreshold = 0.6,
  }) async =>
      DetectionResult(
        [],
        Duration.zero,
        Duration.zero,
        img_lib.Image(0, 0),
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('NcnnPlatformInterface', () {
    late NcnnPlatform ncnnPlatform;

    setUp(() {
      ncnnPlatform = NcnnMock();
      NcnnPlatform.instance = ncnnPlatform;
    });

    group('getPlatformName', () {
      test('returns correct name', () async {
        expect(
          await NcnnPlatform.instance.getPlatformName(),
          equals(NcnnMock.mockPlatformName),
        );
      });
    });
  });
}
