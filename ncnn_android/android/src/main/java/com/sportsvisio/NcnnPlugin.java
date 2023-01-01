// Copyright (c) 2022, SportsVisio, Inc.
// https://sportsvisio.com/
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

package com.sportsvisio;

import android.content.Context;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Objects;

import io.flutter.FlutterInjector;
import io.flutter.Log;
import io.flutter.embedding.engine.loader.FlutterLoader;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class NcnnPlugin implements FlutterPlugin, MethodCallHandler {
    private MethodChannel channel;
    private Context context;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "ncnn_android");
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "init":
                String useGPUStr = call.argument("useGPU");
                assert useGPUStr != null : "useGPU is null";

                String modelTypeStr = call.argument("modelType");
                ModelType modelType = ModelType.valueOf(modelTypeStr);

                String paramFileAssetPath = call.argument("paramFile");
                String binFileAssetPath = call.argument("binFile");

                assert paramFileAssetPath != null : "paramFile is null";
                assert binFileAssetPath != null : "binFile is null";

                boolean useGPU = Boolean.getBoolean(useGPUStr);

                String paramFilePath = getFlutterAssetFilePath(paramFileAssetPath);
                String binFilePath = getFlutterAssetFilePath(binFileAssetPath);

                AssetManager mgr = context.getAssets();

                try {
                    init(modelType, mgr, paramFilePath, binFilePath, useGPU);
                } catch (Exception e) {
                    result.error(e.getClass().getName(), e.getMessage(), Arrays.toString(e.getStackTrace()));
                    return;
                }

                result.success(null);
                break;
            case "detect":
                byte[] image = Objects.requireNonNull(call.argument("imageData"), "imageData is null");

                // start timer
                long startTime = System.currentTimeMillis();
                Bitmap bitmap = BitmapFactory.decodeByteArray(image, 0, image.length);
                long endTime = System.currentTimeMillis();
                Log.i("decode byte array time (native)", (endTime - startTime) + "ms");
                if (bitmap == null) {
                    result.error("ObjectNullException", "Bitmap is null", null);
                    return;
                }

                modelTypeStr = call.argument("modelType");
                modelType = ModelType.valueOf(modelTypeStr);

                double threshold = Objects.requireNonNull(call.argument("threshold"), "threshold is null");
                double nmsThreshold = Objects.requireNonNull(call.argument("nmsThreshold"), "threshold is null");

                try {
                    startTime = System.currentTimeMillis();
                    Box[] boxes = detect(modelType, bitmap, (float) threshold, (float) nmsThreshold);
                    endTime = System.currentTimeMillis();

                    Log.i("detect time", (endTime - startTime) + "ms");

                    if (boxes == null) {
                        result.success(null);
                        return;
                    }

                    ArrayList<HashMap<String, Object>> jsonArray = new ArrayList<>();
                    for (Box box : boxes) {
                        jsonArray.add(box.toMap());
                    }

                    result.success(jsonArray);
                } catch (Exception e) {
                    result.error(e.getClass().getName(), e.getMessage(), Arrays.toString(e.getStackTrace()));
                    return;
                }
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    private String getFlutterAssetFilePath(String assetPath) {
        FlutterLoader loader = FlutterInjector.instance().flutterLoader();
        return loader.getLookupKeyForAsset(assetPath);
    }

    void init(ModelType modelType, AssetManager assetManager, String paramFilePath, String binFilePath, boolean useGPU) {
        switch (modelType) {
            case YOLOv5:
                YOLOv5.init(assetManager, paramFilePath, binFilePath, useGPU);
                break;
            case YOLOv4:
            case MobileNetV2YOLOv3Nano:
            case YOLOFastestXL:
                YOLOv4.init(assetManager, paramFilePath, binFilePath, useGPU);
                break;
            case SimplePose:
                SimplePose.init(assetManager, paramFilePath, binFilePath, useGPU);
                break;
            case Yolact:
                Yolact.init(assetManager, paramFilePath, binFilePath, useGPU);
                break;
            case Enet:
                ENet.init(assetManager, paramFilePath, binFilePath, useGPU);
                break;
            case YOLOFaceLandmark:
                FaceLandmark.init(assetManager, paramFilePath, binFilePath, useGPU);
                break;
            case DBFace:
                DBFace.init(assetManager, paramFilePath, binFilePath, useGPU);
                break;
            case MobileNetV2FCN:
                MbnFCN.init(assetManager, paramFilePath, binFilePath, useGPU);
                break;
            case MobileNetV3Seg:
                MbnSeg.init(assetManager, paramFilePath, binFilePath, useGPU);
                break;
            case NanoDet:
                NanoDet.init(assetManager, paramFilePath, binFilePath, useGPU);
                break;
            case LightOpenPose:
                LightOpenPose.init(assetManager, paramFilePath, binFilePath, useGPU);
                break;
        }
    }

    Box[] detect(ModelType modelType, Bitmap bitmap, double threshold, double nmsThreshold) {
        switch (modelType) {
            case YOLOv5:
                return YOLOv5.detect(bitmap, threshold, nmsThreshold);
            case YOLOv4:
            case MobileNetV2YOLOv3Nano:
            case YOLOFastestXL:
                return YOLOv4.detect(bitmap, threshold, nmsThreshold);
            case SimplePose:
                // TODO(tomassasovsky): make SimplePose return boxes
                SimplePose.detect(bitmap);
                break;
            case Yolact:
                // TODO(tomassasovsky): make yolact return boxes
                Yolact.detect(bitmap);
                break;
            case Enet:
                // TODO(tomassasovsky): make ENet return boxes
                ENet.detect(bitmap);
                break;
            case YOLOFaceLandmark:
                // TODO(tomassasovsky): make FaceLandmark return boxes
                FaceLandmark.detect(bitmap);
                break;
            case DBFace:
                // TODO(tomassasovsky): make DBFace return boxes
                DBFace.detect(bitmap, threshold, nmsThreshold);
                break;
            case MobileNetV2FCN:
                // TODO(tomassasovsky): make MbnFCN return boxes
                MbnFCN.detect(bitmap);
                break;
            case MobileNetV3Seg:
                // TODO(tomassasovsky): make MbnSeg return boxes
                MbnSeg.detect(bitmap);
                break;
            case NanoDet:
                return NanoDet.detect(bitmap, threshold, nmsThreshold);
            case LightOpenPose:
                // TODO(tomassasovsky): make LightOpenPose return boxes
                LightOpenPose.detect(bitmap);
                break;
        }

        return null;
    }
}
