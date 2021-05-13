#import <Tweak.h>

bool isEnabled = true;
NSString *headphonesName = @"WH-1000XM3";

id NCStatusObserver;
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

static void updatePrefs()
{
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.semvis123.sonyfypreferences.plist"];
	if(prefs)
	{
		isEnabled = [prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] boolValue] : isEnabled;
		headphonesName = [prefs objectForKey:@"headphonesName"] ? [prefs objectForKey:@"headphonesName"] : headphonesName;
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
	}];
}

%dtor {
	[[objc_getClass("NSDistributedNotificationCenter") defaultCenter] removeObserver:NCStatusObserver name:@"com.semvis123.sonyfy/NCStatus" object:nil ];
}