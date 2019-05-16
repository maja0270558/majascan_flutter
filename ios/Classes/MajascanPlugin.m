#import "MajascanPlugin.h"
#import <majascan/majascan-Swift.h>

@implementation MajascanPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMajascanPlugin registerWithRegistrar:registrar];
}
@end
