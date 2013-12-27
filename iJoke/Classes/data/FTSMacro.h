//
//  FTSMacro.h
//  iJoke
//
//  Created by Kyle on 13-7-29.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <Foundation/Foundation.h>

#undef weak_delegate
#undef __weak_delegate

#if __has_feature(objc_arc_weak) && \
(!(defined __MAC_OS_X_VERSION_MIN_REQUIRED) || \
__MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_8)
#define weak_delegate weak
#define __weak_delegate __weak
#else
#define weak_delegate unsafe_unretained
#define __weak_delegate __unsafe_unretained
#endif



//notification

#define kLoginStateChange @"joke.login.state.change"
#define kNetworkStateChangeTo3G @"3speed.network.state.3G"