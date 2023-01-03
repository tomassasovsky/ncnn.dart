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
  DetectionResultsPainter(
    this.result,
    this.currentFps,
    this.avgFps,
  );

  final DetectionResult result;
  final double currentFps;
  final double avgFps;
  double _textSize = 0;

  @override
  void paint(Canvas canvas, Size size) {
    // get the image size
    final imageSize =
        Size(result.imageWidth.toDouble(), result.imageHeight.toDouble());

    // get the adapted text size
    _textSize = getAdaptedSize(size, imageSize, 12);

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

    final adaptedWidth = getAdaptedSize(size, imageSize, imageSize.width);
    final adaptedHeight = getAdaptedSize(size, imageSize, imageSize.height);

    final adaptedSize = Size(adaptedWidth, adaptedHeight);

    final fpsTextSize = drawRightSideText(
      canvas,
      adaptedSize,
      'FPS: ${currentFps.toStringAsFixed(2)}',
      0,
      0,
    );

    drawRightSideText(
      canvas,
      adaptedSize,
      'Average FPS: ${avgFps.toStringAsFixed(2)}',
      0,
      fpsTextSize.height,
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
            fontSize: _textSize,
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
        style: TextStyle(
          color: Colors.white,
          fontSize: _textSize,
          backgroundColor: Colors.black.withOpacity(0.5),
        ),
      ),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, Offset(x, y));

    return textPainter.size;
  }

  Size drawRightSideText(
    Canvas canvas,
    Size size,
    String text,
    double x,
    double y,
  ) {
    final textPainter = TextPainter(
      textWidthBasis: TextWidthBasis.longestLine,
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: _textSize,
          backgroundColor: Colors.black.withOpacity(0.5),
        ),
      ),
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(result.imageWidth - textPainter.width, y),
    );

    return textPainter.size;
  }

  @override
  bool shouldRepaint(DetectionResultsPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(DetectionResultsPainter oldDelegate) => true;

  double getAdaptedSize(
    Size size,
    Size imageSize,
    double textSize,
  ) {
    final width = imageSize.width / size.width;
    final height = imageSize.height / size.height;

    final adaptedSize = math.max(width, height) * textSize;

    return adaptedSize;
  }
}
