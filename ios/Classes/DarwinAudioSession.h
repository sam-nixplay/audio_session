#import <Flutter/Flutter.h>

#if TARGET_OS_TV
    #define AUDIO_SESSION_MICROPHONE 0
#else
    #define AUDIO_SESSION_MICROPHONE 1
#endif

@interface DarwinAudioSession : NSObject

@property (readonly, nonatomic) FlutterMethodChannel *channel;

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar;

#if AUDIO_SESSION_MICROPHONE
- (void)getRecordPermission:(NSArray *)args result:(FlutterResult)result;
- (void)requestRecordPermission:(NSArray *)args result:(FlutterResult)result;
#endif

#if !TARGET_OS_TV
- (void)setPreferredInput:(NSArray *)args result:(FlutterResult)result;
- (void)getAvailableInputs:(NSArray *)args result:(FlutterResult)result;
#endif

@end
