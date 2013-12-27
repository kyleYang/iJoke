/*
     File: ASImageScrollView.m
 Abstract: Centers image within the scroll view and configures image sizing and display.
  Version: 1.3 modified by Philippe Converset on 22/01/13.
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 */

#import <Foundation/Foundation.h>
#import "ASImageScrollView.h"
#import "DACircularProgressView.h"

#pragma mark -


#define kCircleProgWidth 40
#define kCircleProgHeigh 40

#define kZoomStep 2

@interface ASImageScrollView () <UIScrollViewDelegate>
{
    CGRect _imageViewFrame;

    CGPoint _pointToCenterAfterResize;
    CGFloat _scaleToRestoreAfterResize;
}
@property (nonatomic, strong, readwrite) UIImageView *zoomImageView;
@property (nonatomic, strong) DACircularProgressView *progressView;
@property (nonatomic, strong) UIImage *placeholder;

@property (nonatomic, assign) CGRect imageViewFrame;

@end

@implementation ASImageScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom = YES;
        self.scrollsToTop = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
        
        self.zoomScale = 1.0;
        
//        self.contentMode = UIViewContentModeScaleAspectFit;
        
        UITapGestureRecognizer *scrollViewDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleScrollViewDoubleTap:)];
        [scrollViewDoubleTap setNumberOfTapsRequired:2];
        [self addGestureRecognizer:scrollViewDoubleTap];
        
//        UITapGestureRecognizer *scrollViewTwoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleScrollViewTwoFingerTap:)];
//        [scrollViewTwoFingerTap setNumberOfTouchesRequired:2];
//        [self addGestureRecognizer:scrollViewTwoFingerTap];
        
        UITapGestureRecognizer *scrollViewSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleScrollViewSingleTap:)];
        [scrollViewSingleTap requireGestureRecognizerToFail:scrollViewDoubleTap];
        [self addGestureRecognizer:scrollViewSingleTap];
        
        self.zoomImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.zoomImageView.userInteractionEnabled = TRUE;
        [self addSubview:self.zoomImageView];
        
        // add gesture recognizers to the image view
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
//        UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
//        UITapGestureRecognizer *doubleTwoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTwoFingerTap:)];
        
        [doubleTap setNumberOfTapsRequired:2];
//        [twoFingerTap setNumberOfTouchesRequired:2];
//        [doubleTwoFingerTap setNumberOfTapsRequired:2];
//        [doubleTwoFingerTap setNumberOfTouchesRequired:2];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
//        [twoFingerTap requireGestureRecognizerToFail:doubleTwoFingerTap];
        
        [self.zoomImageView addGestureRecognizer:singleTap];
        [self.zoomImageView addGestureRecognizer:doubleTap];
//        [self.zoomImageView addGestureRecognizer:twoFingerTap];
//        [self.zoomImageView addGestureRecognizer:doubleTwoFingerTap];
        
        self.progressView = [[DACircularProgressView alloc] initWithFrame:CGRectMake(0.0f,0.0f, kCircleProgWidth, kCircleProgHeigh)];
        self.progressView.progress = 0.01f;
        self.progressView.hidden = YES;
        [self addSubview:self.progressView];
        
        
       

    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.zoomImageView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    self.zoomImageView.frame = frameToCenter;

    
    CGPoint contentOffset = self.contentOffset;
    
    CGSize  contentSize = self.contentSize;
    
    // ensure horizontal offset is reasonable
    if (frameToCenter.origin.x != 0.0)
        contentOffset.x = 0.0;
    
    // ensure vertical offset is reasonable
    if (frameToCenter.origin.y != 0.0)
        contentOffset.y = 0.0;
    
    if (frameToCenter.size.width > contentSize.width) {
        contentSize.width = frameToCenter.size.width;
    }
    
    if (frameToCenter.size.height > contentSize.height) {
        contentSize.height = frameToCenter.size.height;
    }
    
    self.contentOffset = contentOffset;
    
    // ensure content insert is zeroed out using translucent navigation bars
