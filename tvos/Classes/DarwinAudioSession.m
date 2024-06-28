#import "DarwinAudioSession.h"

@implementation DarwinAudioSession {
    NSObject<FlutterPluginRegistrar>* _registrar;
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    self = [super init];
    if (self) {
        _registrar = registrar;
        _channel = [FlutterMethodChannel
            methodChannelWithName:@"com.ryanheise.av_audio_session"
              binaryMessenger:[registrar messenger]];
        __weak typeof(self) weakSelf = self;
        [_channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
            [weakSelf handleMethodCall:call result:result];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioInterrupt:) name:AVAudioSessionInterruptionNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSArray* args = (NSArray*)call.arguments;
    if ([@"getCategory" isEqualToString:call.method]) {
        [self getCategory:args result:result];
    } else if ([@"setCategory" isEqualToString:call.method]) {
        [self setCategory:args result:result];
    } else if ([@"getAvailableCategories" isEqualToString:call.method]) {
        [self getAvailableCategories:args result:result];
    } else if ([@"getCategoryOptions" isEqualToString:call.method]) {
        [self getCategoryOptions:args result:result];
    } else if ([@"getMode" isEqualToString:call.method]) {
        [self getMode:args result:result];
    } else if ([@"setMode" isEqualToString:call.method]) {
        [self setMode:args result:result];
    } else if ([@"getAvailableModes" isEqualToString:call.method]) {
        [self getAvailableModes:args result:result];
    } else if ([@"setActive" isEqualToString:call.method]) {
        [self setActive:args result:result];
    } else if ([@"isOtherAudioPlaying" isEqualToString:call.method]) {
        [self isOtherAudioPlaying:args result:result];
    } else if ([@"getCurrentRoute" isEqualToString:call.method]) {
        [self getCurrentRoute:args result:result];
    } else if ([@"getOutputLatency" isEqualToString:call.method]) {
        [self getOutputLatency:args result:result];
    }
#if TARGET_OS_IOS
    else if ([@"getRouteSharingPolicy" isEqualToString:call.method]) {
        [self getRouteSharingPolicy:args result:result];
    } else if ([@"getSecondaryAudioShouldBeSilencedHint" isEqualToString:call.method]) {
        [self getSecondaryAudioShouldBeSilencedHint:args result:result];
    } else if ([@"getAllowHapticsAndSystemSoundsDuringRecording" isEqualToString:call.method]) {
        [self getAllowHapticsAndSystemSoundsDuringRecording:args result:result];
    } else if ([@"setAllowHapticsAndSystemSoundsDuringRecording" isEqualToString:call.method]) {
        [self setAllowHapticsAndSystemSoundsDuringRecording:args result:result];
    } else if ([@"getPromptStyle" isEqualToString:call.method]) {
        [self getPromptStyle:args result:result];
    } else if ([@"overrideOutputAudioPort" isEqualToString:call.method]) {
        [self overrideOutputAudioPort:args result:result];
    } else if ([@"setPreferredInput" isEqualToString:call.method]) {
        [self setPreferredInput:args result:result];
    } else if ([@"getAvailableInputs" isEqualToString:call.method]) {
        [self getAvailableInputs:args result:result];
    } else if ([@"getInputLatency" isEqualToString:call.method]) {
        [self getInputLatency:args result:result];
    } else if ([@"getRecordPermission" isEqualToString:call.method]) {
        [self getRecordPermission:args result:result];
    } else if ([@"requestRecordPermission" isEqualToString:call.method]) {
        [self requestRecordPermission:args result:result];
    }
#endif
    else {
        result(FlutterMethodNotImplemented);
    }
}

// Implement shared methods here

#if TARGET_OS_IOS
// Implement iOS-specific methods here
#endif

- (AVAudioSessionCategory)flutterToCategory:(NSNumber *)categoryIndex {
    switch (categoryIndex.integerValue) {
        case 0: return AVAudioSessionCategoryAmbient;
        case 1: return AVAudioSessionCategorySoloAmbient;
        case 2: return AVAudioSessionCategoryPlayback;
        #if TARGET_OS_IOS
        case 3: return AVAudioSessionCategoryRecord;
        case 4: return AVAudioSessionCategoryPlayAndRecord;
        #endif
        case 5: return AVAudioSessionCategoryMultiRoute;
        default: return AVAudioSessionCategoryPlayback;
    }
}

- (NSNumber *)categoryToFlutter:(AVAudioSessionCategory)category {
    if ([category isEqualToString:AVAudioSessionCategoryAmbient]) return @0;
    if ([category isEqualToString:AVAudioSessionCategorySoloAmbient]) return @1;
    if ([category isEqualToString:AVAudioSessionCategoryPlayback]) return @2;
    #if TARGET_OS_IOS
    if ([category isEqualToString:AVAudioSessionCategoryRecord]) return @3;
    if ([category isEqualToString:AVAudioSessionCategoryPlayAndRecord]) return @4;
    #endif
    if ([category isEqualToString:AVAudioSessionCategoryMultiRoute]) return @5;
    return @2; // Default to Playback
}

- (void)audioInterrupt:(NSNotification *)notification {
    NSDictionary *interruptionDict = notification.userInfo;
    NSInteger interruptionType = [[interruptionDict valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    
    if (interruptionType == AVAudioSessionInterruptionTypeBegan) {
        [self invokeMethod:@"onInterruptionEvent" arguments:@[@0]];
    } else if (interruptionType == AVAudioSessionInterruptionTypeEnded) {
        NSInteger interruptionOption = [[interruptionDict valueForKey:AVAudioSessionInterruptionOptionKey] integerValue];
        BOOL shouldResume = (interruptionOption == AVAudioSessionInterruptionOptionShouldResume);
        [self invokeMethod:@"onInterruptionEvent" arguments:@[@1, @(shouldResume)]];
    }
    
    #if TARGET_OS_IOS
    if (@available(iOS 14.5, *)) {
        NSNumber *interruptionReason = interruptionDict[AVAudioSessionInterruptionReasonKey];
        // Handle interruption reason
    }
    #endif
}

- (void)routeChange:(NSNotification *)notification {
    NSDictionary *routeChangeDict = notification.userInfo;
    NSInteger routeChangeReason = [[routeChangeDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    [self invokeMethod:@"onRouteChange" arguments:@[@(routeChangeReason)]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end