// Copyright (c) 2022, SportsVisio, Inc.
// https://sportsvisio.com/
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ncnn/ncnn.dart';
import 'package:ncnn_example/custom_painter_box.dart';

class ResultPage extends StatelessWidget {
  const ResultPage(
    this.results, {
    super.key,
  });

  final List<DetectionResult> results;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final entry = results.elementAt(index);

          final image = entry.decodedImage;

          final imageWidth = image.width.toDouble();
          final screenWidth = MediaQuery.of(context).size.width;
          final width = min(imageWidth, screenWidth);

          // percentual height of the screen to be used for the image
          final height = width * image.height / image.width;

          return SizedBox(
            width: width,
            height: height,
            child: FittedBox(
              fit: BoxFit.cover,
              child: Stack(
                children: [
                  Image.memory(image.getBytes()),
                  CustomPaint(
                    size: Size(width, height),
                    painter: DetectionResultsPainter(entry),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
