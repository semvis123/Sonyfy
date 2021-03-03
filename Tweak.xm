#import <ExternalAccessory/ExternalAccessory.h>

#define HBLogDebug NSLog


@interface AVOutputDevice : NSObject
-(void)setCurrentBluetoothListeningMode:(NSString *)arg1;
-(NSString *)name;
@end


@interface Delegate : NSObject <NSStreamDelegate> {
@public
}
@end

@implementation Delegate {
}
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode  {
    NSLog(@"############# in DELEGATE###############");
}

@end



%hook AVOutputDevice
-(id)availableBluetoothListeningModes {
    %log;
    id r = %orig;
    HBLogDebug(@" = %@", r);

    if ([self.name isEqual:@"WH-1000XM3"]){

        NSArray *accessories = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];
        NSLog( @"acessories %@", accessories);
        for (EAAccessory *accessory in accessories) {
            NSLog(@"acessory: %@", [accessory modelNumber]);
            if ([[accessory modelNumber] isEqual: @"WH-1000XM3"]){
                NSLog(@"hooray");
                EASession *session = [[EASession alloc] initWithAccessory:accessory forProtocol:@"jp.co.sony.songpal.mdr.link"];
                if (session)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        Delegate *delegate;
                        [[session inputStream] setDelegate:delegate];
                        [[session inputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                        [[session inputStream] open];

                        [[session outputStream] setDelegate:delegate];
                        [[session outputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                        [[session outputStream] open];
                        bool enabled = true;
                        int noiseCancelling = 2;
                        bool voice = false;
                        int volume = 0;
                        const Byte myByteArray[] = {
                            0x00, 0x00, 0x00,
                            0x08, 0x68, 0x02,
                            (Byte) (enabled ? 0x10 : 0x00),
                            0x02, (Byte) (noiseCancelling),
                            0x01, (Byte) (voice ? 1 : 0),
                            (Byte) volume };

                        while(![session outputStream].hasSpaceAvailable){
                            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
                        }

                        NSLog(@"send: %zd, size of data: %zd", [[session outputStream] write:myByteArray maxLength:sizeof(myByteArray)], sizeof(myByteArray));
                        [[session inputStream] close];
                        [[session outputStream] close];
                        [[session inputStream] setDelegate:nil];
                        [[session outputStream] setDelegate:nil];
                    });

                }
            }
        }

        NSArray *options = [NSArray arrayWithObjects:@"AVOutputDeviceBluetoothListeningModeNormal",
                            @"AVOutputDeviceBluetoothListeningModeActiveNoiseCancellation",
                            @"AVOutputDeviceBluetoothListeningModeAudioTransparency",
                            nil];
        return options;
    }

    return r;
}

-(BOOL)setCurrentBluetoothListeningMode:(id)arg1 error:(id*)arg2  { %log; BOOL r = %orig; HBLogDebug(@" = %d", r); return r; }

-(id)currentBluetoothListeningMode { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
-(void)setCurrentBluetoothListeningMode:(id)arg1  { %log; %orig; }
%end
