#import <Foundation/Foundation.h>
#import <rocketbootstrap/rocketbootstrap.h>

@interface NSDistributedNotificationCenter : NSNotificationCenter
+(id)defaultCenter;
-(void)postNotificationName:(id)arg1 object:(id)arg2 userInfo:(id)arg3 deliverImmediately:(BOOL)arg4;
-(void)addObserver:(id)arg1 selector:(SEL)arg2 name:(id)arg3 object:(id)arg4;
-(void)postNotificationName:(id)arg1 object:(id)arg2 userInfo:(id)arg3;
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
-(void)sendCommandWithComSonySongpalTandemfamilyMessageMdrIPayload: (THMSGV1T1SetNcAsmParam *)arg1;
@end

%hook HPCNcAsmInformation
-(id)copyWithNcAsmEffectWithTHMSGV1T1NcAsmEffect: (id)arg1{
    %log;
    id org = %orig;
    NSLog(@"%@", org);
    return org;
}
%end


%hook THMMdr
static THMMdr *__weak sharedInstance;


-(void)start {
    %orig;
    	[[NSDistributedNotificationCenter defaultCenter]
            addObserver:self
            selector:@selector(notificationReceived:) 
            name:@"com.semvis123.sonyfy/setNC"
            object:nil];

//     [[objc_getClass("NSDistributedNotificationCenter") defaultCenter] addObserver:(id)observer 
//            selector:(SEL)selector 
//                name:(NSNotificationName)name 
//              object:(NSString *)object 
//  suspensionBehavior:(NSNotificationSuspensionBehavior)suspensionBehavior;
//     [[objc_getClass("NSDistributedNotificationCenter") defaultCenter] addObserverForName:@"com.semvis123.sonyfy/setNC" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
//         NSLog(@"Received NSDistributedNotificationCenter message %@", [notification.userInfo objectForKey:@"mode"]);
//         const char dataASMOn[] = {0x68, 0x2, 0x11, 0x2, 0x0, 0x1, 0x0, 0x14};
//         const char dataNCOn[] = {0x68, 0x2, 0x11, 0x2, 0x2, 0x1, 0x0, 0x0};
//         const char dataASMOff[] = {0x68, 0x2, 0x0, 0x2, 0x0, 0x1, 0x0, 0x14};
//         IOSByteArray * byteArray;

//         if ([[notification.userInfo objectForKey:@"mode"] isEqual:@"AVOutputDeviceBluetoothListeningModeAudioTransparency"]){
//             NSLog(@"ooh transparantie lol");
//             byteArray = [%c(IOSByteArray) arrayWithBytes: dataASMOn count: 8];
//         }
//         else if ([[notification.userInfo objectForKey:@"mode"] isEqual:@"AVOutputDeviceBluetoothListeningModeActiveNoiseCancellation"]){
//             NSLog(@"NoiSeCancELling");
//             byteArray = [%c(IOSByteArray) arrayWithBytes: dataNCOn count: 8];
//         }
//         else {
//             NSLog(@"normal/off");
//             byteArray = [%c(IOSByteArray) arrayWithBytes: dataASMOff count: 8];
//         }
//         THMSGV1T1NcAsmParam *ncAsmParam = [%c(THMSGV1T1NcAsmParam) createWithPayloadWithByteArray: byteArray];
//         THMSGV1T1SetNcAsmParam *setNcAsmParam = [[%c(THMSGV1T1SetNcAsmParam) alloc] initWithTHMSGV1T1NcAsmParamBase:ncAsmParam];
//         [setNcAsmParam restoreFromPayloadWithByteArray: byteArray];

//         [self sendCommandWithComSonySongpalTandemfamilyMessageMdrIPayload: setNcAsmParam];
//     }];
}
%new 
-(void)notificationReceived: (NSDictionary *)userInfo {
    NSLog(@"hiero ==============================================================");
	// return [NSDictionary dictionaryWithObjectsAndKeys:@"key", @"object", nil];
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