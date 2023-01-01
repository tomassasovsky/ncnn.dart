// Copyright (c) 2022, SportsVisio, Inc.
// https://sportsvisio.com/
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:ncnn/ncnn.dart';
import 'package:ncnn_example/custom_painter_box.dart';
import 'package:ncnn_example/main.dart';
import 'package:ncnn_example/utils/camera_encoding.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ValueNotifier<bool> _isCameraReady = ValueNotifier(false);
  final ValueNotifier<Duration> _detectionSpeed = ValueNotifier(Duration.zero);
  final ValueNotifier<DetectionResult?> _detectionResult = ValueNotifier(null);
  final ValueNotifier<CameraDescription> _selectedCamera =
      ValueNotifier(cameras.first);
  late CameraController _cameraController = CameraController(
    _selectedCamera.value,
    ResolutionPreset.max,
    enableAudio: false,
  );
  bool _isDetecting = false;
  final StreamController<CameraImage> _streamController =
      StreamController<CameraImage>();
  final stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _isCameraReady.addListener(() {
      if (_isCameraReady.value) {
        _cameraController.startImageStream((image) {
          _streamController.add(image);

          if (!_isDetecting) {
            _isDetecting = true;
            stopwatch
              ..reset()
              ..start();
            _detect(image);
            stopwatch.stop();
            _detectionSpeed.value = stopwatch.elapsed;
            _isDetecting = false;
          }
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _cameraController.initialize();
      _isCameraReady.value = true;
    });
  }

  @override
  void dispose() {
    _streamController.close();
    _cameraController.dispose();
    _isCameraReady.dispose();
    _detectionResult.dispose();
    _selectedCamera.dispose();
    super.dispose();
  }

  Future<void> _detect(CameraImage image) async {
    final imageData = await cameraImageToUint8List(image);

    if (imageData == null) {
      return;
    }

    final result = await NcnnPlatform.instance.detect(
      imageData: imageData,
      modelType: ModelType.YOLOv5,
      threshold: 0.5,
      nmsThreshold: 0.5,
    );

    _detectionResult.value = result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
        actions: [
          ValueListenableBuilder<CameraDescription>(
            valueListenable: _selectedCamera,
            builder: (context, value, child) {
              return IconButton(
                icon: const Icon(Icons.switch_camera),
                onPressed: () async {
                  await _cameraController.stopImageStream();
                  await _cameraController.dispose();
                  if (!mounted) return;

                  _selectedCamera.value =
                      value == cameras.first ? cameras.last : cameras.first;
                  _isCameraReady.value = false;
                  _cameraController = CameraController(
                    _selectedCamera.value,
                    ResolutionPreset.max,
                    enableAudio: false,
                  );

                  await _cameraController.initialize();
                  if (!mounted) return;
                  _isCameraReady.value = true;
                },
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _isCameraReady,
        builder: (context, value, child) {
          if (value) {
            return Stack(
              children: [
                CameraPreview(_cameraController),
                ValueListenableBuilder<DetectionResult?>(
                  valueListenable: _detectionResult,
                  builder: (context, value, child) {
                    if (value == null) {
                      return const SizedBox();
                    }

                    return CustomPaint(
                      painter: DetectionResultsPainter(value),
                    );
                  },
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
