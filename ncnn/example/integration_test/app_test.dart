// Copyright (c) 2022, SportsVisio, Inc.
// https://sportsvisio.com/
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:ncnn_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E', () {
    testWidgets('getPlatformName', (tester) async {
      await app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Get Platform Name'));
      await tester.pumpAndSettle();
      final expected = expectedPlatformName();
      await tester.ensureVisible(find.text('Platform Name: $expected'));
    });
  });
}

String expectedPlatformName() {
  if (Platform.isAndroid) return 'Android';
  if (Platform.isIOS) return 'iOS';
  throw UnsupportedError('Unsupported platform ${Platform.operatingSystem}');
}
