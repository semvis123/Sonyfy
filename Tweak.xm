#import <Tweak.h>


typedef struct __CFUserNotification *CFUserNotificationRef;
FOUNDATION_EXTERN CFUserNotificationRef CFUserNotificationCreate(CFAllocatorRef allocator, CFTimeInterval timeout, CFOptionFlags flags, SInt32 *error, CFDictionaryRef dictionary);
FOUNDATION_EXTERN SInt32 CFUserNotificationReceiveResponse(CFUserNotificationRef userNotification, CFTimeInterval timeout, CFOptionFlags *responseFlags);

bool isEnabled = true;
bool ignoreUpdate = false;
NSString *headphonesName = @"WH-1000XM3";

id NCStatusObserver;
id appLaunchedObserver;
id killAndRelaunchObserver;
NSString *shouldChangeToMode = @"";
NSString *currentListeningMode = @"AVOutputDeviceBluetoothListeningModeNormal";

%hook AVOutputDevice

-(id)availableBluetoothListeningModes {
	if (isEnabled && [self.name isEqual:headphonesName]){
		NSArray *options = [NSArray arrayWithObjects:@"AVOutputDeviceBluetoothListeningModeNormal",
							@"AVOutputDeviceBluetoothListeningModeActiveNoiseCancellation",
							@"AVOutputDeviceBluetoothListeningModeAudioTransparency",
							nil];
		return options;
	}
	return %orig;
}

-(BOOL)setCurrentBluetoothListeningMode:(id)arg1 error:(id*)arg2  {
	shouldChangeToMode = arg1;
	if (isEnabled && [self.name isEqual:headphonesName]){
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
	if (isEnabled && [self.name isEqual:headphonesName]){
		dispatch_async(dispatch_get_main_queue(), ^{
			[[UIApplication sharedApplication] launchApplicationWithIdentifier:@"jp.co.sony.songpal.mdr" suspended:1];
		});
		return currentListeningMode; 
	}
	return %orig;
}
%end

static void updatePrefs() {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.semvis123.sonyfypreferences.plist"];
	if(prefs){
		isEnabled = [prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] boolValue] : isEnabled;
		headphonesName = [prefs objectForKey:@"headphonesName"] ? [prefs objectForKey:@"headphonesName"] : headphonesName;
		ignoreUpdate = [prefs objectForKey:@"ignoreUpdate"] ? [[prefs objectForKey:@"ignoreUpdate"] boolValue] : ignoreUpdate;
		if(isEnabled){
			dispatch_async(dispatch_get_main_queue(), ^{
				[[UIApplication sharedApplication] launchApplicationWithIdentifier:@"jp.co.sony.songpal.mdr" suspended:1];
			});
		}
	}
}


%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)updatePrefs, CFSTR("com.semvis123.sonyfypreferences/update"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	updatePrefs();
	NCStatusObserver = [[objc_getClass("NSDistributedNotificationCenter") defaultCenter] addObserverForName:@"com.semvis123.sonyfy/NCStatus" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
		currentListeningMode = [notification.userInfo objectForKey:@"mode"];
		if ([shouldChangeToMode isEqualToString:[notification.userInfo objectForKey:@"mode"]]){
			shouldChangeToMode = @"";
		}
	}];
	killAndRelaunchObserver = [[objc_getClass("NSDistributedNotificationCenter") defaultCenter] addObserverForName:@"com.semvis123.sonyfy/killAndRelaunch" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
    	BKSTerminateApplicationForReasonAndReportWithDescription(@"jp.co.sony.songpal.mdr", 1, 0, 0);
		dispatch_async(dispatch_get_main_queue(), ^{
			[[UIApplication sharedApplication] launchApplicationWithIdentifier:@"jp.co.sony.songpal.mdr" suspended:1];
		});
	}];
	appLaunchedObserver = [[objc_getClass("NSDistributedNotificationCenter") defaultCenter] addObserverForName:@"com.semvis123.sonyfy/appLaunched" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
		if (![shouldChangeToMode isEqualToString:@""]){
			NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
			[userInfo setObject:shouldChangeToMode forKey:@"mode"];
			[[objc_getClass("NSDistributedNotificationCenter") defaultCenter]
				postNotificationName:@"com.semvis123.sonyfy/setNC"
				object:nil
				userInfo:userInfo
				deliverImmediately:YES]; 
		}
	}];
	if (!ignoreUpdate){
		CFUserNotificationRef postinstNotification = CFUserNotificationCreate(kCFAllocatorDefault, 0, 0, NULL, (__bridge CFDictionaryRef)[[NSDictionary alloc] initWithObjectsAndKeys:
			@"🎧 Friendly note 🎧", @"AlertHeader",
			@"There's an update available for Sonyfy, it's called 'Sonitus' and it's better :) \n It's available for free! \n (you can ignore this update by toggling a setting)", @"AlertMessage",
			@"Okay, I understand!", @"DefaultButtonTitle", nil]);
		CFUserNotificationReceiveResponse(postinstNotification, 0.001, NULL);
	}
}

%dtor {
	[[objc_getClass("NSDistributedNotificationCenter") defaultCenter] removeObserver:NCStatusObserver name:@"com.semvis123.sonyfy/NCStatus" object:nil ];
	[[objc_getClass("NSDistributedNotificationCenter") defaultCenter] removeObserver:appLaunchedObserver name:@"com.semvis123.sonyfy/appLaunched" object:nil ];
	[[objc_getClass("NSDistributedNotificationCenter") defaultCenter] removeObserver:killAndRelaunchObserver name:@"com.semvis123.sonyfy/killAndRelaunch" object:nil ];
}
