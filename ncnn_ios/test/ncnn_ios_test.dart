// Copyright (c) 2022, SportsVisio, Inc.
// https://sportsvisio.com/
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncnn_ios/ncnn_ios.dart';
import 'package:ncnn_platform_interface/ncnn_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NcnnIOS', () {
    const kPlatformName = 'iOS';
    late NcnnIOS ncnn;
    late List<MethodCall> log;

    setUp(() async {
      ncnn = NcnnIOS();

      log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
          .setMockMethodCallHandler(ncnn.methodChannel, (methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'getPlatformName':
            return kPlatformName;
          default:
            return null;
        }
      });
    });

    test('can be registered', () {
      NcnnIOS.registerWith();
      expect(NcnnPlatform.instance, isA<NcnnIOS>());
    });

    test('getPlatformName returns correct name', () async {
      final name = await ncnn.getPlatformName();
      expect(
        log,
        <Matcher>[isMethodCall('getPlatformName', arguments: null)],
      );
      expect(name, equals(kPlatformName));
    });
  });
}
