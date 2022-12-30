// Copyright (c) 2022, SportsVisio, Inc.
// https://sportsvisio.com/
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

package com.sportsvisio;

import android.content.res.AssetManager;
import android.graphics.Bitmap;

public class YOLOv5 {
    static {
        System.loadLibrary("yolov5");
    }

    public static native void init(AssetManager assetManager, String paramFilePath, String binFilePath, boolean useGPU);

    public static native Box[] detect(Bitmap bitmap, double threshold, double nms_threshold);

    public static native void initCustomLayer(AssetManager assetManager, String paramFilePath, String binFilePath, boolean useGPU);

    public static native Box[] detectCustomLayer(Bitmap bitmap, double threshold, double nms_threshold);
}
