// Copyright (c) 2022, SportsVisio, Inc.
// https://sportsvisio.com/
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncnn_platform_interface/src/method_channel_ncnn.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const kPlatformName = 'platformName';

  group('$MethodChannelNcnn', () {
    late MethodChannelNcnn methodChannelNcnn;
    final log = <MethodCall>[];

    setUp(() async {
      methodChannelNcnn = MethodChannelNcnn()
        ..methodChannel.setMockMethodCallHandler((MethodCall methodCall) async {
          log.add(methodCall);
          switch (methodCall.method) {
            case 'getPlatformName':
              return kPlatformName;
            default:
              return null;
          }
        });
    });

    tearDown(log.clear);

    test('getPlatformName', () async {
      final platformName = await methodChannelNcnn.getPlatformName();
      expect(
        log,
        <Matcher>[isMethodCall('getPlatformName', arguments: null)],
      );
      expect(platformName, equals(kPlatformName));
    });
  });
}
