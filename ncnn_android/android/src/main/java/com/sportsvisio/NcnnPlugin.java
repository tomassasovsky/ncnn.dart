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
                    Class<?> clazz = modelType.modelClass;
                    clazz.getMethod("init", AssetManager.class, String.class, String.class, boolean.class).invoke(null, mgr, paramFilePath, binFilePath, useGPU);
                } catch (Exception e) {
                    result.error(e.getClass().getName(), e.getMessage(), Arrays.toString(e.getStackTrace()));
                    return;
                }

                result.success(null);
                break;
            case "detect":
                byte[] image = Objects.requireNonNull(call.argument("imageData"), "imageData is null");
                Bitmap bitmap = BitmapFactory.decodeByteArray(image, 0, image.length);
                if (bitmap == null) {
                    result.error("ObjectNullException", "Bitmap is null", null);
                    return;
                }

                modelTypeStr = call.argument("modelType");
                modelType = ModelType.valueOf(modelTypeStr);

                double thresholdD = Objects.requireNonNull(call.argument("threshold"), "threshold is null");
                double nmsThresholdD = Objects.requireNonNull(call.argument("nmsThreshold"), "threshold is null");

                float threshold = (float) thresholdD;
                float nmsThreshold = (float) nmsThresholdD;

                try {
                    Class<?> clazz = modelType.modelClass;
                    Box[] boxes = null;
                    if (modelType.allowsThreshold) {
                        boxes = (Box[]) clazz.getMethod("detect", Bitmap.class, double.class, double.class).invoke(null, bitmap, threshold, nmsThreshold);
                    } else {
                        boxes = (Box[]) clazz.getMethod("detect", Bitmap.class).invoke(null, bitmap);
                    }

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
}
