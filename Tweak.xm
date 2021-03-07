#import <ExternalAccessory/ExternalAccessory.h>


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
            NSLog(@"~~~~~~~ free space here");
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


@interface AVOutputDevice : NSObject
-(void)setCurrentBluetoothListeningMode:(NSString *)arg1;
-(NSString *)name;
@property (nonatomic, retain) EASession *session;
@property (nonatomic, retain) Delegate *delegate;
@end


%hook AVOutputDevice
%property (nonatomic, retain) EASession *session;
%property (nonatomic, retain) Delegate *delegate;

-(id)availableBluetoothListeningModes {
    %log;
    id r = %orig;
    NSLog(@" = %@", r);

    if ([self.name isEqual:@"WH-1000XM3"]){

        NSArray *accessories = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];
        NSLog( @"acessories %@", accessories);
        for (EAAccessory *accessory in accessories) {
            NSLog(@"acessory: %@", [accessory modelNumber]);
            NSLog(@"%@", [accessory protocolStrings]);
            if ([[accessory modelNumber] isEqual: @"WH-1000XM3"]){
                self.session = [[EASession alloc] initWithAccessory:accessory forProtocol:@"jp.co.sony.songpal.mdr.link"];
                if (self.session)
                {
                    self.delegate = [Delegate new];
                    [[self.session inputStream] setDelegate:self.delegate];
                    [[self.session inputStream] scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
                    [[self.session inputStream] open];

                    [[self.session outputStream] setDelegate:self.delegate];
                    [[self.session outputStream] scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
                    [[self.session outputStream] open];
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

-(BOOL)setCurrentBluetoothListeningMode:(id)arg1 error:(id*)arg2  {
    %log;
    BOOL r = %orig;
    NSLog(@" = %d", r);
    NSLog(@"Set current bluetooth listening mode");
    if (self.session){
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
        NSLog(@"~~~~~~~ Send: %zd, size of data: %zd", [[self.session outputStream] write:myByteArray maxLength:sizeof(myByteArray)], sizeof(myByteArray));
        while(![self.session outputStream].hasSpaceAvailable){
            [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
        }
        [[self.session inputStream] close];
        [[self.session outputStream] close];
        [[self.session inputStream] removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [[self.session outputStream] removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [[self.session inputStream] setDelegate:nil];
        [[self.session outputStream] setDelegate:nil];
        self.session = nil;
        NSLog(@"closed session");
    }else{
        NSLog(@"session is nil");
    }
    return r; 
}

-(id)currentBluetoothListeningMode { %log; id r = %orig; NSLog(@" = %@", r); return r; }
-(void)setCurrentBluetoothListeningMode:(id)arg1  { %log; %orig; }
%end

// %hook HPCAsmInformation
// -(id)getAmbientSoundMode {
//     %log;
//     id r = %orig;
//     NSLog(@" = %@", r);
//     return r;   
// }
// %end

%hook EAOutputStream
- (long long)write:(const char *)arg1 maxLength:(unsigned long long)arg2 {
    NSData *dataData = [NSData dataWithBytes:arg1 length:sizeof(arg1)];
    NSLog(@"dataaaaaaaaaaaa = %@", dataData);
    NSString *result = [[NSString alloc] initWithData:dataData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", result);
    return %orig;
}
%end

// asm - ambient sound mode
// asc - adaptive sound control (location/movement based changing)
// hpc - HeadPhonesControl
// 0x3e01010000000001 -- Confirmation idk
// 0x3e0c000000000868 -- focus on voice OFF
// 0x3e01010000000002 -- Confirmation idk
// 0x3e0c010000000868 -- focus on voice ON


// 0x3e01010000000002 -- Confirmation idk
// 0x3e0c000000000868 -- focus on voice ON
// 0x3e01010000000001 -- Confirmation idk
// 0x3e0c010000000868 -- focus on voice ON

// 0x3e0c010000000868 -- control ON
// 0x3e01010000000002 -- Confirmation idk
