#import "AudioSessionPlugin.h"
#if !TARGET_OS_TV
#import "DarwinAudioSession.h"
#endif

static NSObject *configuration = nil;
static NSHashTable<AudioSessionPlugin *> *plugins = nil;

@implementation AudioSessionPlugin {
#if !TARGET_OS_TV
    DarwinAudioSession *_darwinAudioSession;
#endif
    FlutterMethodChannel *_channel;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if (!plugins) {
        plugins = [NSHashTable weakObjectsHashTable];
    }
    AudioSessionPlugin *plugin = [[AudioSessionPlugin alloc] initWithRegistrar:registrar];
    [plugins addObject:plugin];
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    self = [super init];
    NSAssert(self, @"super init cannot be nil");
    _channel = [FlutterMethodChannel
        methodChannelWithName:@"com.ryanheise.audio_session"
              binaryMessenger:[registrar messenger]];
    [registrar addMethodCallDelegate:self channel:_channel];

#if !TARGET_OS_TV
    _darwinAudioSession = [[DarwinAudioSession alloc] initWithRegistrar:registrar];
#else
    // Set up any tvOS-specific audio session handling here, if needed
#endif

    return self;
}

- (FlutterMethodChannel *)channel {
    return _channel;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSArray* args = (NSArray*)call.arguments;
    if ([@"setConfiguration" isEqualToString:call.method]) {
        configuration = args[0];
        for (AudioSessionPlugin *plugin in plugins) {
            [plugin.channel invokeMethod:@"onConfigurationChanged" arguments:@[configuration]];
        }
        result(nil);
    } else if ([@"getConfiguration" isEqualToString:call.method]) {
        result(configuration);
    } else {
#if !TARGET_OS_TV
        if ([@"someMethodSpecificToDarwinAudioSession" isEqualToString:call.method]) {
            // Call the specific method on DarwinAudioSession
            [_darwinAudioSession someMethodSpecificToDarwinAudioSession:args result:result];
        } else {
            result(FlutterMethodNotImplemented);
        }
#else
        // Handle tvOS-specific audio session methods here, if any
        result(FlutterMethodNotImplemented);
#endif
    }
}

@end
