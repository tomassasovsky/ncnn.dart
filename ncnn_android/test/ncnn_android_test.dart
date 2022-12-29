// Copyright (c) 2022, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncnn_android/ncnn_android.dart';
import 'package:ncnn_platform_interface/ncnn_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NcnnAndroid', () {
    const kPlatformName = 'Android';
    late NcnnAndroid ncnn;
    late List<MethodCall> log;

    setUp(() async {
      ncnn = NcnnAndroid();

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
      NcnnAndroid.registerWith();
      expect(NcnnPlatform.instance, isA<NcnnAndroid>());
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
