//
//  MptContentScrollView.m
//  TVGontrol
//
//  Created by Kyle on 13-4-26.
//  Copyright (c) 2013年 MIPT. All rights reserved.
//

#import "MptContentScrollView.h"
#import "Env.h"
#import "BqsUtils.h"


#define kExistNum 1


@interface MptContentScrollView(){
    NSInteger _curPage;
    
    BOOL isPaning;
    BOOL isLeftShow,isLeftDragging;
    BOOL isRightShow,isRightDragging;
}
@property (nonatomic, strong, readwrite) MptCustomScrollView *scrollView;
@property (nonatomic, assign, readwrite) NSUInteger total;
@property (nonatomic, assign, readwrite) NSUInteger current;
@property (nonatomic, strong) NSMutableArray *onScreenCells;
@property (nonatomic, strong) NSMutableDictionary *saveCells;

- (void)loadViews;
- (void)queueContentCell:(MptCotentCell *)cell;

@end




@implementation MptContentScrollView
@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize scrollView = _scrollView;
@synthesize onScreenCells = _onScreenCells;
@synthesize saveCells = _saveCells;
@synthesize total = _total;
@synthesize current = _current;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.onScreenCells = [NSMutableArray arrayWithCapacity:10];
       
        
        self.scrollView = [[MptCustomScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.delegate = self;
        self.scrollView.BackgroundColor = [UIColor clearColor];
        self.scrollView.pagingEnabled = YES;
        self.scrollView.exclusiveTouch = NO;
        self.scrollView.bouncesZoom = NO;
        self.scrollView.scrollsToTop = NO;
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.scrollView.bounces = NO;
        [self.scrollView setContentOffset:CGPointZero];
        self.scrollView.showsHorizontalScrollIndicator = FALSE;
        self.scrollView.showsVerticalScrollIndicator = FALSE;
        [self.scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.bounds)*3, CGRectGetHeight(self.bounds))];
        [self addSubview:self.scrollView];
        
        _current = 0;
        
//        self.scrollView.panGestureRecognizer.delegate = self;
        
        
    }
    return self;
}


//
//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    if (!endDrag) {
//        if (!shouldClearHitTest) { // as hitTest will be called multible times in one event-loop and i need all events, i will clean the temporaries when everything is done
//            shouldClearHitTest = YES;
//            [[NSRunLoop mainRunLoop] performSelector:@selector(clearHitTest) target:self argument:nil order:1 modes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
//        }
//       [events addObject:event]; // store the events so i can access them after all hittests for one touch are evaluated
//       
//        if (event.type == UIEventTypeTouches && ([_events count] > 3 || [[event allTouches] count] > 0 || _currentEvent)) { // two or more fingers detected. at least for my view hierarchy
//            multiTouch = YES;
//            return scrollViewB;
//       }
//   }else {
//        endDrag = NO;
//   }
//   return scrollViewA;
//}
//




#pragma mark
#pragma mark datasource


- (void)setDataSource:(id<scrollDataSource>)dataSource{
   
    _dataSource = dataSource;
    [self.scrollView setContentOffset:CGPointZero]; //set dataSource , contentOffset to zero， begin
    
    [self reloadData];
}


#pragma mark
#pragma mark cell reuse

- (MptCotentCell *)cellForRowAtIndex:(NSUInteger)index{
    
    if(self.onScreenCells == nil)
        return nil;
    for (MptCotentCell *temp in self.onScreenCells) {
        if (temp.cellTag == index)
            return temp;
    }
    return nil;
    
    
}


- (MptCotentCell *)dequeueCellWithIdentifier:(NSString *)identifier{
    
	if(self.saveCells){
		//找到了重用的
        NSMutableArray *arys = [self.saveCells objectForKey:identifier];
        if (arys && arys.count != 0) {
            BqsLog(@"find dequeueReusableCellWithIdentifier:%@",identifier);
            MptCotentCell *cell = [arys lastObject];
            [arys removeLastObject];
            return cell;
        }
        return nil;
	}
	return nil;
}



