#import "FTSCollectVideoCell.h"

#define kTouchOffX 8
#define KTouchOffY 8

#define kImageOffX 10
#define kImageOffY 20
#define kImageButtomY 20
#define kImageWidth 105
#define kImageHeight 60

#define kUserOffY 5
#define kUserHeight 30
#define kUserContentPaddY 10

#define kUpCommitGap 10;

#define kContentOffX 3
#define kContentOffY 4
#define kContentImagePaddX 6
#define kContentButtonPaddY 6


#define kButtonHeight 25
#define kButtonWidth 30
#define kButtonPaddY 20
#define kButtonsPaddY 8

#define kContentFont [UIFont systemFontOfSize:12.0f]

@interface FTSCollectVideoCell()

@property (nonatomic, strong, readwrite) UIButton *touchView;
@property (nonatomic, strong, readwrite) JKActivityIndicatorImageView *webImage;
@property (nonatomic, strong, readwrite) UILabel *content;

@property (nonatomic, strong) Video *video;

@end

@implementation FTSCollectVideoCell
@synthesize delegate = _delegate;
@synthesize video = _video;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.touchView = [[UIButton alloc] initWithFrame:CGRectMake(kTouchOffX, KTouchOffY, CGRectGetWidth(self.bounds)-2*kTouchOffX, CGRectGetHeight(self.bounds)- 2*KTouchOffY)];
        [self.touchView setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"square_card_bg.png" WithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateNormal];
        [self.touchView setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"square_card_pressed.png" WithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateHighlighted];
        [self.touchView addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.touchView];
        
        self.webImage = [[JKActivityIndicatorImageView alloc] initWithFrame:CGRectMake(kImageOffX, kImageOffY, kImageWidth, kImageHeight)];
        [self.touchView addSubview:self.webImage];
        self.content = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.webImage.frame)+kContentImagePaddX, 0, CGRectGetWidth(self.touchView.frame)-kContentOffX - CGRectGetMaxX(self.webImage.frame)+kContentImagePaddX,0)];
        self.content.font = kContentFont;
        self.content.numberOfLines = 0;
        self.content.textColor = RGBA(97.0f, 97.0f, 97.0f, 1.0);
        self.content.backgroundColor = [UIColor clearColor];
        [self.touchView addSubview:self.content];
        
//        UIImageView *bgImg = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.touchView.frame), CGRectGetHeight(self.frame) - 2, CGRectGetWidth(self.frame)-2*CGRectGetMinX(self.touchView.frame), 2)];
//        bgImg.image = [[Env sharedEnv] cacheImage:@"square_horizontal_separator.png"];
//        bgImg.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
//        [self addSubview:bgImg];
        
        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}



- (void)touchUp:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(collectSelectAtIndexPath:)]) {
        
        NSIndexPath *path = nil;
        if(DeviceSystemMajorVersion() >=7){
            path = [(UITableView *)self.superview.superview indexPathForCell:self];
        }else{
            path = [(UITableView *)self.superview indexPathForCell:self];
        }
        
        BqsLog(@"collectSelectAtIndexPath:%@",path);
        [_delegate collectSelectAtIndexPath:path];
    }
    
}


#pragma mark
#pragma mark config cell

- (void)configCellForVideo:(Video *)video{
    
    _video = video;
    

    
    self.webImage.frame = CGRectMake(kImageOffX, kImageOffY, kImageWidth, kImageHeight);
    self.webImage.imageUrl = video.picture;
    
    CGRect frame = self.touchView.frame;
    frame.size.height = kImageOffY+kImageHeight+kImageButtomY;
    self.touchView.frame = frame;
    
    
    
    frame = CGRectMake(CGRectGetMaxX(self.webImage.frame)+kContentImagePaddX, CGRectGetMinY(self.webImage.frame), CGRectGetWidth(self.touchView.frame)-kContentOffX - CGRectGetMaxX(self.webImage.frame)-kContentImagePaddX,CGRectGetHeight(self.touchView.frame)-CGRectGetMinY(self.webImage.frame)- - kContentOffY);
    self.content.frame = frame;
    
    NSString *summary = nil;
    if(_video.title != nil && [_video.title length] != 0){
        summary = _video.title;
    }else if(_video.summary != nil && [_video.summary length] !=0 ){
        summary = _video.summary;
    }else {
        summary = NSLocalizedString(@"video.notitle", nil);
    }
    
    if (summary != nil) {
        CGSize size = [summary sizeWithFont:self.content.font constrainedToSize:CGSizeMake(self.content.frame.size.width, 1000) lineBreakMode:NSLineBreakByWordWrapping];
        if (size.height < CGRectGetHeight(frame) ) {
            frame.size.height = size.height;
            self.content.frame = frame;
        }
        self.content.text = summary;
    }
    
    frame = self.frame;
    frame.size.height = KTouchOffY*2+kImageOffY+kImageButtomY+kImageHeight;
    self.frame = frame;
    [self setNeedsLayout];
    
    
    
}



+(float)caculateHeighForVideo:(Video *)vido{
    
    return KTouchOffY*2+kImageOffY+kImageButtomY+kImageHeight;
    
    
}



@end
