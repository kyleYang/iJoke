//
//  ASMediaFocusViewController.m
//  ASMediaFocusManager
//
//  Created by Philippe Converset on 21/12/12.
//  Copyright (c) 2012 AutreSphere. All rights reserved.
//

#import "HMImagePopController.h"
#import "ASImageScrollView.h"

static NSTimeInterval const kDefaultOrientationAnimationDuration = 0.4;


#define kExistNum 1

#define kSumOrgX 10
#define kSumOrgY 5

#define kSummaryHeight 85

@interface HMImagePopController()<UIScrollViewDelegate,ASImageScrollViewDelegate,UIGestureRecognizerDelegate>{
    
    BOOL isPaning;
    BOOL isLeftShow,isLeftDragging;
    BOOL isRightShow,isRightDragging;
    BOOL _summaryShow;
    BOOL _animatied;
}
@property (nonatomic, strong, readwrite) UIScrollView *scrollView;
@property (nonatomic, strong, readwrite) UIImageView *summaryBg;
@property (nonatomic, strong, readwrite) UITextView *summary;
@property (nonatomic, strong, readwrite) NSString *summaryString;
@property (nonatomic, assign, readwrite) NSUInteger total;
@property (nonatomic, assign, readwrite) NSUInteger currentPage;
@property (nonatomic, strong) NSMutableArray *onScreenCells;
@property (nonatomic, strong) NSMutableDictionary *saveCells;
@property (nonatomic, strong) HMImagePopCell *currentCell;

- (void)loadViews;
- (void)queueContentCell:(HMImagePopCell *)cell;

@property (nonatomic, assign) UIDeviceOrientation previousOrientation;

@end




@implementation HMImagePopController
@synthesize previousOrientation;
@synthesize scrollView = _scrollView;
@synthesize mainImageView;
@synthesize image = _image;
@synthesize currentPage = _currentPage;
@synthesize currentCell = _currentCell;
@synthesize summaryBg;
@synthesize summary;
@synthesize summaryString = _summaryString;



- (void)viewDidLoad{
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.onScreenCells = [NSMutableArray arrayWithCapacity:10];
    
    _currentPage = 0;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.delegate = self;
    self.scrollView.BackgroundColor = [UIColor clearColor];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.exclusiveTouch = YES;
    self.scrollView.bouncesZoom = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.scrollView.bounces = NO;
    [self.scrollView setContentOffset:CGPointZero];
    self.scrollView.showsHorizontalScrollIndicator = FALSE;
    self.scrollView.showsVerticalScrollIndicator = FALSE;
    [self.scrollView setContentSize:self.view.bounds.size];
    [self.view addSubview:self.scrollView];
    
    
    self.mainImageView = [[UIImageView alloc] initWithFrame:self.scrollView.bounds];
    //    self.mainImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.mainImageView];
    
    
    self.summaryBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds), kSummaryHeight)];
    self.summaryBg.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.6f];
    self.summaryBg.userInteractionEnabled = YES;
    [self.view addSubview:self.summaryBg];
    
    self.summary = [[UITextView alloc] initWithFrame:CGRectMake(kSumOrgX, kSumOrgY, CGRectGetWidth(self.summaryBg.frame)-2*kSumOrgX, CGRectGetHeight(self.summaryBg.frame)-kSumOrgY)];
    self.summary.textColor = [UIColor whiteColor];
    self.summary.editable = FALSE;
    self.summary.backgroundColor = [UIColor clearColor];
    self.summary.font = [UIFont systemFontOfSize:14.0f];
    [self.summaryBg addSubview:self.summary];
    
    
    UITapGestureRecognizer *viewSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleScrollViewSingleTap:)];
    viewSingleTap.delegate = self;
//    [viewSingleTap setNumberOfTouchesRequired:2];
    [viewSingleTap setNumberOfTapsRequired:2];
//    viewSingleTap.delaysTouchesBegan = YES;
    [self.view addGestureRecognizer:viewSingleTap];
    
    if(DeviceSystemMajorVersion() >=7){
        self.edgesForExtendedLayout = UIRectEdgeAll;
        self.extendedLayoutIncludesOpaqueBars  = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
        
    }

    
    _animatied = FALSE;
    _summaryShow = FALSE;

    
}

