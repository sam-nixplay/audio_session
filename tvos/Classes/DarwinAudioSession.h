#import <Flutter/Flutter.h>
#import <AVFoundation/AVFoundation.h>

@interface DarwinAudioSession : NSObject

@property (readonly, nonatomic) FlutterMethodChannel *channel;

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar;

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result;
- (void)getCategory:(NSArray *)args result:(FlutterResult)result;
- (void)setCategory:(NSArray *)args result:(FlutterResult)result;
- (void)getAvailableCategories:(NSArray *)args result:(FlutterResult)result;
- (void)getCategoryOptions:(NSArray *)args result:(FlutterResult)result;
- (void)getMode:(NSArray *)args result:(FlutterResult)result;
- (void)setMode:(NSArray *)args result:(FlutterResult)result;
- (void)getAvailableModes:(NSArray *)args result:(FlutterResult)result;
- (void)setActive:(NSArray *)args result:(FlutterResult)result;
- (void)isOtherAudioPlaying:(NSArray *)args result:(FlutterResult)result;
- (void)getCurrentRoute:(NSArray *)args result:(FlutterResult)result;
- (void)getOutputLatency:(NSArray *)args result:(FlutterResult)result;

#if TARGET_OS_IOS
- (void)getRouteSharingPolicy:(NSArray *)args result:(FlutterResult)result;
- (void)getSecondaryAudioShouldBeSilencedHint:(NSArray *)args result:(FlutterResult)result;
- (void)getAllowHapticsAndSystemSoundsDuringRecording:(NSArray *)args result:(FlutterResult)result;
- (void)setAllowHapticsAndSystemSoundsDuringRecording:(NSArray *)args result:(FlutterResult)result;
- (void)getPromptStyle:(NSArray *)args result:(FlutterResult)result;
- (void)overrideOutputAudioPort:(NSArray *)args result:(FlutterResult)result;
- (void)setPreferredInput:(NSArray *)args result:(FlutterResult)result;
- (void)getAvailableInputs:(NSArray *)args result:(FlutterResult)result;
- (void)getInputLatency:(NSArray *)args result:(FlutterResult)result;
- (void)getRecordPermission:(NSArray *)args result:(FlutterResult)result;
- (void)requestRecordPermission:(NSArray *)args result:(FlutterResult)result;
#endif

- (AVAudioSessionCategory)flutterToCategory:(NSNumber *)categoryIndex;
- (NSNumber *)categoryToFlutter:(AVAudioSessionCategory)category;
- (AVAudioSessionMode)flutterToMode:(NSNumber *)modeIndex;
- (NSNumber *)modeToFlutter:(AVAudioSessionMode)mode;
- (void)sendError:(NSError *)error result:(FlutterResult)result;
- (void)invokeMethod:(NSString *)method arguments:(id _Nullable)arguments;

@end