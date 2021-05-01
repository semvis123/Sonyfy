@interface NSDistributedNotificationCenter : NSNotificationCenter
+(id)defaultCenter;
-(void)postNotificationName:(id)arg1 object:(id)arg2 userInfo:(id)arg3 deliverImmediately:(BOOL)arg4;
-(void)addObserver:(id)arg1 selector:(SEL)arg2 name:(id)arg3 object:(id)arg4;
-(void)postNotificationName:(id)arg1 object:(id)arg2 userInfo:(id)arg3;
@end


@interface AVOutputDevice : NSObject
-(void)setCurrentBluetoothListeningMode:(NSString *)arg1;
-(NSString *)name;
@end

@interface UIApplication (Private)
+(id)sharedApplication;
-(BOOL)launchApplicationWithIdentifier:(id)identifier suspended:(BOOL)suspended;
@end