//    self.contentSize = contentSize;

    self.progressView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
}

- (void)setFrame:(CGRect)frame
{
    BOOL sizeChanging = !CGSizeEqualToSize(frame.size, self.frame.size);
    
    if (sizeChanging) {
        [self prepareToResize];
    }
    
    [super setFrame:frame];
    
    if (sizeChanging) {
        [self recoverFromResizing];
    }
}


- (void)setImageUrl:(NSString *)imageUrl{
   if (_imageUrl == imageUrl) return;
    
    _imageUrl = imageUrl;
    self.progressView.hidden = YES;
    
    
    __weak ASImageScrollView *wself = self;
        
    [self.zoomImageView setImageWithURL:[NSURL URLWithString:_imageUrl] placeholderImage:self.placeholder options:SDWebImageLowPriority progress:^(NSUInteger receiveSize, long long excepectedSize){
        if (wself.progressView.hidden) {
            wself.progressView.hidden = NO;
            wself.progressView.progress = 0.01f;
        }
        if (excepectedSize <= -0) {
            return ;
        }
        
        CGFloat progress = (CGFloat)receiveSize/excepectedSize;
        
        wself.progressView.progress = progress;
        BqsLog(@"progress %.01f",(CGFloat)receiveSize/excepectedSize);
        
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
        
        wself.progressView.hidden = YES;
        
        [wself displayImage:image];
        
        if ([wself.imgDelegate respondsToSelector:@selector(aSImageScrollView:downloaderImage:)]) {
            [wself.imgDelegate aSImageScrollView:wself downloaderImage:image];
        }
        
                
    }];
    
    
}


#pragma mark - UIScrollViewDelegate



- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    
}

#pragma mark - Configure scrollView to display new image
- (void)displayImage:(UIImage *)image{
    
    
    self.placeholder = image;

    CGSize boundsSize = self.bounds.size;
    CGRect frame = {.size=image.size};
    
    frame.size.height = (frame.size.height * boundsSize.width)/frame.size.width;
    frame.size.width = boundsSize.width;
    frame.origin.x = 0;
    
    if (frame.size.height < boundsSize.height)
        frame.origin.y = (boundsSize.height - frame.size.height) / 2;
    else
        frame.origin.y = 0;
    
    self.zoomImageView.image = image;
    self.zoomImageView.frame = _imageViewFrame;
    [UIView animateWithDuration:0.15 animations:^(void){
         self.zoomImageView.frame = frame;
        
    }completion:^(BOOL finish){
         [self configureForImageSize:frame.size];
    }];

}


- (void)displayImage:(UIImage *)image frame:(CGRect)rect
{
    
    self.placeholder = image;
    

    CGSize boundsSize = self.bounds.size;
    CGRect frame = rect;
    
    frame.size.height = (frame.size.height * boundsSize.width)/frame.size.width;
    frame.size.width = boundsSize.width;
    frame.origin.x = 0;
    
    if (frame.size.height < boundsSize.height)
        frame.origin.y = (boundsSize.height - frame.size.height) / 2;
    else
        frame.origin.y = 0;
    
    
    _imageViewFrame = frame;
    
    self.zoomImageView.frame = frame;
    self.zoomImageView.image = image;
    self.zoomImageView.userInteractionEnabled = TRUE;
    
    [self configureForImageSize:_imageViewFrame.size];
    
    
   
    
}

- (void)configureForImageSize:(CGSize)imageSize
{
    self.contentSize = imageSize;
    [self setMaxMinZoomScalesForCurrentBounds];
    self.zoomScale = 1.0f;
}



#pragma mark -
#pragma mark Methods called during rotation to preserve the zoomScale and the visible portion of the image




#pragma mark - Gestures
#pragma mark -

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    return YES;
}



- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    if (self.imgDelegate != nil && [self.imgDelegate respondsToSelector:@selector(photoViewDidSingleTap:)]) {
        [self.imgDelegate photoViewDidSingleTap:self];
    }
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    return;
    if (self.zoomScale == self.maximumZoomScale) {
        // jump back to minimum scale
        [self updateZoomScaleWithGesture:gestureRecognizer newScale:self.minimumZoomScale];
    }
    else {
        // double tap zooms in
        CGFloat newScale = MIN(self.zoomScale * kZoomStep, self.maximumZoomScale);
        [self updateZoomScaleWithGesture:gestureRecognizer newScale:newScale];
    }
    if (self.imgDelegate != nil && [self.imgDelegate respondsToSelector:@selector(photoViewDidDoubleTap:)]) {
        [self.imgDelegate photoViewDidDoubleTap:self];
    }
}

- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer {
    // two-finger tap zooms out
    CGFloat newScale = MAX([self zoomScale] / kZoomStep, self.minimumZoomScale);
    [self updateZoomScaleWithGesture:gestureRecognizer newScale:newScale];
    
    if (self.imgDelegate != nil && [self.imgDelegate respondsToSelector:@selector(photoViewDidTwoFingerTap:)]) {
        [self.imgDelegate photoViewDidTwoFingerTap:self];
    }
}

- (void)handleDoubleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer {
    if (self.imgDelegate != nil  && [self.imgDelegate respondsToSelector:@selector(photoViewDidDoubleTwoFingerTap:)]) {
        [self.imgDelegate photoViewDidDoubleTwoFingerTap:self];
    }
}

- (void)handleScrollViewSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    if (self.imgDelegate != nil  && [self.imgDelegate respondsToSelector:@selector(photoViewDidSingleTap:)]) {
        [self.imgDelegate photoViewDidSingleTap:self];
    }
}

- (void)handleScrollViewDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    return;
    if (self.zoomImageView.image == nil) return;
    CGPoint center =[self adjustPointIntoImageView:[gestureRecognizer locationInView:gestureRecognizer.view]];
    
    if (!CGPointEqualToPoint(center, CGPointZero)) {
        CGFloat newScale = MIN([self zoomScale] * kZoomStep, self.maximumZoomScale);
        [self updateZoomScale:newScale withCenter:center];
    }
}

- (void)handleScrollViewTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer {
    if (self.zoomImageView.image == nil) return;
    CGPoint center =[self adjustPointIntoImageView:[gestureRecognizer locationInView:gestureRecognizer.view]];
    
    if (!CGPointEqualToPoint(center, CGPointZero)) {
        CGFloat newScale = MAX([self zoomScale] / kZoomStep, self.minimumZoomScale);
        [self updateZoomScale:newScale withCenter:center];
    }
}

- (CGPoint)adjustPointIntoImageView:(CGPoint)center {
    BOOL contains = CGRectContainsPoint(self.zoomImageView.frame, center);
    
    if (!contains) {
        center.x = center.x / self.zoomScale;
        center.y = center.y / self.zoomScale;
        
        // adjust center with bounds and scale to be a point within the image view bounds
        CGRect imageViewBounds = self.zoomImageView.bounds;
        
        center.x = MAX(center.x, imageViewBounds.origin.x);
        center.x = MIN(center.x, imageViewBounds.origin.x + imageViewBounds.size.height);
        
        center.y = MAX(center.y, imageViewBounds.origin.y);
        center.y = MIN(center.y, imageViewBounds.origin.y + imageViewBounds.size.width);
        
        return center;
    }
    
    return CGPointZero;
}


#pragma mark - Support Methods
#pragma mark -

- (void)updateZoomScale:(CGFloat)newScale {
    CGPoint center = CGPointMake(self.zoomImageView.bounds.size.width/ 2.0, self.zoomImageView.bounds.size.height / 2.0);
    [self updateZoomScale:newScale withCenter:center];
}

- (void)updateZoomScaleWithGesture:(UIGestureRecognizer *)gestureRecognizer newScale:(CGFloat)newScale {
    CGPoint center = [gestureRecognizer locationInView:gestureRecognizer.view];
    [self updateZoomScale:newScale withCenter:center];
}