- (void)viewDidUnload
{
    [self setMainImageView:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChangeNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return YES;
    }
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark
#pragma mark cell reuse

- (HMImagePopCell *)cellForRowAtIndex:(NSUInteger)index{
    
    if(self.onScreenCells == nil)
        return nil;
    for (HMImagePopCell *temp in self.onScreenCells) {
        if (temp.cellTag == index)
            return temp;
    }
    return nil;
    
    
}

- (HMImagePopCell *)dequeueCellWithIdentifier:(NSString *)identifier{
    
	if(self.saveCells){
		//找到了重用的
        NSMutableArray *arys = [self.saveCells objectForKey:identifier];
        if (arys && arys.count != 0) {
            BqsLog(@"find dequeueReusableCellWithIdentifier:%@",identifier);
            HMImagePopCell *cell = [arys lastObject];
            [arys removeLastObject];
            return cell;
        }
        return nil;
	}
	return nil;
}



- (void)queueContentCell:(HMImagePopCell *)cell{
    if (!self.saveCells) {
        BqsLog(@"self.saveCells : nil");
        self.saveCells = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    NSString *identifier = cell.identifier;
    NSMutableArray *ary = [self.saveCells objectForKey:identifier];
    if (!ary) {
        ary = [NSMutableArray arrayWithCapacity:10];
    }
    [ary addObject:cell];
    [self.saveCells setObject:ary forKey:identifier];
    
}



#pragma mark
#pragma mark private method


- (void)reloadData{
    
    for (HMImagePopCell *cell in self.onScreenCells) {
        [cell viewWillDisappear];
        [cell removeFromSuperview];
        [cell viewDidDisappear];
        [self queueContentCell:cell];
    }
    [self.onScreenCells removeAllObjects];
    
    
    _total = 0;

    
    if ([_dataSource respondsToSelector:@selector(numberOfItemForImagePopController:)]) {
        _total = [_dataSource numberOfItemForImagePopController:self];
    }
    
    if (_total == 0) { //have no item
        return;
    }
    
    
    if (_currentPage == 0 && [_dataSource respondsToSelector:@selector(currentIndexForPopController:)]) {
        _currentPage = [_dataSource currentIndexForPopController:self];
    }
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame)*_total, CGRectGetHeight(self.scrollView.frame));
    self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame)*_currentPage, 0);
    [self loadViews];
    
    if (_dataSource && [_dataSource respondsToSelector:@selector(summaryForImagePopController:AtIndex:)]) {
        
        self.summaryString = [_dataSource summaryForImagePopController:self AtIndex:_currentPage];
        
    }
    
    self.mainImageView.hidden = YES;
    
    BqsLog(@"scrollView contentOffset curPage :%d",_currentPage);
    
    
}


