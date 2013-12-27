#import "HMImagePopCell.h"

@interface HMImagePopCell()


@property (nonatomic, strong, readwrite) ASImageScrollView *imageView;
@end


@implementation HMImagePopCell
@synthesize cellTag = _cellTag;
@synthesize identifier = _identifier;


- (id)initWithFrame:(CGRect)frame
{
    return  [self initWithFrame:frame withIdentifier:@"" withController:nil];
}

- (id)initWithFrame:(CGRect)frame withIdentifier:(NSString *)ident{
    return  [self initWithFrame:frame withIdentifier:ident withController:nil];
}


- (id)initWithFrame:(CGRect)frame withIdentifier:(NSString *)ident withController:(UIViewController *)ctrl{
    self = [super initWithFrame:frame];
    if (self) {
        self.identifier = ident;
        self.parCtl = ctrl;
        
        self.imageView = [[ASImageScrollView alloc] initWithFrame:self.bounds];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.imageView];
    }
    
    return self;
    
}

- (void)viewWillAppear{
    
    [self.imageView displayImage:self.defaultImage frame:self.defaultRect];
    
}
- (void)viewDidAppear{
    self.imageView.imageUrl = self.defaultUrl;
}

- (void)viewWillDisappear{
    self.imageView.imageUrl = nil;
}

- (void)viewDidDisappear{
    self.imageView.zoomImageView.image = nil;
    self.imageView.progressView.hidden = YES;
}

- (void)mainViewOnFont:(BOOL)value{
    
}



@end
