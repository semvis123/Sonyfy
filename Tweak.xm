#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ExternalAccessory/ExternalAccessory.h>
#define HBLogDebug NSLog


@interface AVOutputDevice : NSObject
-(void)setCurrentBluetoothListeningMode:(NSString *)arg1;
-(NSString *)name;
@end

@interface MPAVRoute : NSObject
-(id)logicalLeaderOutputDevice;
@end

@interface MPAVRoutingController : NSObject
@property(readonly, nonatomic) MPAVRoute *pickedRoute;
@end

@interface SBMediaController : NSObject
+ (instancetype)sharedInstance;
-(BOOL)_sendMediaCommand:(unsigned)command;
-(float)volume;
-(BOOL)_lastNowPlayingAppIsPlaying;
@property(readonly, nonatomic)MPAVRoutingController *_routingController;
@end


%hook AVOutputDevice
-(id)availableBluetoothListeningModes {
    %log;
    id r = %orig;
    HBLogDebug(@" = %@", r);

    if ([self.name isEqual:@"WH-1000XM3"]){
        NSArray *options = [NSArray arrayWithObjects:@"AVOutputDeviceBluetoothListeningModeNormal",
                            @"AVOutputDeviceBluetoothListeningModeActiveNoiseCancellation",
                            @"AVOutputDeviceBluetoothListeningModeAudioTransparency",
                            nil];

        NSArray *accessories = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];
        NSLog( @"acessories %@", accessories);
        for (EAAccessory *accessory in accessories) {
            NSLog(@"acessory: %@", [accessory modelNumber]);
            if ([[accessory modelNumber] isEqual: @"WH-1000XM3"]){
                NSLog(@"hooray");
            }
        }

        return options;
    }

    return r;
}

-(BOOL)setCurrentBluetoothListeningMode:(id)arg1 error:(id*)arg2  { %log; BOOL r = %orig; HBLogDebug(@" = %d", r); return r; }

-(id)currentBluetoothListeningMode { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
-(void)setCurrentBluetoothListeningMode:(id)arg1  { %log; %orig; }
%end