- (void)loadViews{
    
    
    CGPoint offset = self.scrollView.contentOffset;
    
    //移掉划出屏幕外的图片 保存3个
    NSMutableArray *readyToRemove = [NSMutableArray array];
    for (HMImagePopCell *view in self.onScreenCells) {
        if(view.frame.origin.x + 2*view.frame.size.width  <= offset.x || view.frame.origin.x - 2*view.frame.size.width >= offset.x ){
            [readyToRemove addObject:view];
            BqsLog(@"remove cell at index:%d", view.cellTag);
        }
    }
    
    for (HMImagePopCell *cell in readyToRemove) {
        [cell viewWillDisappear];
        
        [self.onScreenCells removeObject:cell];
        [cell removeFromSuperview];
        [cell viewDidDisappear];
        
        [self queueContentCell:cell];
    }
    
    
    
    //移掉划出屏幕外的图片 保存3个
    for (int i = 0;i<_total;i++) {
        
        BOOL OnScreen = FALSE;
        BOOL onFront = FALSE;
        
        
        if (i*CGRectGetWidth(self.scrollView.frame)>=offset.x&& i*CGRectGetWidth(self.scrollView.frame) < offset.x+CGRectGetWidth(self.scrollView.frame) ){ //on front
            
            OnScreen = TRUE;
            onFront = TRUE;
            _currentPage = i;
            
        }else if(i*CGRectGetWidth(self.scrollView.frame) >= offset.x+CGRectGetWidth(self.scrollView.frame)&&i*CGRectGetWidth(self.scrollView.frame) < offset.x+2*CGRectGetWidth(self.scrollView.frame)){
            OnScreen = TRUE;
            onFront = FALSE;
            
        }else if(i*CGRectGetWidth(self.scrollView.frame) >= offset.x-CGRectGetWidth(self.scrollView.frame)&&i*CGRectGetWidth(self.scrollView.frame) < offset.x){
            OnScreen = TRUE;
            onFront = FALSE;
            
        }else {
            OnScreen = FALSE;
            onFront = FALSE;
        }
        
        //在屏幕范围内的创建添加
        if (OnScreen) {
            BOOL HasOnScreen = FALSE;
            for (HMImagePopCell *vi in self.onScreenCells) {
                if (i == vi.cellTag) {
                    HasOnScreen = TRUE;
                    if (onFront) {
                        self.currentCell = vi;
                    }
                    [vi mainViewOnFont:onFront];
                    break;
                }
            }
            if (!HasOnScreen) {
                CGRect frame = CGRectMake(0,0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
                HMImagePopCell *cell = nil;
                if(_dataSource && [_dataSource respondsToSelector:@selector(cellViewForImagePopController:frame:AtIndex:)]){
                    cell = [_dataSource cellViewForImagePopController:self frame:frame AtIndex:i];
                }
                if (cell == nil)
                    cell = [[HMImagePopCell alloc] initWithFrame:frame];
                
                frame.origin = CGPointMake(CGRectGetWidth(self.scrollView.bounds)*i, 0);
                cell.frame = frame;
                cell.cellTag = i;
                cell.imageView.imgDelegate = self;
                cell.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
                
                
                [cell viewWillAppear];
                [self.scrollView addSubview:cell];
                [cell viewDidAppear];
                
                BqsLog(@"add cell at index:%d",i);
                
                [self.onScreenCells addObject:cell];
                
                if (onFront) {
                    self.currentCell = cell;
                }
                
                [cell mainViewOnFont:onFront];
            }
            
            
            
        }
    }
    
}


- (void)setCurrentItemIndex:(NSUInteger)index animation:(BOOL)animation;{
    if (index >= _total){
        BqsLog(@"setCurrentDisplayItemIndex > _total ,index :%d",index);
        return;
    }
    CGFloat off = index * CGRectGetWidth(self.scrollView.frame);
    CGPoint offPoint = CGPointMake(off, 0);
    [self.scrollView setContentOffset:offPoint animated:animation];
}


- (void)setCurrentCell:(HMImagePopCell *)currentCell{

    _currentCell = currentCell;
    self.mainImageView.frame = _currentCell.defaultRect;
    self.mainImageView.image = _currentCell.imageView.zoomImageView.image;
}

- (void)setSummaryString:(NSString *)summaryString{
    if (_summaryString == summaryString) return;
    
    _summaryString = summaryString;
    self.summary.text = _summaryString;
    
}


#pragma mark UIScrollViewDelegate
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self loadViews];
    
    if (_delegate && [_delegate respondsToSelector:@selector(imagePopController:curOffsetPercent:)]) {
        CGFloat offset = scrollView.contentOffset.x/scrollView.contentSize.width;
        BqsLog(@"scrollViewDidScroll offset percent :%.1f",offset);
        [_delegate imagePopController:self curOffsetPercent:offset];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadViews];
    CGPoint off = self.scrollView.contentOffset;
    NSUInteger index =  off.x/CGRectGetWidth(self.scrollView.frame);
    BqsLog(@"MptContentScrollView current index : %d",index);
    if (_dataSource && [_dataSource respondsToSelector:@selector(summaryForImagePopController:AtIndex:)]) {
        
        self.summaryString = [_dataSource summaryForImagePopController:self AtIndex:index];
        
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(imagePopController:curIndex:)]) {
        [_delegate imagePopController:self curIndex:index];
    }
    
}


- (void)installZoomView:(CGRect)rect
{
    self.mainImageView.hidden = YES;
}


- (void)uninstallZoomView
{
    CGRect frame;
    
    frame = [self.view convertRect:self.currentCell.imageView.zoomImageView.frame fromView:self.view];
    self.scrollView.hidden = YES;
    self.mainImageView.hidden = NO;
    self.mainImageView.frame = frame;
}

- (void)pinAccessoryView:(UIView *)view
{
    CGRect frame;
    
    frame = [self.view convertRect:view.frame fromView:view.superview];
    view.transform = view.superview.transform;
    [self.view addSubview:view];
    view.frame = frame;
}

- (void)pinAccessoryViews
{
    // Move the accessory views to the main view in order not to be rotated along with the media.
    [self pinAccessoryView:self.accessoryView];
    //    [self pinAccessoryView:self.titleLabel];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    return TRUE;
    
//    return FALSE;
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return TRUE;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}



- (void)handleScrollViewSingleTap:(UIGestureRecognizer *)gestureRecognizer{
    
    if (_animatied) {
        
        return;
    }
    _summaryShow = !_summaryShow;
    _animatied = TRUE;
    
    CGRect frame = self.summaryBg.frame;
    if (_summaryShow) {
        frame.origin.y = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.summaryBg.bounds);
    }else{
        frame.origin.y = CGRectGetHeight(self.view.bounds);
    }
    [UIView animateWithDuration:0.5 animations:^{
        
        self.summaryBg.frame = frame;
        
    } completion:^(BOOL finish){
        _animatied = FALSE;
    }];
    
}



#pragma mark - Notifications
- (void)orientationDidChangeNotification:(NSNotification *)notification
{
    [self updateOrientationAnimated:YES];
}



#pragma mark

