#import <Foundation/Foundation.h>
#import <Tweak.h>

bool focusOnVoiceNC = false;
bool focusOnVoiceASM = false;
bool isEnabled = true;
int NCValue = 0;
int ASMValue = 20;
HPCNcAsmInformation *NcAsmInformation;

%hook HPCNcAsmInformation

+(id)alloc {
    NcAsmInformation = %orig;
    return NcAsmInformation;
}

-(void)dealloc {
    if (NcAsmInformation){
        NSString *currentMode;
        if (![[[NcAsmInformation valueForKey:@"mSendStatus_"] description] isEqualToString:@"OFF"]){
            if ([[[NcAsmInformation valueForKey:@"mNoiseCancellingAsmMode_"] description] isEqualToString:@"ASM"]){
                currentMode = @"AVOutputDeviceBluetoothListeningModeAudioTransparency";
            } else {
                currentMode = @"AVOutputDeviceBluetoothListeningModeActiveNoiseCancellation";
            }
        } else {
            currentMode = @"AVOutputDeviceBluetoothListeningModeNormal";
        }
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:currentMode forKey:@"mode"];

        [[objc_getClass("NSDistributedNotificationCenter") defaultCenter]
            postNotificationName:@"com.semvis123.sonyfy/NCStatus"
            object:nil
            userInfo: userInfo
            deliverImmediately:YES];
    }
    %orig;
}
%end


%hook THMMdr
id setNCObserver;
-(void)start {
    %orig;
    setNCObserver = [[objc_getClass("NSDistributedNotificationCenter") defaultCenter] addObserverForName:@"com.semvis123.sonyfy/setNC" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        const char dataNCOn[] = {0x68, 0x2, 0x11, 0x2, 0x2, 0x1, focusOnVoiceNC, static_cast<char>(NCValue)};
        const char dataASMOn[] = {0x68, 0x2, 0x11, 0x2, 0x0, 0x1, focusOnVoiceASM, static_cast<char>(ASMValue)};
        const char dataASMOff[] = {0x68, 0x2, 0x0, 0x2, 0x0, 0x1, 0x0, 0x14};
        NSLog(@"NCValue: %d", NCValue);
        NSLog(@"ASMValue: %d", ASMValue);
        IOSByteArray *byteArray;

        if ([[notification.userInfo objectForKey:@"mode"] isEqual:@"AVOutputDeviceBluetoothListeningModeAudioTransparency"]){
            byteArray = [%c(IOSByteArray) arrayWithBytes: dataASMOn count: 8];
        } else if ([[notification.userInfo objectForKey:@"mode"] isEqual:@"AVOutputDeviceBluetoothListeningModeActiveNoiseCancellation"]){
            byteArray = [%c(IOSByteArray) arrayWithBytes: dataNCOn count: 8];
        } else {
            byteArray = [%c(IOSByteArray) arrayWithBytes: dataASMOff count: 8];
        }
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:[notification.userInfo objectForKey:@"mode"] forKey:@"mode"];
        [[objc_getClass("NSDistributedNotificationCenter") defaultCenter]
            postNotificationName:@"com.semvis123.sonyfy/NCStatus"
            object:nil
            userInfo: userInfo
            deliverImmediately:YES];
        THMSGV1T1NcAsmParam *ncAsmParam = [%c(THMSGV1T1NcAsmParam) createWithPayloadWithByteArray: byteArray];
        THMSGV1T1SetNcAsmParam *setNcAsmParam = [[%c(THMSGV1T1SetNcAsmParam) alloc] initWithTHMSGV1T1NcAsmParamBase:ncAsmParam];
        [setNcAsmParam restoreFromPayloadWithByteArray: byteArray];

        [self sendCommandWithComSonySongpalTandemfamilyMessageMdrIPayload: setNcAsmParam];
    }];
}
-(void) dealloc {
    [[objc_getClass("NSDistributedNotificationCenter") defaultCenter] removeObserver:setNCObserver name:@"com.semvis123.sonyfy/setNC" object:nil ];
    %orig;
}
%end


static void updateAppPrefs()
{
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.semvis123.sonyfypreferences.plist"];
    if(prefs)
    {
        focusOnVoiceASM = [prefs objectForKey:@"focusOnVoiceASM"] ? [[prefs objectForKey:@"focusOnVoiceASM"] boolValue] : focusOnVoiceASM;
        focusOnVoiceNC = [prefs objectForKey:@"focusOnVoiceNC"] ? [[prefs objectForKey:@"focusOnVoiceNC"] boolValue] : focusOnVoiceNC;
        NCValue = [prefs objectForKey:@"NCValue"] ? [[prefs objectForKey:@"NCValue"] intValue] : NCValue;
        ASMValue = [prefs objectForKey:@"ASMValue"] ? [[prefs objectForKey:@"ASMValue"] intValue] : ASMValue;
    }
}

static void updateGlobalPrefs()
{
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.semvis123.sonyfypreferences.plist"];
    if(prefs)
    {
        isEnabled = [prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] boolValue] : isEnabled;
    }
}


%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)updateGlobalPrefs, CFSTR("com.semvis123.sonyfypreferences/update"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    updateGlobalPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)updateAppPrefs, CFSTR("com.semvis123.sonyfypreferences/updateApp"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    updateAppPrefs();
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