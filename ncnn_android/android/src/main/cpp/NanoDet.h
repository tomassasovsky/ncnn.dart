#ifndef NANODET_H
#define NANODET_H

#include "ncnn/net.h"
#include "YoloV5.h"

struct HeadInfo {
    std::string cls_layer;
    std::string dis_layer;
    int stride;
};


class NanoDet {
public:
    NanoDet(AAssetManager *assetManager, const char *paramFilePath, const char *binFilePath,
           bool useGPU);

    ~NanoDet();

    std::vector<BoxInfo>
    detect(JNIEnv *env, jobject image, float score_threshold, float nms_threshold);

private:
    void preprocess(JNIEnv *env, jobject image, ncnn::Mat &in);

    void decode_infer(ncnn::Mat &cls_pred, ncnn::Mat &dis_pred, int stride, float threshold,
                      std::vector<std::vector<BoxInfo>> &results, float width_ratio,
                      float height_ratio);

    BoxInfo disPred2Bbox(const float *&dfl_det, int label, float score, int x, int y, int stride,
                         float width_ratio,
                         float height_ratio);

    static void nms(std::vector<BoxInfo> &result, float nms_threshold);

    ncnn::Net *Net;
    int input_size = 320;
    int num_class = 80;
    int reg_max = 7;
    std::vector<HeadInfo> heads_info{
            // cls_pred|dis_pred|stride
            {"792", "795", 8},
            {"814", "817", 16},
            {"836", "839", 32},
    };

public:
    static NanoDet *detector;
    static bool hasGPU;
    static bool toUseGPU;
};


#endif //NANODET_H
