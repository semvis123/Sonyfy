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
    switch (eventCode) {
        case NSStreamEventNone:
            NSLog(@"~~~~~~~~ nothing here lol ~~~~~~");
            break;
        case NSStreamEventOpenCompleted:
            NSLog(@"~~~~~~~ Stream opened ~~~~~~~");
            break;
        case NSStreamEventHasBytesAvailable:
            {
                uint8_t buf[1024];
                NSMutableData *readData = [[NSMutableData alloc] init];
                
                while ([(NSInputStream *)stream hasBytesAvailable]) {
                    NSUInteger bytesRead = [(NSInputStream *)stream read:buf
                                                            maxLength:1024];
                    [readData appendBytes:buf length:bytesRead];
                }
                NSLog(@"~~~~~~~ Read: %@", readData); 
            }
            break;
        case NSStreamEventHasSpaceAvailable:
            {
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
                NSLog(@"~~~~~~~ Send: %zd, size of data: %zd", [(NSOutputStream *)stream write:myByteArray maxLength:sizeof(myByteArray)], sizeof(myByteArray));
                [(NSOutputStream *)stream close];
                [(NSOutputStream *)stream setDelegate:nil];
            }
            break;
        case NSStreamEventErrorOccurred:
            NSLog(@"~~~~~~~ Error occurred :(");
            break;
        case NSStreamEventEndEncountered:
            NSLog(@"~~~~~~~ End occurred  ~~~~~~~");
            break;
        default:
            NSLog(@"~~~~~~~ other event ??? ~~~~~");
            break;
    }
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
                EASession *session = [[EASession alloc] initWithAccessory:accessory forProtocol:@"jp.co.sony.audio.companion.tandem"];
                if (session)
                {
                    Delegate *delegate = [[Delegate alloc] init];
                    [[session inputStream] setDelegate:delegate];
                    [[session inputStream] scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
                    [[session inputStream] open];
                    [[session outputStream] setDelegate:delegate];
                    [[session outputStream] scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
                    [[session outputStream] open];
                    while(![session outputStream].hasSpaceAvailable){
                        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
                    }
                    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
                    [[session inputStream] close];
                    [[session outputStream] close];
                    [[session inputStream] removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
                    [[session outputStream] removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
                    [[session inputStream] setDelegate:nil];
                    [[session outputStream] setDelegate:nil];
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
