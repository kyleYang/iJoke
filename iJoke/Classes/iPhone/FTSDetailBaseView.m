//
//  FTSDetailBaseView.m
//  iJoke
//
//  Created by Kyle on 13-8-3.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSDetailBaseView.h"

@interface FTSDetailBaseView()


@property (nonatomic, strong, readwrite) Downloader *downloader;

@end


@implementation FTSDetailBaseView

- (id)initWithFrame:(CGRect)frame withIdentifier:(NSString *)ident withController:(UIViewController *)ctrl
{
    self = [super initWithFrame:frame withIdentifier:ident withController:ctrl];
    if (nil == self) return nil;
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:self.bounds];
    bg.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    bg.image = [[Env sharedEnv] cacheScretchableImage:@"background.png" X:20 Y:10];
    [self addSubview:bg];

    self.downloader = [[Downloader alloc] init];
    self.downloader.bSearialLoad = YES;
    
    return self;
}

 /**
  *	instance method ,must be rewrite
  *
  *	@param	bLoadMore	yes,load More, no fresh
  */

-(void)loadNetworkDataMore:(BOOL)bLoadMore{
    
}

- (BOOL)loadLocalDataNeedFresh{
    return TRUE;
}


 /**
  *	ASIHTTPRequest 
  *
  *	@param	request
  */

- (void)viewWillDisappear{
    [self.downloader cancelAll];
    [super viewWillDisappear];
}



@end
