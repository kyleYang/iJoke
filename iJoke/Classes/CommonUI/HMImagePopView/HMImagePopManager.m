//
//  PanguImgPopView.m
//  pangu
//
//  Created by yang zhiyun on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HMImagePopManager.h"
#import "HMImagePopController.h"
#import "ASImageScrollView.h"



#define kButtonWidth 40
#define kButtonHeigh 40
#define kElemtGap 5

#define ZOOM_STEP 1.5
#define ZOOM_MIN 0.3


static CGFloat const kAnimateElasticSizeRatio = 0.03;
static CGFloat const kAnimateElasticDurationRatio = 0.6;
static CGFloat const kAnimationDuration = 0.4;

@interface  HMImagePopManager()<ASImageScrollViewDelegate>{
    BOOL _bAnimation;
    UIView *_viewZomm;
}

@property (nonatomic, retain,readwrite) HMImagePopController *focusViewController;
@property (nonatomic, assign) UIViewController *parentController;

@end


@implementation HMImagePopManager

@synthesize imgRect;
@synthesize urlString;
@synthesize animationDuration;
// The background color. Defaults to transparent black.
@synthesize backgroundColor;
// Returns whether the animation has an elastic effect. Defaults to YES.
@synthesize elasticAnimation;
// Returns whether zoom is enabled on fullscreen image. Defaults to YES.
@synthesize zoomEnabled;
@synthesize dftImage;
@synthesize focusViewController;
@synthesize parentController;

- (void)dealloc
{
   
    self.urlString = nil;
    self.backgroundColor = nil;
    self.dftImage = nil;
    self.focusViewController = nil;
    self.parentController = nil;
    self.delegate = nil;
    
}


- (UIImage *)decodedImageWithImage:(UIImage *)imageTmp
{
    CGImageRef imageRef = imageTmp.CGImage;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    CGRect imageRect = (CGRect){.origin = CGPointZero, .size = imageSize};
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, imageSize.width, imageSize.height, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpace, CGImageGetBitmapInfo(imageRef));
    CGColorSpaceRelease(colorSpace);
    
    // If failed, return undecompressed image
    if (!context) return imageTmp;
    
    CGContextDrawImage(context, imageRect, imageRef);
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    
    UIImage *decompressedImage = [UIImage imageWithCGImage:decompressedImageRef];
    CGImageRelease(decompressedImageRef);
    return decompressedImage;
}


- (id)init{
    return [self initWithParentConroller:nil DefaultImg:nil imageUrl:nil imageFrame:CGRectZero];
}

- (id)initWithParentConroller:(UIViewController *)controller DefaultImg:(UIImage *)popImage imageUrl:(NSString*)popImgUrl imageFrame:(CGRect)rect
{
    self = [super init];
    if (self) {
        
        self.imgRect = rect;
        self.urlString = popImgUrl;
        self.dftImage = popImage;
        self.parentController = controller;
    
        self.animationDuration = kAnimationDuration;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:1.0f];
        self.elasticAnimation = YES;
        self.zoomEnabled = YES;
        
        _bAnimation = NO;
        
        self.focusViewController = [[HMImagePopController alloc] initWithNibName:nil bundle:nil] ;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDefocusGesture:)];
        [self.focusViewController.view addGestureRecognizer:tapGesture];
        self.focusViewController.mainImageView.image = self.dftImage;
        
    }
    return self;
}