- (void)updateZoomScale:(CGFloat)newScale withCenter:(CGPoint)center {
    assert(newScale >= self.minimumZoomScale);
    assert(newScale <= self.maximumZoomScale);
    
    if (self.zoomScale != newScale) {
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:center];
        [self zoomToRect:zoomRect animated:YES];
    }
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    assert(scale >= self.minimumZoomScale);
    assert(scale <= self.maximumZoomScale);
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    zoomRect.size.width = self.frame.size.width / scale;
    zoomRect.size.height = self.frame.size.height / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}



- (void)setMaxMinZoomScalesForCurrentBounds {
    // calculate minimum scale to perfectly fit image width, and begin at that scale
    CGSize boundsSize = self.bounds.size;
    
    CGFloat minScale = 0.25;
    
    if (self.zoomImageView.bounds.size.width > 0.0 && self.zoomImageView.bounds.size.height > 0.0) {
        // calculate min/max zoomscale
        CGFloat xScale = boundsSize.width  / self.zoomImageView.bounds.size.width;    // the scale needed to perfectly fit the image width-wise
        CGFloat yScale = boundsSize.height / self.zoomImageView.bounds.size.height;   // the scale needed to perfectly fit the image height-wise
        
        //        xScale = MIN(1, xScale);
        //        yScale = MIN(1, yScale);
        
        minScale = MIN(xScale, yScale);
    }
    
    CGFloat maxScale = minScale * (kZoomStep * 2);
    
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
}

#pragma mark - Rotation support

- (void)prepareToResize {
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _pointToCenterAfterResize = [self convertPoint:boundsCenter toView:self.zoomImageView];
    
    _scaleToRestoreAfterResize = self.zoomScale;
    
    // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
    // allowable scale when the scale is restored.
    if (_scaleToRestoreAfterResize <= self.minimumZoomScale + FLT_EPSILON)
        _scaleToRestoreAfterResize = 0;
}

- (void)recoverFromResizing {
    [self setMaxMinZoomScalesForCurrentBounds];
    
    // Step 1: restore zoom scale, first making sure it is within the allowable range.
    CGFloat maxZoomScale = MAX(self.minimumZoomScale, _scaleToRestoreAfterResize);
    self.zoomScale = MIN(self.maximumZoomScale, maxZoomScale);
    
    // Step 2: restore center point, first making sure it is within the allowable range.
    
    // 2a: convert our desired center point back to our own coordinate space
    CGPoint boundsCenter = [self convertPoint:_pointToCenterAfterResize fromView:self.zoomImageView];
    
    // 2b: calculate the content offset that would yield that center point
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
                                 boundsCenter.y - self.bounds.size.height / 2.0);
    
    // 2c: restore offset, adjusted to be within the allowable range
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    
    CGFloat realMaxOffset = MIN(maxOffset.x, offset.x);
    offset.x = MAX(minOffset.x, realMaxOffset);
    
    realMaxOffset = MIN(maxOffset.y, offset.y);
    offset.y = MAX(minOffset.y, realMaxOffset);
    
    self.contentOffset = offset;
    
    
    
}

- (CGPoint)maximumContentOffset {
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset {
    return CGPointZero;
}

#pragma mark - UIScrollViewDelegate Methods
#pragma mark -

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.zoomImageView;
}
#pragma mark - Layout Debugging Support
#pragma mark -

- (void)logRect:(CGRect)rect withName:(NSString *)name {
    NSLog(@"%@: %f, %f / %f, %f", name, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

- (void)logLayout {
    NSLog(@"#### PZPhotoView ###");
    
    [self logRect:self.bounds withName:@"self.bounds"];
    [self logRect:self.frame withName:@"self.frame"];
    
    NSLog(@"contentSize: %f, %f", self.contentSize.width, self.contentSize.height);
    NSLog(@"contentOffset: %f, %f", self.contentOffset.x, self.contentOffset.y);
    NSLog(@"contentInset: %f, %f, %f, %f", self.contentInset.top, self.contentInset.right, self.contentInset.bottom, self.contentInset.left);
}


@end
