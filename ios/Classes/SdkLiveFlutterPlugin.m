#import "SdkLiveFlutterPlugin.h"

#if __has_include(<screenmeet_sdk_flutter/screenmeet_sdk_flutter-Swift.h>)
#import <screenmeet_sdk_flutter/screenmeet_sdk_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "screenmeet_sdk_flutter-Swift.h"
#endif

@implementation SdkLiveFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSdkLiveFlutterPlugin registerWithRegistrar:registrar];
}
@end
