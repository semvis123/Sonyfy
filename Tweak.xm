#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


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

id NCStatusObserver;
NSString *currentListeningMode = @"AVOutputDeviceBluetoothListeningModeNormal";

%hook AVOutputDevice

-(id)availableBluetoothListeningModes {
    if ([self.name isEqual:@"WH-1000XM3"]){
        NSArray *options = [NSArray arrayWithObjects:@"AVOutputDeviceBluetoothListeningModeNormal",
                            @"AVOutputDeviceBluetoothListeningModeActiveNoiseCancellation",
                            @"AVOutputDeviceBluetoothListeningModeAudioTransparency",
                            nil];
        return options;
    }
    return %orig;
}

-(BOOL)setCurrentBluetoothListeningMode:(id)arg1 error:(id*)arg2  {
    if ([self.name isEqual:@"WH-1000XM3"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] launchApplicationWithIdentifier:@"jp.co.sony.songpal.mdr" suspended:1];
        });
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:arg1 forKey:@"mode"];
        [[objc_getClass("NSDistributedNotificationCenter") defaultCenter]
            postNotificationName:@"com.semvis123.sonyfy/setNC"
            object:nil
            userInfo: userInfo
            deliverImmediately:YES];    
        return true;
    }
    return %orig;
}

-(id)currentBluetoothListeningMode {
    if ([self.name isEqual:@"WH-1000XM3"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] launchApplicationWithIdentifier:@"jp.co.sony.songpal.mdr" suspended:1];
        });
        return currentListeningMode; 
    }
    return %orig;
}
%end

%ctor {
    NCStatusObserver = [[objc_getClass("NSDistributedNotificationCenter") defaultCenter] addObserverForName:@"com.semvis123.sonyfy/NCStatus" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        currentListeningMode = [notification.userInfo objectForKey:@"mode"];
    }];
}

%dtor {
    [[objc_getClass("NSDistributedNotificationCenter") defaultCenter] removeObserver:NCStatusObserver name:@"com.semvis123.sonyfy/NCStatus" object:nil ];
}