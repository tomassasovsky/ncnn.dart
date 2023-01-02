// Copyright (c) 2022, SportsVisio, Inc.
// https://sportsvisio.com/
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:ncnn/ncnn.dart';
import 'package:ncnn_example/custom_painter_box.dart';
import 'package:ncnn_example/labels.dart';
import 'package:ncnn_example/main.dart';
import 'package:ncnn_example/utils/camera_encoding.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ValueNotifier<bool> _cameraInitialized = ValueNotifier(false);
  final ValueNotifier<Duration> _detectionSpeed = ValueNotifier(Duration.zero);
  final ValueNotifier<DetectionResult?> _detectionResult = ValueNotifier(null);
  final ValueNotifier<CameraDescription> _selectedCamera =
      ValueNotifier(cameras.first);
  late CameraController _cameraController = CameraController(
    _selectedCamera.value,
    ResolutionPreset.medium,
    enableAudio: false,
  );
  bool _isDetecting = false;
  final stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _cameraInitialized.addListener(() {
      if (_cameraInitialized.value) {
        _cameraController.startImageStream(_detect);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _cameraController.initialize();
      await _cameraController.prepareForVideoRecording();
      _cameraInitialized.value = true;
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _cameraInitialized.dispose();
    _detectionResult.dispose();
    _selectedCamera.dispose();
    super.dispose();
  }

  Future<void> _detect(CameraImage image) async {
    if (_isDetecting) return;
    _isDetecting = true;
    stopwatch
      ..reset()
      ..start();

    final imageData = await cameraImageToUint8List(image);

    if (imageData == null) {
      log('Failed to convert image to uint8list');
      return;
    }

    final result = await NcnnPlatform.instance.detect(
      imageData: imageData,
      modelType: ModelType.YOLOFastestXL,
      threshold: 0.5,
      nmsThreshold: 0.5,
    );

    _detectionResult.value = result;
    log('Detection: ${result.toString(labels)}');
    stopwatch.stop();
    _detectionSpeed.value = stopwatch.elapsed;
    _isDetecting = false;
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
                  _cameraInitialized.value = false;
                  _cameraController = CameraController(
                    _selectedCamera.value,
                    ResolutionPreset.max,
                    enableAudio: false,
                  );

                  await _cameraController.initialize();
                  if (!mounted) return;
                  _cameraInitialized.value = true;
                },
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _cameraInitialized,
        builder: (context, cameraInitialized, child) {
          if (cameraInitialized) {
            final imageWidth = _cameraController.value.previewSize!.width;
            final imageHeight = _cameraController.value.previewSize!.height;
            final screenWidth = MediaQuery.of(context).size.width;

            // percentual width of the screen to be used for the image
            final width = math.min(imageWidth, screenWidth);

            // percentual height of the screen to be used for the image
            final height = width * imageHeight / imageWidth;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: width,
                  maxHeight: height,
                ),
                child: CameraPreview(
                  _cameraController,
                  child: ValueListenableBuilder<DetectionResult?>(
                    valueListenable: _detectionResult,
                    builder: (context, detection, child) {
                      if (detection == null) {
                        return const SizedBox();
                      }

                      return CustomPaint(
                        size: Size(width, height),
                        willChange: true,
                        painter: DetectionResultsPainter(detection),
                      );
                    },
                  ),
                ),
              ),
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
