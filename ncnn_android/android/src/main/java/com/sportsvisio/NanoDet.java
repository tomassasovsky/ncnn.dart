package com.sportsvisio;

import android.content.res.AssetManager;
import android.graphics.Bitmap;

public class NanoDet {
    static {
        System.loadLibrary("yolov5");
    }

    public static native void init(AssetManager assetManager, String paramFilePath, String binFilePath, boolean useGPU);
    public static native Box[] detect(Bitmap bitmap, double threshold, double nms_threshold);
}
