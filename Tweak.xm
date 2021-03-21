#import <Foundation/Foundation.h>
#import <rocketbootstrap/rocketbootstrap.h>

@interface CPDistributedMessagingCenter : NSObject
+ (id)centerNamed:(id)arg1;
-(BOOL)sendMessageName:(NSString*)name userInfo:(NSDictionary*)info;
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
    BOOL r = %orig;
    NSLog(@" = %d", r);
    NSLog(@"Set current bluetooth listening mode");
    CPDistributedMessagingCenter *messagingCenter;
    messagingCenter = [%c(CPDistributedMessagingCenter) centerNamed:@"com.semvis123.sonyfy"];
    rocketbootstrap_distributedmessagingcenter_apply(messagingCenter);
    [messagingCenter sendMessageName:@"setNowPls" userInfo: nil];
    return r; 
}

-(id)currentBluetoothListeningMode { %log; id r = %orig; NSLog(@" = %@", r); return r; }
-(void)setCurrentBluetoothListeningMode:(id)arg1  { %log; %orig; }
%end



// %end
%ctor {
    NSLog(@"from springboard ");
}