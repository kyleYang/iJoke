    //
//  PopupWebviewController.m
//  iMobeeOmscn
//
//  Created by ellison on 10-12-25.
//  Copyright 2010 borqs. All rights reserved.
//

#import "PopupWebviewController.h"
#import "Env.h"
#import "BqsRoundLeftArrowButton.h"

#if __has_feature(objc_arc)
#error This file cannot be compiled with ARC. Either turn off ARC for the project or use -fno-objc-arc flag
#endif

@interface PopupWebviewController()
@property (nonatomic, retain) UIButton *btnClose;

-(void)onClickCloseBtn:(id)sender;
@end


@implementation PopupWebviewController
@synthesize callback, bEnableScale, url;
@synthesize btnClose;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
-(void)dealloc {
    self.callback = nil;
    self.url = nil;
    self.btnClose = nil;
    [super dealloc];
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	BqsLog(@"PopupWebviewController.viewDidLoad:");
	
	self.isPopWebView = YES;
    self.homeUrl = self.url;
	
    [super viewDidLoad];
	
	// init hide ad
	[self jsShowAd:NO];
	
    //LeftBack Button;
    {
        BqsRoundLeftArrowButton *btn = [[[BqsRoundLeftArrowButton alloc] initWithFrame:CGRectZero] autorelease];
        btn.text = NSLocalizedStringFromTable(@"button.goback", @"commonlib", nil);
        btn.tintColor = kToolbarButtonTintColorBlack;
        [btn sizeToFit];
        [btn addTarget:self action:@selector(onClickCloseBtn:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn] autorelease];
    }

//	UIBarButtonItem *bkBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"button.goback", @"commonlib",nil) style:UIBarButtonItemStyleBordered target:self action:@selector(onClickCloseBtn:)];
//
//	self.navigationItem.leftBarButtonItem = bkBtn;
//	[bkBtn release];
    
    self.webView.scalesPageToFit = self.bEnableScale;
}

-(void)onViewWillAppear {
	if(nil == self.navigationController) {
		//[self.navigationController setNavigationBarHidden:YES animated:NO];
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		UIImage *img = [[Env sharedEnv] cacheImage:@"popweb_icon_close.png"];
		[btn setImage:img forState:UIControlStateNormal];
		btn.showsTouchWhenHighlighted = YES;
		btn.frame = CGRectMake(self.view.frame.size.width - img.size.width - 3, self.view.frame.origin.y + 3, 
							   img.size.width, img.size.height);
        btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		
		[btn addTarget:self action:@selector(onClickCloseBtn:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:btn];
		self.btnClose = btn;
	}
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    
    Env *env = [Env sharedEnv];
    if(env.bIsPad) return YES;
    else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}


#pragma mark IOS 6

-(NSUInteger)supportedInterfaceOrientations{
    
    Env *env = [Env sharedEnv];
    if(env.bIsPad) return UIInterfaceOrientationMaskAll;
    else {
        return UIInterfaceOrientationMaskPortrait;
    }

}

-(BOOL)shouldAutorotate{
    
    return YES;
}



- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.btnClose = nil;
    self.url = nil;
}


-(void)onClickCloseBtn:(id)sender {
    if(nil != self.callback && [self.callback respondsToSelector:@selector(popupWebviewControllerDidClickClose:)]) {
        [self.callback popupWebviewControllerDidClickClose:self];
    }
}
@end
