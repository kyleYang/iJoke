//
//  NGMoviePlayerViewController.h
//  NGMoviePlayerDemo
//
//  Created by Tretter Matthias on 13.03.12.
//  Copyright (c) 2012 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NGMoviePlayer.h"
#import "NGWeak.h"
#import "NGMoviePlayerAudioSessionCategory.h"

typedef enum
{
    NGMoviePlayerrUnknowed,
    NGMoviePlayerCancelled,
    NGMoviePlayerFinished,
    NGMoviePlayerURLError,
    NGMoviePlayerFailed,
} NGMoviePlayerResult;

@class News;
@class Video;


@protocol MoviePlayerViewControllerDelegate;

@interface FTSMoviePlayerViewController : UIViewController <NGMoviePlayerDelegate>{
    BOOL                bSuperOrientFix;
    CGFloat             ad_x;         //-1 means center in horizontal
    CGFloat             ad_y;         //-1 means center in vertical
    BOOL                _setVideo;
    
    
}

@property (nonatomic, assign) BOOL bSuperOrientFix;
@property (nonatomic, strong) NSArray *dataArray;

- (id)initWithVideo:(Video *)vide;
- (id)initWithVideo:(Video *)vide videoArray:(NSArray*)array;
- (id)initWithUrl:(NSString *)url title:(NSString *)title;

@property (nonatomic, weak_delegate) id<MoviePlayerViewControllerDelegate> delegate;

@end



@protocol MoviePlayerViewControllerDelegate <NSObject>

@required
- (void)moviePlayerViewController:(FTSMoviePlayerViewController*)ctl didFinishWithResult:(NGMoviePlayerResult)result error:(NSError *)error;

@optional


@end

