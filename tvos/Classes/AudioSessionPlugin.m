#import "AudioSessionPlugin.h"
#if !TARGET_OS_TV
#import "DarwinAudioSession.h"
#endif

static NSObject *configuration = nil;
static NSHashTable<AudioSessionPlugin *> *plugins = nil;

@implementation AudioSessionPlugin {
#if !TARGET_OS_TV
    DarwinAudioSession *_darwinAudioSession;
#else
    // Add any tvOS-specific properties here if needed
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
    // Set up any tvOS-specific audio session handling here
    // For example, you might want to configure basic audio session settings
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
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
            // Forward other method calls to DarwinAudioSession
            [_darwinAudioSession handleMethodCall:call result:result];
        }
#else
        // Handle tvOS-specific audio session methods here
        if ([@"getTvOsAudioSessionInfo" isEqualToString:call.method]) {
            // Example of a tvOS-specific method
            [self getTvOsAudioSessionInfo:result];
        } else {
            result(FlutterMethodNotImplemented);
        }
#endif
    }
}

#if TARGET_OS_TV
// Example of a tvOS-specific method
- (void)getTvOsAudioSessionInfo:(FlutterResult)result {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSDictionary *info = @{
        @"category": session.category,
        @"sampleRate": @(session.sampleRate),
        @"outputLatency": @(session.outputLatency)
    };
    result(info);
}
#endif

@end