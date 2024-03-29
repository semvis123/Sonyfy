#import <Tweak.h>

static bool focusOnVoiceNC = false;
static bool focusOnVoiceASM = false;
static bool windReductionSupport = true;
static bool isEnabled = true;
static char NCValue = 0x0;
static char ASMValue = 0x14;
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
		char NCDualSingleValue = NCValue == 0 ? (windReductionSupport? 0x2: 0x1) : (NCValue == 1 ? 0x1 : 0x0);
		char ASMDualSingleValue = ASMValue == 0 ? (windReductionSupport? 0x2: 0x1) : (ASMValue == 1 ? 0x1 : 0x0);
		char NCSettingType = !windReductionSupport && NCValue == 0 ? 0x0 : 0x2;
		char ASMSettingType = !windReductionSupport && ASMValue == 0 ? 0x0 : 0x2;

		char dataNCOn[] = {0x68, 0x2, 0x11, NCSettingType, NCDualSingleValue, !!NCSettingType, focusOnVoiceNC, NCValue};
		char dataASMOn[] = {0x68, 0x2, 0x11, ASMSettingType, ASMDualSingleValue, !!ASMSettingType, focusOnVoiceASM, ASMValue};
		char dataASMOff[] = {0x68, 0x2, 0x0, 0x2, 0x0, 0x1, 0x0, 0x14};

		@try {
			IOSByteArray *byteArray;

			if ([[notification.userInfo objectForKey:@"mode"] isEqual:@"AVOutputDeviceBluetoothListeningModeAudioTransparency"]){
				byteArray = [%c(IOSByteArray) arrayWithBytes:dataASMOn count:8];
			} else if ([[notification.userInfo objectForKey:@"mode"] isEqual:@"AVOutputDeviceBluetoothListeningModeActiveNoiseCancellation"]){
				byteArray = [%c(IOSByteArray) arrayWithBytes:dataNCOn count:8];
			} else {
				byteArray = [%c(IOSByteArray) arrayWithBytes:dataASMOff count:8];
			}

			THMSGV1T1NcAsmParam *ncAsmParam = [%c(THMSGV1T1NcAsmParam) createWithPayloadWithByteArray:byteArray];
			THMSGV1T1SetNcAsmParam *setNcAsmParam = [[%c(THMSGV1T1SetNcAsmParam) alloc] initWithTHMSGV1T1NcAsmParamBase:ncAsmParam];
			[setNcAsmParam restoreFromPayloadWithByteArray:byteArray];

			[self sendCommandWithComSonySongpalTandemfamilyMessageMdrIPayload:setNcAsmParam];
			[[objc_getClass("NSDistributedNotificationCenter") defaultCenter]
				postNotificationName:@"com.semvis123.sonyfy/NCStatus"
				object:nil
				userInfo:notification.userInfo
				deliverImmediately:YES];
		} @catch(id e) {
			// Sometimes it doesn't respond to the method (bad timing ?) in that case catch the error, so we don't get a crash.
			// We can just relaunch the app and try again. 
			[[objc_getClass("NSDistributedNotificationCenter") defaultCenter]
				postNotificationName:@"com.semvis123.sonyfy/killAndRelaunch"
				object:nil
				userInfo:notification.userInfo
				deliverImmediately:YES];
		}
	}];

	[[objc_getClass("NSDistributedNotificationCenter") defaultCenter]
		postNotificationName:@"com.semvis123.sonyfy/appLaunched"
		object:nil
		userInfo:nil
		deliverImmediately:YES];
}

-(void)dealloc {
	[[objc_getClass("NSDistributedNotificationCenter") defaultCenter] removeObserver:setNCObserver name:@"com.semvis123.sonyfy/setNC" object:nil ];
	%orig;
}

%end


static void updatePrefs() {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.semvis123.sonyfypreferences.plist"];
	if(prefs)
	{
		isEnabled = [prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] boolValue] : isEnabled;
		focusOnVoiceASM = [prefs objectForKey:@"focusOnVoiceASM"] ? [[prefs objectForKey:@"focusOnVoiceASM"] boolValue] : focusOnVoiceASM;
		focusOnVoiceNC = [prefs objectForKey:@"focusOnVoiceNC"] ? [[prefs objectForKey:@"focusOnVoiceNC"] boolValue] : focusOnVoiceNC;
		NCValue = [prefs objectForKey:@"NCValue"] ? [[prefs objectForKey:@"NCValue"] intValue] : NCValue;
		ASMValue = [prefs objectForKey:@"ASMValue"] ? [[prefs objectForKey:@"ASMValue"] intValue] : ASMValue;
		windReductionSupport = [prefs objectForKey:@"windReductionSupport"] ? [[prefs objectForKey:@"windReductionSupport"] boolValue] : windReductionSupport;
	}
}


%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)updatePrefs, CFSTR("com.semvis123.sonyfypreferences/update"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	updatePrefs();
}
