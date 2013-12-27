//
//  FTSUserCenter.m
//  iJoke
//
//  Created by Kyle on 13-7-30.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSUserCenter.h"

@implementation FTSUserCenter



+(int)intValueForKey:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}
+(void)setIntValue:(int)value forKey:(NSString *)key{
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



+(CGFloat)floatValueForKey:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults] floatForKey:key];
}
+(void)setFloatVaule:(CGFloat)value forKey:(NSString *)key{
    [[NSUserDefaults standardUserDefaults] setFloat:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



+(BOOL)BoolValueForKey:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];

}
+(void)setBoolVaule:(BOOL)value forKey:(NSString *)key{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];

}



+(id)objectValueForKey:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}
+(void)setObjectValue:(id)value forKey:(NSString *)key{
    if (!value||!key) {
        BqsLog(@"setObjectValue has null vale=%@, key=%@",value,key);
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
