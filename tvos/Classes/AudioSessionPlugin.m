#import "AudioSessionPlugin.h"
#import "DarwinAudioSession.h"

static NSObject *configuration = nil;
static NSHashTable<AudioSessionPlugin *> *plugins = nil;

@implementation AudioSessionPlugin {
    DarwinAudioSession *_darwinAudioSession;
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

    _darwinAudioSession = [[DarwinAudioSession alloc] initWithRegistrar:registrar];
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
    } else if ([@"getRecordPermission" isEqualToString:call.method] ||
               [@"requestRecordPermission" isEqualToString:call.method]) {
        #if AUDIO_SESSION_MICROPHONE
        [_darwinAudioSession handleMethodCall:call result:result];
        #else
        result(FlutterMethodNotImplemented);
        #endif
    } else if ([@"setPreferredInput" isEqualToString:call.method] ||
               [@"getAvailableInputs" isEqualToString:call.method]) {
        #if !TARGET_OS_TV
        [_darwinAudioSession handleMethodCall:call result:result];
        #else
        result(FlutterMethodNotImplemented);
        #endif
    } else {
        [_darwinAudioSession handleMethodCall:call result:result];
    }
}

@end