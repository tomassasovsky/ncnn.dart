// Copyright (c) 2022, SportsVisio, Inc.
// https://sportsvisio.com/
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:ncnn/ncnn.dart';
import 'package:ncnn_example/custom_painter_box.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({
    required this.boxes,
    required this.image,
    super.key,
  });

  final List<Box> boxes;
  final ui.Image image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scale = min(
            constraints.maxWidth / image.width,
            constraints.maxHeight / image.height,
          );

          return Transform.scale(
            scale: scale,
            child: CustomPaint(
              painter: DetectionResultsPainter(
                boxes: boxes,
                image: image,
              ),
            ),
          );
        },
      ),
    );
  }
}
