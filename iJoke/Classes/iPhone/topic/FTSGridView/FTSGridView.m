//
//  FTSGridView.m
//
//
//  Created by Kyle on 13-7-31.
//
//

#import "FTSGridView.h"



@interface FTSGridView(){
    
    NSMutableArray *_onScreenCells; //store element
    
    
}

@property (nonatomic, assign, readwrite) NSUInteger numberOfCell;
@property (nonatomic, strong) NSMutableDictionary  *reusableTableCells;

@property (nonatomic, strong) NSMutableArray *onScreenCells;


@end

@implementation FTSGridView
@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;

@synthesize numberOfCell = _numberOfCell;
@synthesize reusableTableCells = _reusableTableCells;
@synthesize onScreenCells = _onScreenCells;

- (void)setup{
    _onScreenCells = [[NSMutableArray alloc] initWithCapacity:10];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}


- (void)layoutSubviews{
    [self reLayout];
    [super layoutSubviews];
}

-(NSArray *)setRandomCellSize{
    NSMutableArray *nodes = [[NSMutableArray alloc ] initWithCapacity:_numberOfCell];
    for (NSInteger i = 0; i < _numberOfCell; i++) {
        NSNumber *value = [NSNumber numberWithInteger:(arc4random()%3000)+1000]; //random size of the element
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:2];
        [dic setValue:[NSNumber numberWithInt:i] forKey:@"index"];
        [dic setValue:value forKey:@"value"];
        [nodes addObject:dic];
    }
    return nodes;
}


- (void)setupLayoutWithElementsWithCreat:(BOOL)value{
    NSArray *nodes = [self setRandomCellSize];
    if (nodes && nodes.count > 0) {
        [self calcNodePositions:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)
                          nodes:nodes
                          width:ceil(self.bounds.size.width)
                         height:ceil(self.bounds.size.height)
                          depth:0
                     withCreate:value];
    }
}

 /**
  *	
  *
  *
  */


