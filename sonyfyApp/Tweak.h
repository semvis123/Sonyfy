#import <Foundation/Foundation.h>

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
-(id)getByteArray;
-(void)restoreFromPayloadWithByteArray: (IOSByteArray *)arg1;
@end

@interface THMSGV1T1NcAsmParam: NSObject
+(id) createWithPayloadWithByteArray: (IOSByteArray *)arg1;
@end

@interface THMSGV1T1SetNcAsmParam : THMSGV1T1Payload
-(id)initWithTHMSGV1T1NcAsmParamBase: (THMSGV1T1NcAsmParam *)arg1;
@end

@interface THMMdr: NSObject
-(void)sendCommandWithComSonySongpalTandemfamilyMessageMdrIPayload: (THMSGV1T1SetNcAsmParam *)arg1;
@end

@interface HPCNcAsmInformation
-(int)mAsmValue_;
-(id)valueForKey: (NSString *)key;
@end