- (void)handleFocusGesture:(UIGestureRecognizer *)gesture
{
    UIViewController *parentViewController;  
    UIView *imageView;
    
    if(self.focusViewController == nil)
        return;
    
    parentViewController = self.parentController;
    [parentViewController addChildViewController:self.focusViewController];
    [parentViewController.view addSubview:self.focusViewController.view];
    self.focusViewController.view.frame = parentViewController.view.bounds;
    
    imageView = self.focusViewController.mainImageView;
    imageView.frame = self.imgRect;
    
    [UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame;
                         CGRect initialFrame;
                         CGAffineTransform initialTransform;
                         
                         frame = self.parentController.view.bounds;
//                         frame = (self.elasticAnimation?[self rectInsetsForRect:frame ratio:-kAnimateElasticSizeRatio]:frame);
                         
                         // Trick to keep the right animation on the image frame.
                         // The image frame shoud animate from its current frame to a final frame.
                         // The final frame is computed by taking care of a possible rotation regarding the current device orientation, done by calling updateOrientationAnimated.
                         // As this method changes the image frame, it also replaces the current animation on the image view, which is not wanted.
                         // Thus to recreate the right animation, the image frame is set back to its inital frame then to its final frame.
                         // This very last frame operation recreates the right frame animation.
                         initialTransform = imageView.transform;
                         imageView.transform = CGAffineTransformIdentity;
                         initialFrame = imageView.frame;
//                         imageView.frame = frame;
                         [self.focusViewController updateOrientationAnimated:NO];
                         // This is the final image frame. No transform.
                         
                         CGSize boundsSize = frame.size;
                         CGRect frameToCenter = frame;
                         CGSize imageSize = self.imgRect.size;
                         
                         imageSize.height = (imageSize.height * boundsSize.width)/imageSize.width;
                         imageSize.width = boundsSize.width;
                         frameToCenter.origin.x = 0;
                         
                         // center horizontally
                         if (imageSize.height < boundsSize.height)
                             frameToCenter.origin.y = (boundsSize.height - imageSize.height) / 2;
                         else
                             frameToCenter.origin.y = 0;
                         
                         frameToCenter.size = imageSize;
//                         frame = imageView.frame;
                         // It must now be animated from its initial frame and transform.
//                         imageView.frame = initialFrame;
                         imageView.transform = initialTransform;
                         imageView.transform = CGAffineTransformIdentity;
                         imageView.frame = frameToCenter;
                         
                         focusViewController.view.backgroundColor = self.backgroundColor;
                     }
                     completion:^(BOOL finished) {
                         if(self.elasticAnimation)
                         {
                             [UIView animateWithDuration:self.animationDuration*kAnimateElasticDurationRatio
                                              animations:^{
//                                                  imageView.frame = focusViewController.contentView.bounds;
                                              }
                                              completion:^(BOOL finished) {
                                                  [self installZoomView];
                                              }];
                         }
                         else
                         {
                             [self installZoomView];
                         }
                     }];
    
}


- (void)installZoomView
{
    if(self.zoomEnabled)
    {
        [self.focusViewController reloadData];
    }
}

- (void)uninstallZoomView
{
    if(self.zoomEnabled)
    {
        [self.focusViewController uninstallZoomView];
        
    }
}


- (CGRect)rectInsetsForRect:(CGRect)frame ratio:(CGFloat)ratio
{
    CGFloat dx;
    CGFloat dy;
    
    dx = frame.size.width*ratio;
    dy = frame.size.height*ratio;
    
    return CGRectInset(frame, dx, dy);
}



- (BOOL)handleDefocusGesture:(UIGestureRecognizer *)gesture
{
    if (_bAnimation) {
        return FALSE;
    }
    
    _bAnimation = YES;
    UIImageView *contentView;
//    CGRect __block bounds;
    
    [self uninstallZoomView];
    contentView = self.focusViewController.mainImageView;
//    contentView.image = self.dftImage;
//    contentView.contentMode = UIViewContentModeScaleAspectFit;
    [UIView animateWithDuration:self.animationDuration
                     animations:^{
                         self.focusViewController.scrollView.transform = CGAffineTransformIdentity;
                         contentView.frame = self.imgRect;
//                         contentView.bounds = (self.elasticAnimation?[self rectInsetsForRect:bounds ratio:kAnimateElasticSizeRatio]:bounds);
                        
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:(self.elasticAnimation?self.animationDuration*kAnimateElasticDurationRatio:0)
                                          animations:^{
                                            self.focusViewController.view.backgroundColor = [UIColor clearColor];
                                              if(self.elasticAnimation)
                                              {
//                                                  contentView.bounds = bounds;
                                              }
                                          }
                                          completion:^(BOOL finished) {
                                              [self.focusViewController.view removeFromSuperview];
                                              [self.focusViewController removeFromParentViewController];
                                              self.focusViewController = nil;
                                              _bAnimation = FALSE;
                                             
                                          }];
                     }];
    
    return TRUE;
}









#define ASImageScrollViewDelegate



- (void)aSImageScrollView:(ASImageScrollView *)view downloaderImage:(UIImage *)image{
    
    self.dftImage = image;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(HMImagePopManager:loadIndex:)]) {
        [self.delegate HMImagePopManager:self loadIndex:self.index];
    }
    
}




@end