- (void)queueContentCell:(MptCotentCell *)cell{
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
- (void)viewWillDisappear{
    for (MptCotentCell * cell in _onScreenCells) {
        [cell viewWillDisappear];
    }
    
}

- (void)viewWillAppear{
    for (MptCotentCell * cell in _onScreenCells) {
        [cell viewWillAppear];
    }
}


- (void)reloadData{
    
    for (MptCotentCell *cell in self.onScreenCells) {
        [cell viewWillDisappear];
        [cell removeFromSuperview];
        [cell viewDidDisappear];
        [self queueContentCell:cell];
    }
    [self.onScreenCells removeAllObjects];
        
    _total = 0;
    
    if ([_dataSource respondsToSelector:@selector(numberOfItemFor:)]) {
        _total = [_dataSource numberOfItemFor:self];
    }
    
    if (_total == 0) { //have no item
        return;
    }
    
    if (_current==0 && [_dataSource respondsToSelector:@selector(currentPageForScrollView:)]) {
        _current = [_dataSource currentPageForScrollView:self];
    }
    
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame)*_total, CGRectGetHeight(self.scrollView.frame));
    self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame)*_current, 0);
    [self loadViews];
    
    BqsLog(@"scrollView contentOffset curPage :%d",_curPage);

    
}


- (void)loadViews{

    CGPoint offset = self.scrollView.contentOffset;
    
    //移掉划出屏幕外的图片 保存3个
    NSMutableArray *readyToRemove = [NSMutableArray array];
    for (MptCotentCell *view in self.onScreenCells) {
        if(view.frame.origin.x + 2*view.frame.size.width  <= offset.x || view.frame.origin.x - 2*view.frame.size.width >= offset.x ){
            [readyToRemove addObject:view];
        }
    }
    
    for (MptCotentCell *cell in readyToRemove) {
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
            _current = i;
            BqsLog(@"_current index :%d ",_current);
            
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
            for (MptCotentCell *vi in self.onScreenCells) {
                if (i == vi.cellTag) {
                    HasOnScreen = TRUE;
                    [vi mainViewOnFont:onFront];
                    break;
                }
            }
            if (!HasOnScreen) {
                CGRect frame = CGRectMake(0,0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
                MptCotentCell *cell = nil;
                if(_dataSource && [_dataSource respondsToSelector:@selector(cellViewForScrollView:frame:AtIndex:)]){
                    cell = [_dataSource cellViewForScrollView:self frame:frame AtIndex:i];
                }
                if (!cell)
                    cell = [[MptCotentCell alloc] initWithFrame:frame];
                
                frame.origin = CGPointMake(CGRectGetWidth(self.scrollView.bounds)*i, 0);
                cell.frame = frame;
                cell.cellTag = i;
                cell.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
                
                [cell viewWillAppear];
                [self.scrollView addSubview:cell];
                [cell viewDidAppear];
                
                [self.onScreenCells addObject:cell];
                
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
    
    if (CGPointEqualToPoint(self.scrollView.contentOffset,offPoint)) {
        return;
    }
    
    [self.scrollView setContentOffset:offPoint animated:animation];
}




#pragma mark UIScrollViewDelegate
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self loadViews];
    
    if (_delegate && [_delegate respondsToSelector:@selector(scrollView:curOffsetPercent:)]) {
        CGFloat offset = scrollView.contentOffset.x/scrollView.contentSize.width;
        BqsLog(@"scrollViewDidScroll offset percent :%.1f",offset);
        [_delegate scrollView:self curOffsetPercent:offset];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadViews];
    CGPoint off = self.scrollView.contentOffset;
    NSUInteger index =  off.x/CGRectGetWidth(self.scrollView.frame);
    BqsLog(@"MptContentScrollView current index : %d",index);
    if (_delegate && [_delegate respondsToSelector:@selector(scrollView:curIndex:)]) {
        [_delegate scrollView:self curIndex:index];
    }
    
}





@end
