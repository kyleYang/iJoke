//
//  ErrViewController.m
//  iMobee
//
//  Created by ellison on 10-9-16.
//  Copyright 2010 borqs. All rights reserved.
//

#import "ErrViewController.h"
#import "BqsUtils.h"

#if __has_feature(objc_arc)
#error This file cannot be compiled with ARC. Either turn off ARC for the project or use -fno-objc-arc flag
#endif

@interface ErrViewController()

@property (nonatomic, copy) NSString *strTitle;
@property (nonatomic, copy) NSString *strErrMsg;
@property (nonatomic, copy) NSString *strButton;

@end

@implementation ErrViewController

@synthesize lblTitle = _lblTitle;
@synthesize lblErrMsg = _lblErrMsg;
@synthesize btBackOrRetry = _btBackOrRetry;
@synthesize delegate = _delegate;

@synthesize strTitle = _strTitle;
@synthesize strErrMsg = _strErrMsg;
@synthesize strButton = _strButton;


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.lblTitle.text = _strTitle;
	self.lblErrMsg.text = _strErrMsg;
	[self.btBackOrRetry setTitle: _strButton forState: UIControlStateNormal];
	
	//[_parentView addSubview: self.view];
}


#pragma mark IOS < 6

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark IOS 6

-(NSUInteger)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskPortrait;  // 可以修改为任何方向
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
	
	self.lblTitle = nil;
	self.lblErrMsg = nil;
	self.btBackOrRetry = nil;
	//self.delegate = nil;
	
	self.strTitle = nil;
	self.strErrMsg = nil;
	self.strButton = nil;
}


- (void)dealloc {
    BqsLog(@"dealloc");
	[_lblTitle release];
	[_lblErrMsg release];
	[_btBackOrRetry release];
	//[_delegate release];
	[_strTitle release];
	[_strErrMsg release];
	[_strButton release];
    [super dealloc];
}


-(IBAction) backOrRetryAction:(id)from {
	[self.view removeFromSuperview];
	if(nil != _delegate && [_delegate respondsToSelector:@selector(errViewDidDisappear:)]) {
		[_delegate errViewDidDisappear:self];
	}
}

-(id)initWithErrorTitle: (NSString*)sTitle Msg: (NSString*)sMsg Button: (NSString*)sBtn Delegate: (id)delg {
	
    if([BqsUtils isIPad]) {
        self = [super initWithNibName:@"ErrViewController-iPad" bundle:nil];
    } else {
        self = [super initWithNibName:@"ErrViewController" bundle:nil];
    }
	if(nil == self) return nil;
	
	self.delegate = delg;

	self.strTitle = sTitle;
	self.strErrMsg = sMsg;
	self.strButton = sBtn;
	return self;
}

@end
