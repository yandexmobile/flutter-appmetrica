#import "MetricaPlugin.h"
#if __has_include(<metrica_plugin/metrica_plugin-Swift.h>)
#import <metrica_plugin/metrica_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "metrica_plugin-Swift.h"
#endif

@implementation MetricaPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMetricaPlugin registerWithRegistrar:registrar];
}
@end
