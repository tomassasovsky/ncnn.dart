// Copyright (c) 2022, SportsVisio, Inc.
// https://sportsvisio.com/
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

// ignore_for_file: constant_identifier_names, public_member_api_docs

/// The model types supported by the plugin.
enum ModelType {
  YOLOv5(usesThreshold: true),
  YOLOv4(usesThreshold: true),
  MobileNetV2YOLOv3Nano(usesThreshold: true),
  YOLOFastestXL(usesThreshold: true),
  SimplePose(usesThreshold: false),
  Yolact(usesThreshold: false),
  Enet(usesThreshold: false),
  YOLOFaceLandmark(usesThreshold: false),
  DBFace(usesThreshold: true),
  MobileNetV2FCN(usesThreshold: false),
  MobileNetV3Seg(usesThreshold: false),
  NanoDet(usesThreshold: true),
  LightOpenPose(usesThreshold: false);

  const ModelType({required this.usesThreshold});

  final bool usesThreshold;
}
