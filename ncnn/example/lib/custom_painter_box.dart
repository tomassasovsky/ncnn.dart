// Copyright (c) 2022, SportsVisio, Inc.
// https://sportsvisio.com/
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:ncnn/ncnn.dart';
import 'package:ncnn_example/labels.dart';

class DetectionResultsPainter extends CustomPainter {
  const DetectionResultsPainter({
    required this.boxes,
    this.image,
  });

  final List<Box> boxes;
  final ui.Image? image;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (image != null) {
      canvas.drawImage(image!, Offset.zero, Paint());
    }

    for (final box in boxes) {
      canvas.drawRect(
        box.rect,
        paint..color = box.color,
      );

      final label = box.getLabel(labels);
      final score = (box.score * 100).toStringAsFixed(2);

      TextPainter(
        text: TextSpan(
          text: '$label $score%',
          style: TextStyle(
            color: box.color,
            fontSize: 20,
          ),
        ),
        textDirection: TextDirection.ltr,
      )
        ..layout()
        ..paint(
          canvas,
          box.rect.topLeft,
        );
    }
  }

  @override
  bool shouldRepaint(DetectionResultsPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(DetectionResultsPainter oldDelegate) => false;
}
