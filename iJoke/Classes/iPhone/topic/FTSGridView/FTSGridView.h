//
//  FTSGridView.h
//  
//
//  Created by Kyle on 13-7-31.
//
//

#import <UIKit/UIKit.h>
#import "FTSGirdViewCell.h"






@protocol FTSGridViewDataSource;
@protocol FTSGridViewDelegate;


struct FTSLayout { //grid layout ,have change to define number 
    NSUInteger x; 
    NSUInteger y;
    NSUInteger widht;
    NSUInteger height;
    
    NSUInteger up;
    NSUInteger down;
    NSUInteger left;
    NSUInteger right;
};
typedef struct FTSLayout FTSLayout;



@interface FTSGridView : UIView{
    
    id<FTSGridViewDataSource> __weak _dataSource;
    id<FTSGridViewDelegate> __weak _delegate;
    
    NSMutableDictionary        *_reusableTableCells;
   
    NSUInteger _numberOfCell;
}


@property (nonatomic, weak) id<FTSGridViewDataSource> dataSource;
@property (nonatomic, weak) id<FTSGridViewDelegate> delegate;

@property (nonatomic, assign, readonly) NSUInteger numberOfCell;

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier; 
- (void)reloadData;
- (void)reLayout;

@end




@protocol FTSGridViewDataSource <NSObject>

@required
- (NSUInteger)numberOfCellInGridView:(FTSGridView *)gridView;
- (FTSGirdViewCell *)gridView:(FTSGridView *)gridView cellIndex:(NSUInteger)index;
@optional
- (CGFloat)gridView:(FTSGridView *)gridView separatorWidthForDepth:(NSInteger)depth;
- (NSInteger)gridView:(FTSGridView *)gridView separationPositionForDepth:(NSInteger)depth;

@end



@protocol FTSGridViewDelegate <NSObject>



@end
