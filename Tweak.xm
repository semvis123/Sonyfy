#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <rocketbootstrap/rocketbootstrap.h>

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


%hook AVOutputDevice

-(id)availableBluetoothListeningModes {
    %log;
    id r = %orig;
    NSLog(@" = %@", r);

    if ([self.name isEqual:@"WH-1000XM3"]){
        NSArray *options = [NSArray arrayWithObjects:@"AVOutputDeviceBluetoothListeningModeNormal",
                            @"AVOutputDeviceBluetoothListeningModeActiveNoiseCancellation",
                            @"AVOutputDeviceBluetoothListeningModeAudioTransparency",
                            nil];
        return options;
    }

    return r;
}

-(BOOL)setCurrentBluetoothListeningMode:(id)arg1 error:(id*)arg2  {
    %log;
    NSLog(@"Set current bluetooth listening mode");
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:arg1 forKey:@"mode"];
    [[objc_getClass("NSDistributedNotificationCenter") defaultCenter]
        postNotificationName:@"com.semvis123.sonyfy/setNC"
        object:nil
        userInfo: userInfo
        deliverImmediately:YES];
    

    BOOL r = %orig;
    NSLog(@" = %d", r);
    return r; 
}

-(id)currentBluetoothListeningMode { %log; id r = %orig; NSLog(@" = %@", r); return r; }
-(void)setCurrentBluetoothListeningMode:(id)arg1  { %log; %orig; }
%end



// %end
%ctor {
    NSLog(@"from springboard ");
}