//
//  GridData.m
//  iJoke
//
//  Created by Kyle on 13-11-6.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "GridData.h"

//@property (nonatomic,strong) NSString *name;
//@property (nonatomic,strong) NSString *iconUrl;
//@property (nonatomic,assign) gridType type;

@implementation GridData

- (NSString *)description{
    
    return [NSString stringWithFormat:@"[GridData name:%@, iconUrl:%@, type:%d]",self.name,self.iconUrl,self.type];
}

@end
