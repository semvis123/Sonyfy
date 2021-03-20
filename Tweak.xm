#import <ExternalAccessory/ExternalAccessory.h>
#import <Foundation/Foundation.h>

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
- (NSInteger)write:(const uint8_t *)buffer maxLength:(NSUInteger)len{
    NSData *dataData = [NSData dataWithBytes:buffer length:sizeof(buffer)];
    NSLog(@"dataaaaaaaaaaaa = %@", dataData);
    // NSString *result = [[NSString alloc] initWithData:dataData encoding:NSUTF8StringEncoding];
    // NSLog(@"%@", result);
    return %orig;
}
%end

%hook EAInputStream
- (long long)read:(char *)arg1 maxLength:(unsigned long long)arg2 {
    long long r = %orig;
    NSData *dataData = [NSData dataWithBytes:arg1 length:sizeof(arg1)];
    NSLog(@"dataaaaaaaaaaaaaaaa read = %@", dataData);
    return r;
}
%end
%hook EASession
- (instancetype)initWithAccessory:(EAAccessory *)accessory forProtocol:(NSString *)protocolString {
%log;
return %orig;                          
}
%end

%hook ACCExternalAccessoryProvider
-(void)sendOutgoingExternalAccessoryData:(id)arg1 forEASessionIdentifier:(id)arg2 withReply:(/*^block*/ id)arg3 {
    %log;
    %orig;
}
%end

%hook THMSGV1T1SetNcAsmParam
-(id)getAsmValue{
    %log;
    return %orig;
}
-(id)getAsmType{
    %log;
    return %orig;
}
-(id)getAsmEffect{
    %log;
    return %orig;
}
-(id)getParameter{
    %log;
    return %orig;
}
+(id)init{
    %log;
    return %orig;
}
%end
%hook THMSGV1T1SetNcAsmParam
-(void)restoreFromPayloadWithByteArray:(id)arg1 {
    %log;
    %orig;
}
-(id)initWithTHMSGV1T1NcAsmParamBase:(id)arg1 {
    %log;
    return %orig;
}
// -(unsigned char *)getByteArray {
//     // %log;
//     // unsigned char* r = %orig;
//     // // NSLog(@"%@",r);
//     // NSMutableString * str = [NSMutableString string];
//     // for (int i = 0; i<sizeof(r); i++)
//     // {
//     //     [str appendFormat:@"%d ", r[i]];
//     // }

//     // NSLog(@"%@",str);
//     // return r;
// }
%end

@interface THMSGV1T1Payload : NSObject
-(id)dataType;
-(id)getByteArray;
-(id)getCommandStream;
-(id)getCommandType;
-(id)initWithByte: (int)arg1;
-(void)restoreFromPayloadWithByteArray: (const char *)arg1;
@end

@interface THMSGV1T1NcAsmParam: NSObject
+(id) createWithPayloadWithByteArray: (const char *)arg1;
@end
@interface THMSGV1T1SetNcAsmParam : THMSGV1T1Payload
-(id)initWithTHMSGV1T1NcAsmParamBase: (THMSGV1T1NcAsmParam *)arg1;
@end

%hook THMMdr
-(void)sendCommandWithComSonySongpalTandemfamilyMessageMdrIPayload:(id)arg1{
    if ([NSStringFromClass([arg1 class]) isEqual:@"THMSGV1T1SetNcAsmParam"]){
        const char bytes1[] = {0x68, 0x2, 0x11, 0x2, 0x2, 0x1, 0x0, 0x0};
        NSLog(@"Trueeeee");
        NSLog(@"%@",[arg1 getByteArray]);
        // NSLog(@"%@",[arg1 getCommandStream]);

        THMSGV1T1SetNcAsmParam *myPayload = [[%c(THMSGV1T1SetNcAsmParam) alloc] initWithTHMSGV1T1NcAsmParamBase:[%c(THMSGV1T1NcAsmParam) createWithPayloadWithByteArray: bytes1]];
        NSLog(@"succesfully payload created?");
        // NSLog(@"%@",[myPayload getByteArray]);
        NSLog(@"succesfully payload created??");
        [myPayload restoreFromPayloadWithByteArray: bytes1];
        NSLog(@"%@",[myPayload getByteArray]);
        // return %orig(myPayload);
    }
    // %log;
    // NSLog(@"%@", [arg1 class]);
    %orig;
}

%end
%ctor {
    NSLog(@"loaded tweak here ");
}
// asm - ambient sound mode
// asc - adaptive sound control (location/movement based changing)
// hpc - HeadPhonesControl


//____________________________________________

// [0x68, 0x2, 0x0, 0x2, 0x0, 0x1, 0x1, 0x14] asm off 
// [0x68, 0x2, 0x0, 0x2, 0x0, 0x1, 0x0, 0x14] asm off
// [0x68, 0x2, 0x1, 0x2, 0x0, 0x1, 0x1, 0x14] asm on slider on 20 focus on voice
// [0x68, 0x2, 0x1, 0x2, 0x0, 0x1, 0x0, 0x14] asm on slider on 20 from asm off
// [0x68, 0x2, 0x11, 0x2, 0x2, 0x1, 0x0, 0x0] nc slider on 0 dual
// [0x68, 0x2, 0x11, 0x2, 0x1, 0x1, 0x0, 0x0] nc slider on 1 single
// [0x68, 0x2, 0x11, 0x2, 0x0, 0x1, 0x0, 0x2] nc slider on 2 off
// [0x68, 0x2, 0x11, 0x2, 0x0, 0x1, 0x0, 0x14] asm slider on 20
// [0x68, 0x2, 0x11, 0x2, 0x0, 0x1, 0x1, 0x14] focus on voice

// [commandtype, start2, sendstate, 0x2?, NC_DUAL_SINGLE_VALUE, ASM_SETTING_TYPE(0x1), FocusVoice, asmlevel]
