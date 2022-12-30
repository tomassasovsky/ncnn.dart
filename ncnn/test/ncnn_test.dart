// Copyright (c) 2022, SportsVisio, Inc.
// https://sportsvisio.com/
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ncnn/ncnn.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNcnnPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements NcnnPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Ncnn', () {
    late NcnnPlatform ncnnPlatform;

    setUp(() {
      ncnnPlatform = MockNcnnPlatform();
      NcnnPlatform.instance = ncnnPlatform;
    });

    group('getPlatformName', () {
      test('returns correct name when platform implementation exists',
          () async {
        const platformName = '__test_platform__';
        when(
          () => ncnnPlatform.getPlatformName(),
        ).thenAnswer((_) async => platformName);

        final actualPlatformName = await ncnnPlatform.getPlatformName();
        expect(actualPlatformName, equals(platformName));
      });

      test('throws exception when platform implementation is missing',
          () async {
        when(
          () => ncnnPlatform.getPlatformName(),
        ).thenAnswer((_) async => null);

        expect(ncnnPlatform.getPlatformName, throwsException);
      });
    });
  });
}
