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
    } else if ([@"getMode" isEqualToString:call.method]) {
        [self getMode:args result:result];
    } else if ([@"setMode" isEqualToString:call.method]) {
        [self setMode:args result:result];
    } else if ([@"setActive" isEqualToString:call.method]) {
        [self setActive:args result:result];
    } else if ([@"getCurrentRoute" isEqualToString:call.method]) {
        [self getCurrentRoute:args result:result];
    } else if ([@"getOutputLatency" isEqualToString:call.method]) {
        [self getOutputLatency:args result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)getCategory:(NSArray *)args result:(FlutterResult)result {
    AVAudioSessionCategory category = [[AVAudioSession sharedInstance] category];
    result([self categoryToFlutter:category]);
}

- (void)setCategory:(NSArray *)args result:(FlutterResult)result {
    NSNumber *categoryIndex = args[0];
    NSError *error = nil;
    BOOL success = [[AVAudioSession sharedInstance] setCategory:[self flutterToCategory:categoryIndex] error:&error];
    if (error) {
        [self sendError:error result:result];
    } else {
        result(@(success));
    }
}

- (void)getAvailableCategories:(NSArray *)args result:(FlutterResult)result {
    result(@[
        @(AVAudioSessionCategoryAmbient),
        @(AVAudioSessionCategoryPlayback)
    ]);
}

- (void)getMode:(NSArray *)args result:(FlutterResult)result {
    AVAudioSessionMode mode = [[AVAudioSession sharedInstance] mode];
    result([self modeToFlutter:mode]);
}

- (void)setMode:(NSArray *)args result:(FlutterResult)result {
    NSNumber *modeIndex = args[0];
    NSError *error = nil;
    BOOL success = [[AVAudioSession sharedInstance] setMode:[self flutterToMode:modeIndex] error:&error];
    if (error) {
        [self sendError:error result:result];
    } else {
        result(@(success));
    }
}

- (void)setActive:(NSArray *)args result:(FlutterResult)result {
    BOOL active = [args[0] boolValue];
    NSError *error = nil;
    BOOL success = [[AVAudioSession sharedInstance] setActive:active error:&error];
    if (error) {
        [self sendError:error result:result];
    } else {
        result(@(success));
    }
}

- (void)getCurrentRoute:(NSArray *)args result:(FlutterResult)result {
    AVAudioSessionRouteDescription *route = [[AVAudioSession sharedInstance] currentRoute];
    NSMutableDictionary *routeInfo = [NSMutableDictionary dictionary];
    routeInfo[@"outputs"] = [self describePortList:route.outputs];
    result(routeInfo);
}

- (void)getOutputLatency:(NSArray *)args result:(FlutterResult)result {
    NSTimeInterval latency = [[AVAudioSession sharedInstance] outputLatency];
    result(@(latency * 1000000)); // Convert to microseconds
}

- (AVAudioSessionCategory)flutterToCategory:(NSNumber *)categoryIndex {
    switch (categoryIndex.integerValue) {
        case 0: return AVAudioSessionCategoryAmbient;
        case 2: return AVAudioSessionCategoryPlayback;
        default: return AVAudioSessionCategoryPlayback;
    }
}

- (NSNumber *)categoryToFlutter:(AVAudioSessionCategory)category {
    if ([category isEqualToString:AVAudioSessionCategoryAmbient]) return @0;
    if ([category isEqualToString:AVAudioSessionCategoryPlayback]) return @2;
    return @2; // Default to Playback
}

- (AVAudioSessionMode)flutterToMode:(NSNumber *)modeIndex {
    switch (modeIndex.integerValue) {
        case 0: return AVAudioSessionModeDefault;
        case 3: return AVAudioSessionModeMoviePlayback;
        default: return AVAudioSessionModeDefault;
    }
}

- (NSNumber *)modeToFlutter:(AVAudioSessionMode)mode {
    if ([mode isEqualToString:AVAudioSessionModeDefault]) return @0;
    if ([mode isEqualToString:AVAudioSessionModeMoviePlayback]) return @3;
    return @0; // Default
}

- (NSArray *)describePortList:(NSArray<AVAudioSessionPortDescription *> *)ports {
    NSMutableArray *portDescriptions = [NSMutableArray array];
    for (AVAudioSessionPortDescription *port in ports) {
        [portDescriptions addObject:@{
            @"portName": port.portName,
            @"portType": [self portTypeToString:port.portType],
        }];
    }
    return portDescriptions;
}

- (NSString *)portTypeToString:(AVAudioSessionPort)portType {
    if ([portType isEqualToString:AVAudioSessionPortHDMI]) return @"HDMI";
    if ([portType isEqualToString:AVAudioSessionPortBuiltInSpeaker]) return @"BuiltInSpeaker";
    return @"Unknown";
}

- (void)sendError:(NSError *)error result:(FlutterResult)result {
    FlutterError *flutterError = [FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", (long)error.code]
                                                    message:error.localizedDescription
                                                    details:nil];
    result(flutterError);
}

- (void)invokeMethod:(NSString *)method arguments:(id)arguments {
    [_channel invokeMethod:method arguments:arguments];
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