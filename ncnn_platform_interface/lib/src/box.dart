// Copyright (c) 2022, SportsVisio, Inc.
// https://sportsvisio.com/
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:math';
import 'dart:ui';

/// The result of a model inference.
class Box {
  /// Creates a new [Box] item.
  const Box({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    required this.labelId,
    required this.score,
  });

  /// Creates a new [Box] item from a map (decoded JSON).
  factory Box.fromMap(Map<String, dynamic> map) {
    return Box(
      left: map['x0'] as double,
      top: map['y0'] as double,
      right: map['x1'] as double,
      bottom: map['y1'] as double,
      labelId: map['labelId'] as int,
      score: map['score'] as double,
    );
  }

  /// The Coordinates of the box.
  final double left, top, right, bottom;

  /// The label of the box.
  final int labelId;

  /// The score of the inference.
  final double score;

  /// A drawable [Rect] for the box.
  Rect get rect => Rect.fromLTRB(left, top, right, bottom);

  /// A random color for the box, can be used in the UI.
  Color get color {
    final random = Random(labelId);
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  /// The label of the box.
  String getLabel(List<String> labels) => labels[labelId];

  @override
  String toString() {
    return 'Box{left: $left, top: $top, right: $right, bottom: $bottom, '
        'labelId: $labelId, score: $score}';
  }
}
