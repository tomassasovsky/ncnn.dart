#ifndef YOLOV4_H
#define YOLOV4_H

#include "ncnn/net.h"
#include "YoloV5.h"


class YoloV4 {
public:
    YoloV4(AAssetManager *assetManager, const char *paramFilePath, const char *binFilePath,
           bool useGPU);

    ~YoloV4();

    std::vector<BoxInfo> detect(JNIEnv *env, jobject image, double threshold, double nms_threshold);

private:
    static std::vector<BoxInfo>
    decode_infer(ncnn::Mat &data, const yolocv::YoloSize &frame_size, int net_size, int num_classes,
                 float threshold);

//    static void nms(std::vector<BoxInfo>& result,float nms_threshold);
    ncnn::Net *Net;
    int input_size = 640 / 2;
    int num_class = 80;
public:
    static YoloV4 *detector;
    static bool hasGPU;
    static bool toUseGPU;
};


#endif //YOLOV4_H
