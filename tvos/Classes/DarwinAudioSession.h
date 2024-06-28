#import <Flutter/Flutter.h>
#import <AVFoundation/AVFoundation.h>

@interface DarwinAudioSession : NSObject

@property (readonly, nonatomic) FlutterMethodChannel *channel;

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar;

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result;
- (void)getCategory:(NSArray *)args result:(FlutterResult)result;
- (void)setCategory:(NSArray *)args result:(FlutterResult)result;
- (void)getAvailableCategories:(NSArray *)args result:(FlutterResult)result;
- (void)getMode:(NSArray *)args result:(FlutterResult)result;
- (void)setMode:(NSArray *)args result:(FlutterResult)result;
- (void)getAvailableModes:(NSArray *)args result:(FlutterResult)result;
- (void)setActive:(NSArray *)args result:(FlutterResult)result;
- (void)isOtherAudioPlaying:(NSArray *)args result:(FlutterResult)result;
- (void)getCurrentRoute:(NSArray *)args result:(FlutterResult)result;
- (void)getOutputLatency:(NSArray *)args result:(FlutterResult)result;

- (AVAudioSessionCategory)flutterToCategory:(NSNumber *)categoryIndex;
- (NSNumber *)categoryToFlutter:(AVAudioSessionCategory)category;
- (AVAudioSessionMode)flutterToMode:(NSNumber *)modeIndex;
- (NSNumber *)modeToFlutter:(AVAudioSessionMode)mode;
- (void)sendError:(NSError *)error result:(FlutterResult)result;
- (void)invokeMethod:(NSString *)method arguments:(id _Nullable)arguments;

- (NSArray *)describePortList:(NSArray<AVAudioSessionPortDescription *> *)ports;
- (NSString *)portTypeToString:(AVAudioSessionPort)portType;

@end