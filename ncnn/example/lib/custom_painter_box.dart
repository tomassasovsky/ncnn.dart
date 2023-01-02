// Copyright (c) 2022, SportsVisio, Inc.
// https://sportsvisio.com/
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ncnn/ncnn.dart';
import 'package:ncnn_example/labels.dart';

class DetectionResultsPainter extends CustomPainter {
  const DetectionResultsPainter(this.result);

  final DetectionResult result;

  @override
  void paint(Canvas canvas, Size size) {
    // final scale = size.width / result.imageWidth;
    // canvas.scale(scale);

    final detectionTime =
        result.detectiontime.inMilliseconds.toStringAsFixed(2);
    final imageConversionTime =
        result.imageConversionTime.inMilliseconds.toStringAsFixed(2);

    final detectionTimeTextSize =
        drawText(canvas, 'Detection Time: $detectionTime ms', 0, 0);
    final imageConversionTimeTextSize = drawText(
      canvas,
      'Image Conversion Time: $imageConversionTime ms',
      0,
      detectionTimeTextSize.height,
    );
    final fullDetectionTimeTextSize = drawText(
      canvas,
      'Full Detection Time ${result.fullDetectionTime.inMilliseconds} ms',
      0,
      detectionTimeTextSize.height + imageConversionTimeTextSize.height,
    );
    final lostTime = result.fullDetectionTime -
        result.detectiontime -
        result.imageConversionTime;
    drawText(
      canvas,
      'Lost Time: ${lostTime.inMilliseconds} ms',
      0,
      detectionTimeTextSize.height +
          imageConversionTimeTextSize.height +
          fullDetectionTimeTextSize.height,
    );

    final boxes = result.boxes;

    if (boxes == null) {
      return;
    }

    for (final box in boxes) {
      final paint = Paint()
        ..color = box.color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      // limit the rect to the size
      final rect = box.rect;
      final left = math.max<double>(0, rect.left);
      final top = math.max<double>(0, rect.top);
      final right = math.min<double>(
        rect.right,
        result.imageWidth.toDouble(),
      );
      final bottom = math.min<double>(
        rect.bottom,
        result.imageHeight.toDouble(),
      );
      final limitedRect = Rect.fromLTRB(left, top, right, bottom);

      canvas.drawRect(
        limitedRect,
        paint,
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

  Size drawText(
    Canvas canvas,
    String text,
    double x,
    double y,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, Offset(x, y));

    return textPainter.size;
  }

  @override
  bool shouldRepaint(DetectionResultsPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(DetectionResultsPainter oldDelegate) => true;
}
