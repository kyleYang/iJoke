//
//  NSString+TimeInterval.m
//  iJoke
//
//  Created by Kyle on 13-11-23.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "NSString+TimeInterval.h"

@implementation NSString(TimeInterval)

-(NSString*)noticeTimeIntervalFromCurrent{
    
//    "joke.commit.current" = "刚刚";
//    "joke.commit.minutes" = "%d 分钟前";
//    "joke.commit.hours" = "%d 小时前";
//    "joke.commit.days" = "%d 天前";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:self];

    NSTimeInterval timerInterval = [[NSDate date] timeIntervalSinceDate:date];
    
    NSInteger minutes = timerInterval / 60;
    NSInteger hours = minutes / 60;
    NSInteger days = hours/24;
    
    minutes = ((NSInteger)minutes) % 60;
    
    
    if (days >= 3) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        return [dateFormatter stringFromDate:date];
        
    }else if (days > 0) {
        return [NSString stringWithFormat:NSLocalizedString(@"joke.commit.minutes", nil),days];
            
    }else if (hours > 0) {
        return [NSString stringWithFormat:NSLocalizedString(@"joke.commit.hours", nil),hours];
        
    }else if (minutes > 5) {
        return [NSString stringWithFormat:NSLocalizedString(@"joke.commit.minutes", nil),minutes];
        
    }else{
        return NSLocalizedString(@"joke.commit.current", nil);
    }
  
}

-(NSString*)timeFromatToDay{

    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:self];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    return [dateFormatter stringFromDate:date];

    

}






//-(NSString*)TimeIntervalFromDate:(NSDate *)beforeDate{
//    
//    //    "joke.commit.current" = "刚刚";
//    //    "joke.commit.minutes" = "%d 分钟前";
//    //    "joke.commit.hours" = "%d 小时前";
//    //    "joke.commit.days" = "%d 天前";
//    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSDate *date = [dateFormatter dateFromString:self];
//    
//    NSTimeInterval timerInterval = [beforeDate timeIntervalSinceDate:date];
//    
//    NSInteger minutes = timerInterval / 60;
//    NSInteger hours = minutes / 60;
//    NSInteger days = hours/24;
//    NSInteger mounths = days/30;
//    NSInteger years = mounths/23;
//    
//    minutes = ((NSInteger)minutes) % 60;
//    
//    
//    if (years > 0 || mounths >0 || days > 10) {
//        return self;
//        
//    }else if (days > 0) {
//        return [NSString stringWithFormat:NSLocalizedString(@"joke.commit.minutes", nil),days];
//        
//    }else if (hours > 0) {
//        return [NSString stringWithFormat:NSLocalizedString(@"joke.commit.hours", nil),days];
//    }else if (minutes > 5) {
//        return [NSString stringWithFormat:NSLocalizedString(@"joke.commit.minutes", nil),days];
//    }else{
//        return NSLocalizedString(@"joke.commit.current", nil);
//    }
//    
//}
//






@end
