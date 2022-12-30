package com.sportsvisio;

import android.content.res.AssetManager;
import android.graphics.Bitmap;

class Yolact {
    static {
        System.loadLibrary("yolov5");
    }

    public static native void init(AssetManager assetManager, String paramFilePath, String binFilePath, boolean useGPU);
    public static native YolactMask[] detect(Bitmap bitmap);
}
