#import <Foundation/Foundation.h>
#import <rocketbootstrap/rocketbootstrap.h>

@interface CPDistributedMessagingCenter : NSObject
+ (id)centerNamed:(id)arg1;
-(BOOL)sendMessageName:(NSString*)name userInfo:(NSDictionary*)info;
-(void)runServerOnCurrentThread;
-(void)registerForMessageName:(NSString*)messageName target:(id)target selector:(SEL)selector;
@end

@interface IOSByteArray
+(id)arrayWithBytes:(const char *)ints count:(NSUInteger)count;
@end

@interface THMSGV1T1Payload : NSObject
-(void)restoreFromPayloadWithByteArray: (IOSByteArray *)arg1;
@end

@interface THMSGV1T1NcAsmParam: NSObject
+(id) createWithPayloadWithByteArray: (IOSByteArray *)arg1;
@end

@interface THMSGV1T1SetNcAsmParam : THMSGV1T1Payload
-(id)initWithTHMSGV1T1NcAsmParamBase: (THMSGV1T1NcAsmParam *)arg1;
@end

@interface THMMdr
+(id)sharedInstance;
-(void)sendCommandWithComSonySongpalTandemfamilyMessageMdrIPayload: (THMSGV1T1SetNcAsmParam *)arg1;
-(void)setNowPls: (id)withUserInfo;
@end

%hook THMMdr
static THMMdr *__weak sharedInstance;

-(void)start {
    %orig;
    NSLog(@"jjjjjjj");
    sharedInstance = self;

    const char dataASMOn[] = {0x68, 0x2, 0x11, 0x2, 0x0, 0x1, 0x0, 0x14};
    IOSByteArray * byteArray = [%c(IOSByteArray) arrayWithBytes: dataASMOn count: 8];
    THMSGV1T1NcAsmParam *ncAsmParam = [%c(THMSGV1T1NcAsmParam) createWithPayloadWithByteArray: byteArray];
    THMSGV1T1SetNcAsmParam *setNcAsmParam = [[%c(THMSGV1T1SetNcAsmParam) alloc] initWithTHMSGV1T1NcAsmParamBase:ncAsmParam];
    [setNcAsmParam restoreFromPayloadWithByteArray: byteArray];

    [self sendCommandWithComSonySongpalTandemfamilyMessageMdrIPayload: setNcAsmParam];

    CPDistributedMessagingCenter * messagingCenter = [%c(CPDistributedMessagingCenter) centerNamed:@"com.semvis123.sonyfy"];
    rocketbootstrap_distributedmessagingcenter_apply(messagingCenter);
    [messagingCenter runServerOnCurrentThread];
	[messagingCenter registerForMessageName:@"setNowPls" target:self selector:@selector(setNowPls:withUserInfo:)];
}

%new
+(id)sharedInstance{
    return sharedInstance;
}
-(void)setNowPls: (id)withUserInfo{
    %log;
    NSLog(@"AAAAAAAAAaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
}
%end
%ctor {
    NSLog(@"from the app");
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
// [commandtype, 0x2?, sendstate, 0x2?, NC_DUAL_SINGLE_VALUE, ASM_SETTING_TYPE(0x1), FocusVoice, asmlevel]