//
//  PanguAlterView.h
//  pangu
//
//  Created by yang zhiyun on 12-4-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMPopMsgView : NSObject


+(void)showPopMsg:(NSString *)msg;
+(void)showPopError:(NSError *)error;
+(void)showPopMsgError:(NSError*)err Msg:(NSString*)msg Delegate:(id)target ;
+(void)showPopMsgString:(NSString*)err Msg:(NSString*)msg Delegate:(id)target;
+(void)showPopMsgError:(NSError*)err Msg:(NSString*)msg RetMsg: (NSString*)retMsg RetStatus: (NSString*)retStatus;

+(void)showErrorAlert:(NSError*)err Msg:(NSString*)msg Delegate:(id)target;
+(void)showAlterError:(NSString*)err Msg:(NSString*)msg Delegate:(id)target ;
+(void)showAlertError:(NSError*)err Msg:(NSString*)msg RetMsg: (NSString*)retMsg RetStatus: (NSString*)retStatus;

+(UIAlertView *)showChaoseAlertError:(NSError*)err Msg:(NSString*)msg delegate:(id)delegate;

@end
