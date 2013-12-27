//
//  FTSElementView.m
//  FTSGridViewExample
//
//  Created by Kyle on 13-7-31.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSGirdViewCell.h"
#import <QuartzCore/QuartzCore.h>

#define kMosaicDataViewFont @"Helvetica-Bold"

#define kIconWidth 20
#define kIconHeight 20


@interface FTSGirdViewCell()


@property (nonatomic, strong, readwrite) NSString *reuseIdentifier;
@property (nonatomic, strong, readwrite) UILabel *titleLabel;
@property (nonatomic, strong, readwrite) UIImageView *iconImageView;
@property (nonatomic, strong, readwrite) FlipView *flipView;
@end

@implementation FTSGirdViewCell

@synthesize reuseIdentifier = _reuseIdentifier;
@synthesize titleLabel = _titleLabel;
@synthesize flipView = _flipView;
@synthesize delegate = _delegate;
@synthesize iconImageView = _iconImageView;

- (void)setUp{
    
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = HexRGB(0xE5E3E1);
    [_titleLabel sizeToFit];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.shadowColor = [UIColor blackColor];
    _titleLabel.shadowOffset = CGSizeMake(0, 1);
    _titleLabel.numberOfLines = 0;
    [self addSubview:_titleLabel];
    
    _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _iconImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:_iconImageView];
    
    AnimationDelegate *animationDelegate = [[AnimationDelegate alloc] initWithSequenceType:kSequenceControlled
                                                           directionType:kDirectionForward];
    animationDelegate.controller = self;
    animationDelegate.perspectiveDepth = 2000;
    
//    _flipView = [[FlipView alloc] initWithAnimationType:kAnimationFlipHorizontal
//                                                       frame:self.bounds];
//    animationDelegate.transformView = _flipView;
//    [self addSubview:_flipView];

    
    //  Set stroke width
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.clipsToBounds = YES;
    
    
    //  Add double tap recognizer
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(doubleTapReceived:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTapRecognizer];
    
    //  Add simple tap recognizer. This will get call ONLY if the double tap fails, so it's got a little delay
    UITapGestureRecognizer *simpleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(simpleTapReceived:)];
    simpleTapRecognizer.numberOfTapsRequired = 1;
    [simpleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    simpleTapRecognizer.delegate = self;
    [self addGestureRecognizer:simpleTapRecognizer];


}



- (id)initReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super init];
    if (self) {
        _reuseIdentifier = reuseIdentifier;
        
        [self setUp];
    }
    return self;
}



- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rect = CGRectMake(0,0,CGRectGetWidth(self.bounds),CGRectGetHeight(self.bounds));
    _titleLabel.frame = rect;
    
    rect = CGRectMake(CGRectGetWidth(self.bounds)-kIconWidth-4, CGRectGetHeight(self.bounds)-kIconHeight-4, kIconWidth, kIconHeight);
    _iconImageView.frame = rect;
    
}

-(void)simpleTapReceived:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(fTSGirdViewCellDidTap:)]){
        [_delegate fTSGirdViewCellDidTap:self];
    }
}

-(void)doubleTapReceived:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(fTSGirdViewCellDidDoubleTap:)]){
        [_delegate fTSGirdViewCellDidDoubleTap:self];
    }
}



- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    //  Display the animation no matter if the gesture fails or not
    BOOL retVal = YES;
    
    /*  From http://developer.apple.com NSObject class reference
     *  You cannot test whether an object inherits a method from its superclass by sending respondsToSelector:
     *  to the object using the super keyword. This method will still be testing the object as a whole, not just
     *  the superclass’s implementation. Therefore, sending respondsToSelector: to super is equivalent to sending
     *  it to self. Instead, you must invoke the NSObject class method instancesRespondToSelector: directly on
     *  the object’s superclass */
    
    SEL aSel = @selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:);
    
    /*  You cannot simply use [[self superclass] instancesRespondToSelector:@selector(aMethod)]
     *  since this may cause the method to fail if it is invoked by a subclass. */
    
    if ([UIView instancesRespondToSelector:aSel]){
        retVal = [super gestureRecognizerShouldBegin:gestureRecognizer];
    }
    [self displayHighlightAnimation];
    return retVal;
}


-(void)displayHighlightAnimation{
    
    //  Notify to the rest of MosaicDataView which is the selected MosaicDataView
    //  (Usefull is you need to deselect some MosaicDataView)
    
    self.alpha = 0.3;
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.alpha = 1;
                     }
                     completion:^(BOOL completed){
                         // Do nothing. This is only visual feedback.
                         // See simpleExclusiveTapRecognized instead
                     }];
    
}




#pragma mark - Properties

-(NSString *)title{
//    NSString *retVal = _titleLabel.text;
//    return retVal;
    return nil;
}

-(void)setTitle:(NSString *)title{
//    _titleLabel.text = title;
}




@end