- (void)calcNodePositions:(CGRect)rect nodes:(NSArray *)nodes width:(CGFloat)width height:(CGFloat)height depth:(NSInteger)depth withCreate:(BOOL)createNode {
    if (nodes.count <= 1) {
        NSInteger index = [[[nodes objectAtIndex:0] valueForKey:@"index"] integerValue];
        if (createNode) {
            
            FTSGirdViewCell *cell;
            if (_dataSource && [_dataSource respondsToSelector:@selector(gridView:cellIndex:)]) {
                cell = [_dataSource gridView:self cellIndex:index];
            }
            if (cell) {
                cell.index = index;
                cell.frame = rect;
                [self addSubview:cell];
                [_onScreenCells addObject:cell];
            }
            
        }else {
            FTSGirdViewCell *cell = [_onScreenCells objectAtIndex:index];
            cell.frame = rect;
            cell.index = index;
            [cell layoutSubviews];
        }
        return;
    }
    
    CGFloat total = 0;
    for (NSDictionary *dic in nodes) {
        total += [[dic objectForKey:@"value"] floatValue];
    }
    CGFloat half = total / 2.0;
    
    NSInteger customSep = NSNotFound;
    if ([_dataSource respondsToSelector:@selector(gridView:separationPositionForDepth:)])
        customSep = [_dataSource gridView:self separationPositionForDepth:depth];
    
    NSInteger m;
    if (customSep != NSNotFound&&customSep<nodes.count-1) {
        m = customSep;
    }
    else {
        m = nodes.count - 1;
        total = 0.0;
        for (NSInteger i = 0; i < nodes.count; i++) {
            if (total > half) {
                m = i;
                break;
            }
            total += [[[nodes objectAtIndex:i] objectForKey:@"value"] floatValue];
        }
        if (m < 1) m = 1;
    }
    
    NSArray *aArray = [nodes subarrayWithRange:NSMakeRange(0, m)];
    NSArray *bArray = [nodes subarrayWithRange:NSMakeRange(m, nodes.count - m)];
    
    CGFloat aTotal = 0.0;
    for (NSDictionary *dic in aArray) {
        aTotal += [[dic objectForKey:@"value"] floatValue];
    }
    CGFloat bTotal = 0.0;
    for (NSDictionary *dic in bArray) {
        bTotal += [[dic objectForKey:@"value"] floatValue];
    }
    
    CGFloat aRatio;
    if (aTotal + bTotal > 0.0)
        aRatio = aTotal / (aTotal + bTotal);
    else
        aRatio = 0.5;
    
    CGRect aRect, bRect;
    CGFloat aWidth, aHeight, bWidth, bHeight;
    
    BOOL horizontal = (width > height * 1.2 );
    
    CGFloat sep = 0.0;
    if ([_dataSource respondsToSelector:@selector(gridView:separatorWidthForDepth:)])
        sep = [_dataSource gridView:self separatorWidthForDepth:depth];
    
    if (horizontal) {
        aWidth = ceil((width - sep) * aRatio);
        bWidth = width - sep - aWidth;
        aHeight = bHeight = height;
        aRect = CGRectMake(rect.origin.x, rect.origin.y, aWidth, aHeight);
        bRect = CGRectMake(rect.origin.x + aWidth + sep, rect.origin.y, bWidth, bHeight);
    }
    else { // vertical layout
        if (total == 0.0) {
            aWidth = aHeight = bWidth = bHeight = 0.0;
            aRect = CGRectMake(rect.origin.x, rect.origin.y, 0.0, 0.0);
            bRect = CGRectMake(rect.origin.x, rect.origin.y + sep, 0.0, 0.0);
        }
        else {
            aWidth = bWidth = width;
            aHeight = ceil((height - sep) * aRatio);
            bHeight = height - sep - aHeight;
            aRect = CGRectMake(rect.origin.x, rect.origin.y, aWidth, aHeight);
            bRect = CGRectMake(rect.origin.x, rect.origin.y + aHeight + sep, bWidth, bHeight);
        }
    }
    
    [self calcNodePositions:aRect nodes:aArray width:aWidth height:aHeight depth:depth + 1 withCreate:createNode];
    [self calcNodePositions:bRect nodes:bArray width:bWidth height:bHeight depth:depth + 1 withCreate:createNode];
}



- (void)queueReusableCell:(FTSGirdViewCell *)cell{
    if (_reusableTableCells) {
        _reusableTableCells = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    NSString *identifier = cell.reuseIdentifier;
    NSMutableArray *ary = [_reusableTableCells objectForKey:identifier];
    if (!ary) {
        ary = [NSMutableArray arrayWithCapacity:10];
        [_reusableTableCells setObject:ary forKey:identifier];
    }
    [ary addObject:cell];
    
}



#pragma
#pragma mark property

- (void)setDataSource:(id<FTSGridViewDataSource>)dataSource{
    if (_dataSource == dataSource) return;
    _dataSource = dataSource;
    [self reloadData];
}




#pragma mark
#pragma mark open method
- (void)reloadData{
    
    for (FTSGirdViewCell *cell in _onScreenCells) {
        [cell removeFromSuperview];
        [self queueReusableCell:cell];
    }
    [_onScreenCells removeAllObjects];
    
    if (_dataSource && [_dataSource respondsToSelector:@selector(numberOfCellInGridView:)]) {
        _numberOfCell = [_dataSource numberOfCellInGridView:self];
    }
    
    [self setupLayoutWithElementsWithCreat:YES];
    
}


- (void)reLayout{
    [self setupLayoutWithElementsWithCreat:NO];
}


- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier{
    
	if(_reusableTableCells){
		//找到了重用的
        NSMutableArray *arys = [_reusableTableCells objectForKey:identifier];
        if (arys && arys.count != 0) {
            id cell = [arys lastObject];
            [arys removeLastObject];
            return cell;
        }
        return nil;
	}
	return nil;
}



@end
