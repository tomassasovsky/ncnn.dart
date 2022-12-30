//
// Created by Tomas on 12/29/2022.
//

#ifndef NCNN_ANDROID_YOLOV7_H
#define NCNN_ANDROID_YOLOV7_H

#include "ncnn/net.h"
#include "YoloV5.h"

class YoloV7 {
public:
    YoloV7(AAssetManager *assetManager, const char *paramFilePath, const char *binFilePath,
           bool useGPU);

    ~YoloV7();

    std::vector<BoxInfo> detect(JNIEnv *env, jobject image, float threshold, float nms_threshold);

private:
    static std::vector<BoxInfo>
    decode_infer(ncnn::Mat &data, const yolocv::YoloSize &frame_size, int net_size, int num_classes,
                 float threshold);

//    static void nms(std::vector<BoxInfo>& result,float nms_threshold);
    ncnn::Net *Net;
    int input_size = 640 / 2;
    int num_class = 80;
public:
    static YoloV7 *detector;
    static bool hasGPU;
    static bool toUseGPU;
};


#endif //YOLOV7_H
