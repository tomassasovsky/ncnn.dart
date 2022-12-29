#import "NcnnPlugin.h"

@implementation NcnnPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"ncnn_ios"
                                  binaryMessenger:registrar.messenger];
  [channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
    if ([@"getPlatformName" isEqualToString:call.method]) {
      result(@"iOS");
    } else {
      result(FlutterMethodNotImplemented);
    }
  }];
}

@end