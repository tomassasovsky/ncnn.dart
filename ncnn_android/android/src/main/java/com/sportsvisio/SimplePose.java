package com.sportsvisio;

import android.content.res.AssetManager;
import android.graphics.Bitmap;

public class SimplePose {
    static {
        System.loadLibrary("yolov5");
    }

    public static native void init(AssetManager assetManager, String paramFilePath, String binFilePath, boolean useGPU);
    public static native KeyPoint[] detect(Bitmap bitmap);
}
