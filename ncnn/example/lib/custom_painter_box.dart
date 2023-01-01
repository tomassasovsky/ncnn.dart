// Copyright (c) 2022, SportsVisio, Inc.
// https://sportsvisio.com/
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter/material.dart';
import 'package:ncnn/ncnn.dart';
import 'package:ncnn_example/labels.dart';

class DetectionResultsPainter extends CustomPainter {
  const DetectionResultsPainter(this.result);

  final DetectionResult result;

  @override
  void paint(Canvas canvas, Size size) {
    final detectionTime =
        result.detectiontime.inMilliseconds.toStringAsFixed(2);
    final imageConversionTime =
        result.imageConversionTime.inMilliseconds.toStringAsFixed(2);

    final detectionTimePainter = TextPainter(
      text: TextSpan(
        text: 'Detection Time: $detectionTime ms',
        style: TextStyle(
          color: Colors.white,
          fontSize: size.width / 8,
        ),
      ),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, Offset.zero);

    TextPainter(
      text: TextSpan(
        text: 'Image Conversion Time: $imageConversionTime ms',
        style: TextStyle(
          color: Colors.white,
          fontSize: size.width / 8,
        ),
      ),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(
        canvas,
        Offset(0, detectionTimePainter.height),
      );

    final boxes = result.boxes;

    if (boxes == null) {
      return;
    }

    for (final box in boxes) {
      final paint = Paint()
        ..color = box.color
        ..strokeWidth = size.width / 60
        ..style = PaintingStyle.stroke;

      canvas.drawRect(
        box.rect,
        paint,
      );

      final label = box.getLabel(labels);
      final score = (box.score * 100).toStringAsFixed(2);

      TextPainter(
        text: TextSpan(
          text: '$label $score%',
          style: TextStyle(
            color: box.color,
            fontSize: size.width / 8,
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
  bool shouldRepaint(DetectionResultsPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(DetectionResultsPainter oldDelegate) => true;
}
