package com.sportsvisio;

import android.content.res.AssetManager;
import android.graphics.Bitmap;

class DBFace {
    static {
        System.loadLibrary("yolov5");
    }

    public static native void init(AssetManager assetManager, String paramFilePath, String binFilePath, boolean useGPU);
    public static native KeyPoint[] detect(Bitmap bitmap, double threshold, double nms_threshold);
}
