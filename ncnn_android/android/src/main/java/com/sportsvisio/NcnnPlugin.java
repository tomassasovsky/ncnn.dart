// Copyright (c) 2022, SportsVisio, Inc.
// https://sportsvisio.com/
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

package com.sportsvisio;

import static androidx.core.math.MathUtils.clamp;

import android.content.Context;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.ColorSpace;
import android.graphics.ImageFormat;
import android.graphics.Rect;
import android.graphics.YuvImage;

import androidx.annotation.NonNull;

import java.io.ByteArrayOutputStream;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

import io.flutter.FlutterInjector;
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

                modelTypeStr = call.argument("modelType");
                modelType = ModelType.valueOf(modelTypeStr);

                double threshold = Objects.requireNonNull(call.argument("threshold"), "threshold is null");
                double nmsThreshold = Objects.requireNonNull(call.argument("nmsThreshold"), "threshold is null");

                // start timer
                long startTime = System.currentTimeMillis();
                BitmapFactory.Options bfo = new BitmapFactory.Options();
                bfo.inPreferredConfig = Bitmap.Config.ARGB_8888;
                bfo.inMutable = true;   // this makes an mutable bitmap
                bfo.inPreferredColorSpace = ColorSpace.get(ColorSpace.Named.SRGB);
                Bitmap bitmap = BitmapFactory.decodeByteArray(image, 0, image.length, bfo);

                long endTime = System.currentTimeMillis();
                long imageConversionTime = endTime - startTime;
                if (bitmap == null) {
                    result.error("ObjectNullException", "Bitmap is null", null);
                    return;
                }

                startTime = System.currentTimeMillis();
                try {
                    Box[] boxes = detect(modelType, bitmap, (float) threshold, (float) nmsThreshold);

                    endTime = System.currentTimeMillis();
                    long detectionTime = endTime - startTime;

                    if (boxes == null) {
                        result.success(null);
                        return;
                    }

                    ArrayList<HashMap<String, Object>> jsonArray = new ArrayList<>();
                    for (Box box : boxes) {
                        jsonArray.add(box.toMap());
                    }

                    HashMap<String, Object> resultMap = new HashMap<>();
                    resultMap.put("boxes", jsonArray);
                    resultMap.put("time", endTime - startTime);
                    resultMap.put("imageHeight", bitmap.getHeight());
                    resultMap.put("imageWidth", bitmap.getWidth());
                    resultMap.put("imageConversionTime", imageConversionTime);
                    resultMap.put("detectionTime", detectionTime);

                    result.success(resultMap);
                } catch (Exception e) {
                    result.error(e.getClass().getName(), e.getMessage(), Arrays.toString(e.getStackTrace()));
                    return;
                }
                break;
            case "detectOnCameraImage":
                Map<String, Object> yPlane = Objects.requireNonNull(call.argument("yPlane"), "yPlane is null");
                Map<String, Object> uPlane = Objects.requireNonNull(call.argument("uPlane"), "uPlane is null");
                Map<String, Object> vPlane = Objects.requireNonNull(call.argument("vPlane"), "vPlane is null");

                int imageWidth = Objects.requireNonNull(call.argument("imageWidth"), "imageWidth is null");
                int imageHeight = Objects.requireNonNull(call.argument("imageHeight"), "imageHeight is null");

                threshold = Objects.requireNonNull(call.argument("threshold"), "threshold is null");
                nmsThreshold = Objects.requireNonNull(call.argument("nmsThreshold"), "threshold is null");

                startTime = System.currentTimeMillis();
                FlutterImagePlane yPlaneObj = FlutterImagePlane.fromMap(yPlane);
                FlutterImagePlane uPlaneObj = FlutterImagePlane.fromMap(uPlane);
                FlutterImagePlane vPlaneObj = FlutterImagePlane.fromMap(vPlane);

                // concatenate the byte arrays
                byte[] yBytes = yPlaneObj.bytes;
                byte[] uBytes = uPlaneObj.bytes;
                byte[] vBytes = vPlaneObj.bytes;
                byte[] yuvBytes = new byte[yBytes.length + uBytes.length + vBytes.length];
                System.arraycopy(yBytes, 0, yuvBytes, 0, yBytes.length);
                System.arraycopy(uBytes, 0, yuvBytes, yBytes.length, uBytes.length);
                System.arraycopy(vBytes, 0, yuvBytes, yBytes.length + uBytes.length, vBytes.length);


                YuvImage yuvImage = new YuvImage(yuvBytes, ImageFormat.NV21, imageWidth, imageHeight, null);
                ByteArrayOutputStream out = new ByteArrayOutputStream();
                yuvImage.compressToJpeg(new Rect(0, 0, imageWidth, imageHeight), 100, out);
                byte[] imageBytes = out.toByteArray();
                bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.length);

                modelTypeStr = call.argument("modelType");
                modelType = ModelType.valueOf(modelTypeStr);

                endTime = System.currentTimeMillis();
                imageConversionTime = endTime - startTime;

                startTime = System.currentTimeMillis();
                try {
                    Box[] boxes = detect(modelType, bitmap, (float) threshold, (float) nmsThreshold);

                    endTime = System.currentTimeMillis();
                    long detectionTime = endTime - startTime;

                    if (boxes == null) {
                        result.success(null);
                        return;
                    }

                    ArrayList<HashMap<String, Object>> jsonArray = new ArrayList<>();
                    for (Box box : boxes) {
                        jsonArray.add(box.toMap());
                    }

                    HashMap<String, Object> resultMap = new HashMap<>();
                    resultMap.put("boxes", jsonArray);
                    resultMap.put("time", endTime - startTime);
                    resultMap.put("imageHeight", bitmap.getHeight());
                    resultMap.put("imageWidth", bitmap.getWidth());
                    resultMap.put("bytes", imageBytes);
                    resultMap.put("imageConversionTime", imageConversionTime);
                    resultMap.put("detectionTime", detectionTime);

                    result.success(resultMap);
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

    private BitmapResult imagePlanesToBitmap(FlutterImagePlane[] imagePlanes, int width, int height) {
        FlutterImagePlane yImagePlane = imagePlanes[0];
        FlutterImagePlane uImagePlane = imagePlanes[1];
        FlutterImagePlane vImagePlane = imagePlanes[2];

        ByteBuffer yBuffer = yImagePlane.getByteBuffer();
        ByteBuffer uBuffer = uImagePlane.getByteBuffer();
        ByteBuffer vBuffer = vImagePlane.getByteBuffer();

        int[] argbArray = new int[width * height];
        yBuffer.position(0);
        uBuffer.position(0);
        vBuffer.position(0);


        int yRowStride = yImagePlane.getRowStride();
        int yPixelStride = yImagePlane.getPixelStride();
        int uvRowStride = uImagePlane.getRowStride();
        int uvPixelStride = uImagePlane.getPixelStride();

        int r, g, b;
        int yValue, uValue, vValue;

        for (int y = 0; y < height; ++y) {
            for (int x = 0; x < width; ++x) {
                int yIndex = (y * yRowStride) + (x * yPixelStride);
                // Y plane should have positive values belonging to [0...255]
                yValue = (yBuffer.get(yIndex) & 0xff);

                int uvx = x / 2;
                int uvy = y / 2;
                // U/V Values are subsampled i.e. each pixel in U/V chanel in a
                // YUV_420 image act as chroma value for 4 neighbouring pixels
                int uvIndex = (uvy * uvRowStride) + (uvx * uvPixelStride);

                // U/V values ideally fall under [-0.5, 0.5] range. To fit them into
                // [0, 255] range they are scaled up and centered to 128.
                // Operation below brings U/V values to [-128, 127].
                uValue = (uBuffer.get(uvIndex) & 0xff) - 128;
                vValue = (vBuffer.get(uvIndex) & 0xff) - 128;

                // Compute RGB values per formula above.
                r = (int) (yValue + 1.370705f * vValue);
                g = (int) (yValue - (0.698001f * vValue) - (0.337633f * uValue));
                b = (int) (yValue + 1.732446f * uValue);
                r = clamp(r, 0, 255);
                g = clamp(g, 0, 255);
                b = clamp(b, 0, 255);

                // Use 255 for alpha value, no transparency. ARGB values are
                // positioned in each byte of a single 4 byte integer
                // [AAAAAAAARRRRRRRRGGGGGGGGBBBBBBBB]
                int argbIndex = y * width + x;
                argbArray[argbIndex]
                        = (255 << 24) | (r & 255) << 16 | (g & 255) << 8 | (b & 255);
            }
        }

        Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        bitmap.setPixels(argbArray, 0, width, 0, 0, width, height);
        ByteArrayOutputStream stream = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);
        byte[] byteArray = stream.toByteArray();

        return new BitmapResult(bitmap, byteArray);
    }

    private class BitmapResult {
        Bitmap bitmap;
        byte[] bytes;

        BitmapResult(Bitmap bitmap, byte[] bytes) {
            this.bitmap = bitmap;
            this.bytes = bytes;
        }
    }
}
