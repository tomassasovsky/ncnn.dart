package com.sportsvisio;

public enum ModelType {
    YOLOv5(true, YOLOv5.class),
    YOLOv4(true, YOLOv4.class),
    MobileNetV2YOLOv3Nano(true, YOLOv4.class),
    YOLOFastestXL(true, YOLOv4.class),
    SimplePose(false, SimplePose.class),
    Yolact(false, Yolact.class),
    Enet(false, ENet.class),
    YOLOFaceLandmark(false, FaceLandmark.class),
    DBFace(true, DBFace.class),
    MobileNetV2FCN(false, MbnFCN.class),
    MobileNetV3Seg(false, MbnSeg.class),
    NanoDet(true, NanoDet.class),
    LightOpenPose(false, LightOpenPose.class);

    final boolean allowsThreshold;
    final Class<?> modelClass;

    ModelType(boolean allowsThreshold, Class<?> modelClass) {
        this.allowsThreshold = allowsThreshold;
        this.modelClass = modelClass;
    }
}
