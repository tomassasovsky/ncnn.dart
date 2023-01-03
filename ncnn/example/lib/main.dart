// Copyright (c) 2022, SportsVisio, Inc.
// https://sportsvisio.com/
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:convert';
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ncnn/ncnn.dart';
import 'package:ncnn_example/camera_page.dart';
import 'package:ncnn_example/result_page.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _platformName;
  List<DetectionResult> results = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ncnn Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_platformName == null)
              const SizedBox.shrink()
            else
              Text(
                'Platform Name: $_platformName',
                style: Theme.of(context).textTheme.headline5,
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                try {
                  const name = 'model';
                  await NcnnPlatform.instance.initialize(
                    binFile: 'assets/$name.bin',
                    paramFile: 'assets/$name.param',
                    modelType: ModelType.YOLOFastestXL,
                  );
                } catch (error, stacktrace) {
                  log('$error', stackTrace: stacktrace);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).primaryColor,
                      content: Text('$error'),
                    ),
                  );
                }
              },
              child: const Text('Initialize Model (CPU)'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  const name = 'yolo-fastest-opt';
                  await NcnnPlatform.instance.initialize(
                    binFile: 'assets/$name.bin',
                    paramFile: 'assets/$name.param',
                    modelType: ModelType.YOLOFastestXL,
                    useGPU: true,
                  );
                } catch (error, stacktrace) {
                  log('$error', stackTrace: stacktrace);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).primaryColor,
                      content: Text('$error'),
                    ),
                  );
                }
              },
              child: const Text('Initialize Model (GPU)'),
            ),
            ElevatedButton(
              onPressed: () async {
                results = <DetectionResult>[];

                try {
                  final allAssets = await rootBundle
                      .loadString('AssetManifest.json')
                      .then(jsonDecode) as Map<String, dynamic>;

                  final pngAssets = allAssets.entries.where(
                    (element) => element.key.endsWith('.png'),
                  );

                  for (final asset in pngAssets) {
                    final byteData = await rootBundle.load(asset.key);
                    final imageBytes = byteData.buffer.asUint8List();

                    final result = await NcnnPlatform.instance.detect(
                      imageData: imageBytes,
                      modelType: ModelType.YOLOFastestXL,
                    );

                    results.add(result);
                  }

                  if (!mounted) return;

                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => ResultPage(results),
                    ),
                  );
                } catch (error, stacktrace) {
                  log('$error', stackTrace: stacktrace);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).primaryColor,
                      content: Text('$error'),
                    ),
                  );
                }
              },
              child: const Text('Run inference on Asset Image'),
            ),
            ElevatedButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const CameraPage(),
                  ),
                );
              },
              child: const Text('Run inference on Camera Stream'),
            ),
          ],
        ),
      ),
    );
  }
}
