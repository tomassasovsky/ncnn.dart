// Copyright (c) 2022, SportsVisio, Inc.
// https://sportsvisio.com/
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

package com.sportsvisio;

public enum ModelType {
    YOLOv5(true),
    YOLOv4(true),
    MobileNetV2YOLOv3Nano(true),
    YOLOFastestXL(true),
    SimplePose(false),
    Yolact(false),
    Enet(false),
    YOLOFaceLandmark(false),
    DBFace(true),
    MobileNetV2FCN(false),
    MobileNetV3Seg(false),
    NanoDet(true),
    LightOpenPose(false);

    final boolean allowsThreshold;

    ModelType(boolean allowsThreshold) {
        this.allowsThreshold = allowsThreshold;
    }
}