- (void)aSImageScrollView:(ASImageScrollView *)view downloaderImage:(UIImage *)image{
    
    if (view == self.currentCell.imageView) {
        self.mainImageView.frame = self.currentCell.imageView.zoomImageView.frame;
        self.mainImageView.image = self.currentCell.imageView.zoomImageView.image;
    }
    
}
- (void)aSImageScrollView:(ASImageScrollView *)view loadImage:(UIImage *)image{
    
    if (view == self.currentCell.imageView) {
        self.mainImageView.frame = self.currentCell.imageView.zoomImageView.frame;
        self.mainImageView.image = self.currentCell.imageView.zoomImageView.image;
    }
    
    
}


//Guest
- (void)photoViewDidSingleTap:(ASImageScrollView *)imageScrollView{
    if (_delegate && [_delegate respondsToSelector:@selector(imagePopControllerDidTap:currentIndex:)]) {
        [_delegate imagePopControllerDidTap:self currentIndex:_currentPage];
    }
}

- (void)photoViewDidDoubleTap:(ASImageScrollView *)imageScrollView{
    
}

- (void)photoViewDidTwoFingerTap:(ASImageScrollView *)imageScrollView{
    
}

- (void)photoViewDidDoubleTwoFingerTap:(ASImageScrollView *)imageScrollView{
    
}



#pragma mark IOS 6

-(NSUInteger)supportedInterfaceOrientations{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    }
    
    return UIInterfaceOrientationMaskPortrait;  // 可以修改为任何方向
}

-(BOOL)shouldAutorotate{
    
    return YES;
}


- (BOOL)isParentSupportingInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    switch(toInterfaceOrientation)
    {
        case UIInterfaceOrientationPortrait:
            return [self.parentViewController supportedInterfaceOrientations] & UIInterfaceOrientationMaskPortrait;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            return [self.parentViewController supportedInterfaceOrientations] & UIInterfaceOrientationMaskPortraitUpsideDown;
            
        case UIInterfaceOrientationLandscapeLeft:
            return [self.parentViewController supportedInterfaceOrientations] & UIInterfaceOrientationMaskLandscapeLeft;
            
        case UIInterfaceOrientationLandscapeRight:
            return [self.parentViewController supportedInterfaceOrientations] & UIInterfaceOrientationMaskLandscapeRight;
    }
}

#pragma mark - Public
- (void)updateOrientationAnimated:(BOOL)animated
{
    return;
    
    CGAffineTransform transform;
    CGRect frame;
    NSTimeInterval duration = kDefaultOrientationAnimationDuration;
    
    if([UIDevice currentDevice].orientation == self.previousOrientation)
        return;
    
    if((UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation) && UIInterfaceOrientationIsLandscape(self.previousOrientation))
       || (UIInterfaceOrientationIsPortrait([UIDevice currentDevice].orientation) && UIInterfaceOrientationIsPortrait(self.previousOrientation)))
    {
        duration *= 2;
    }
    
    if(([UIDevice currentDevice].orientation == UIInterfaceOrientationPortrait)
       || [self isParentSupportingInterfaceOrientation:[UIDevice currentDevice].orientation])
    {
        transform = CGAffineTransformIdentity;
    }
    else
    {
        switch ([UIDevice currentDevice].orientation)
        {
            case UIInterfaceOrientationLandscapeLeft:
                if(self.parentViewController.interfaceOrientation == UIInterfaceOrientationPortrait)
                {
                    transform = CGAffineTransformMakeRotation(-M_PI_2);
                }
                else
                {
                    transform = CGAffineTransformMakeRotation(M_PI_2);
                }
                break;
                
            case UIInterfaceOrientationLandscapeRight:
                if(self.parentViewController.interfaceOrientation == UIInterfaceOrientationPortrait)
                {
                    transform = CGAffineTransformMakeRotation(M_PI_2);
                }
                else
                {
                    transform = CGAffineTransformMakeRotation(-M_PI_2);
                }
                break;
                
            case UIInterfaceOrientationPortrait:
                transform = CGAffineTransformIdentity;
                break;
                
            case UIInterfaceOrientationPortraitUpsideDown:
                transform = CGAffineTransformMakeRotation(M_PI);
                break;
                
            case UIDeviceOrientationFaceDown:
            case UIDeviceOrientationFaceUp:
            case UIDeviceOrientationUnknown:
                return;
        }
    }
    
    if(animated)
    {
        frame = self.scrollView.frame;
        [UIView animateWithDuration:duration
                         animations:^{
                             self.scrollView.transform = transform;
                             self.scrollView.frame = frame;
                         }];
    }
    else
    {
        frame = self.scrollView.frame;
        self.scrollView.transform = transform;
        self.scrollView.frame = frame;
    }
    self.previousOrientation = [UIDevice currentDevice].orientation;
}



@end
