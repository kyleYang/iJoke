    //
//  WebviewController.m
//  iMobee
//
//  Created by ellison on 10-9-7.
//  Copyright 2010 borqs. All rights reserved.
//

#import "WebviewController.h"
#import "BqsUtils.h"
#import "ExtIfc.h"
#import "ExtIfcCommand.h"
#import "ErrViewController.h"
#import "Env.h"

#define kAccelerometerIntervalS 1.0

#if __has_feature(objc_arc)
#error This file cannot be compiled with ARC. Either turn off ARC for the project or use -fno-objc-arc flag
#endif

@interface WebviewController() <ErrViewControllerDelegate,UIAccelerometerDelegate>

@property (nonatomic, readwrite) BOOL webViewError;
@property (nonatomic, copy, readwrite) NSString *curUrl;
@property (nonatomic, retain) UIViewController *errViewCtl;


-(void)onViewWillAppear;
-(void)onViewWillDisppear;
-(void)showProgress;
-(void)hideProgress;
-(void)onNtfFrameChanged:(NSNotification*)ntf;
-(void)showErrorView:(NSError*)error FromExtIfc:(BOOL)bFromExtIfc;
@end

@implementation WebviewController

@synthesize webView = _webView;
@synthesize activityView = _activityView; 
@synthesize myTabBarItem = _myTabBarItem;
@synthesize errViewCtl = _errViewCtl;


@synthesize extIfc = _extIfc;
@synthesize webViewError = _webViewError;
@synthesize curUrl = _curUrl;
@synthesize homeUrl = _homeUrl; 
@synthesize isPopWebView = _bIsPopWebView;
@synthesize orientationJsCallback = _orientationJsCallback;
@synthesize curOrientation=_devOrientation;

#pragma mark * View management


//-(id)initWithHomeUrl:(NSString*)url {
//	self = [super init];
//	if(nil == self) return nil;
//	
//	_webView = [[UIWebView alloc] initWithFrame:self.view.frame];
//	_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//	_webView.dataDetectorTypes = UIDataDetectorTypeNone;
//	_webView.delegate = self;
//	[self.view addSubview:_webView];
//	
//	self.homeUrl = url;
//	
//	
//	return self;
//}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	BqsLog(@"WebviewController.viewDidLoad:");
    [super viewDidLoad];
	
	
	// ext ifc
	_extIfc = [[ExtIfc alloc] init]; 

//	BqsLog(@"frame: %f,%f,%f,%f", self.view.frame.origin.x, self.view.frame.origin.y, 
//		   self.view.frame.size.width,self.view.frame.size.height);

	CGRect rc = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
	UIWebView *wv = [[UIWebView alloc] initWithFrame:rc];
	wv.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	self.webView = wv;
	self.webView.delegate = self;
	[wv release];
	
	[self.view addSubview:_webView];
		
	// activity view
	UIActivityIndicatorViewStyle topActivityIndicatorStyle = UIActivityIndicatorViewStyleGray;//UIActivityIndicatorViewStyleWhiteLarge;
	_activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:topActivityIndicatorStyle];

	_activityView.tag = 1;
	_activityView.center = self.view.center;
	//_activityView.hidesWhenStopped = YES;
	[_activityView startAnimating];
	//_activityView.hidden = YES;
	//_bActivityHidden = YES;
    //[self.webView addSubview:_activityView];

	
//	// tab bar item
//	if(nil != self.tabBarItem && [self.tabBarItem isKindOfClass:[TabBarItem class]]) {
//		self.myTabBarItem = (TabBarItem *)self.tabBarItem;
//	}
	
	// load home url
	if(nil != _homeUrl) {
		NSString *sN = [NSString stringWithFormat:@"lastUrl_%@", _homeUrl];
		
		NSString *lastUrl = [[NSUserDefaults standardUserDefaults] objectForKey:sN];
		[[NSUserDefaults standardUserDefaults] setObject:nil forKey:sN];
		
		if(nil != lastUrl && [lastUrl length] > 0) {
			[self loadUrl:lastUrl];
		} else {
			[self loadUrl: _homeUrl];	
		}
	}
		
}

-(void)onViewWillAppear {
    
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNtfFrameChanged:) name:kNtfWebViewFrameChanged object:nil];
	
//	BqsLog(@"frame: %f,%f,%f,%f", self.view.frame.origin.x, self.view.frame.origin.y, 
//		   self.view.frame.size.width,self.view.frame.size.height);
}

-(void)onViewWillDisppear {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewWillAppear:(BOOL)animated {
    _bViewVisible = YES;
    
    [super viewWillAppear:animated];
	BqsLog(@"viewWillAppear");

	[self onViewWillAppear];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	BqsLog(@"viewDidAppear");
//	BqsLog(@"frame: %f,%f,%f,%f", self.view.frame.origin.x, self.view.frame.origin.y, 
//		   self.view.frame.size.width,self.view.frame.size.height);
	
	if(nil != _orientationJsCallback && [_orientationJsCallback length] > 0) {
		_devOrientation = -1;
		[UIAccelerometer sharedAccelerometer].updateInterval = kAccelerometerIntervalS;
		[UIAccelerometer sharedAccelerometer].delegate = self;
	}
}

- (void)viewWillDisappear:(BOOL)animated {
    _bViewVisible = NO;
    
	[self onViewWillDisppear];
    [super viewWillDisappear:animated];
	BqsLog(@"viewWillDisappear");
	[UIAccelerometer sharedAccelerometer].delegate = nil;
	
}

- (void)viewDidDisappear:(BOOL)animated {
	BqsLog(@"viewDidDisappear");
    [super viewDidDisappear:animated];
}


- (void)layoutSubviews {
	BqsLog(@"layoutSubviews");
}
-(void)onNtfFrameChanged:(NSNotification*)ntf {
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	//if(nil != _prgView) return NO;
	//BqsLog(@"shouldAutorotateToInterfaceOrientation: %d", interfaceOrientation);
	
	//return NO;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);

}

-(NSUInteger)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskPortrait;  // 可以修改为任何方向
}

-(BOOL)shouldAutorotate{
    
    return YES;
}



- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toOri duration:(NSTimeInterval)duration{
	//BqsLog(@"willRotateToInterfaceOrientation: %d", toOri);
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	//BqsLog(@"didRotateFromInterfaceOrientation: %d", fromInterfaceOrientation);
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	
	// Get the current device angle
	float xx = -[acceleration x];
	float yy = [acceleration y];
	float angle = atan2(yy, xx); 
	//BqsLog(@"x:%.2f, y:%.2f, z:%.2f, angle: %.2f", acceleration.x, acceleration.y, acceleration.z, angle);
	// Add 1.5 to the angle to keep the label constantly horizontal to the viewer.
	//[interfaceOrientationLabel setTransform:CGAffineTransformMakeRotation(angle+1.5)]; 
	
	BOOL bChanged = NO;
	if(angle >= -2.25 && angle <= -0.75) {
		if(_devOrientation != UIInterfaceOrientationPortrait)
		{
			_devOrientation = UIInterfaceOrientationPortrait;
			bChanged = YES;
			BqsLog(@"orientation: UIInterfaceOrientationPortrait");
		}
	} else if(angle >= -0.75 && angle <= 0.75) {
		if(_devOrientation != UIInterfaceOrientationLandscapeRight)
		{
			_devOrientation = UIInterfaceOrientationLandscapeRight;
			bChanged = YES;
			BqsLog(@"orientation: UIInterfaceOrientationLandscapeRight");
		}
	} else if(angle >= 0.75 && angle <= 2.25) {
		if(_devOrientation != UIInterfaceOrientationPortraitUpsideDown)
		{
			_devOrientation = UIInterfaceOrientationPortraitUpsideDown;
			bChanged = YES;
			BqsLog(@"orientation: UIInterfaceOrientationPortraitUpsideDown");
		}
	} else if(angle <= -2.25 || angle >= 2.25) {
		if(_devOrientation != UIInterfaceOrientationLandscapeLeft)
		{
			_devOrientation = UIInterfaceOrientationLandscapeLeft;
			bChanged = YES;
			BqsLog(@"orientation: UIInterfaceOrientationLandscapeLeft");
		}
	}
	if(bChanged && nil != self.orientationJsCallback && [_orientationJsCallback length] > 0) {
		NSString *realCBStr = [_orientationJsCallback stringByReplacingOccurrencesOfString: kCmdCallback_Place_Holder withString: [NSString stringWithFormat:@"%d", _devOrientation]];
		[self.webView stringByEvaluatingJavaScriptFromString: realCBStr];
//		BqsLog(@"ret=%@", ret);
//		[_admobHandler adjustAdMobPosition];
	}
}

-(void)setOrientationJsCallback:(NSString *)sStr {
	[_orientationJsCallback release];
	_orientationJsCallback = nil;
	
	if(nil != sStr && [sStr length] > 0) {
		_orientationJsCallback = [sStr copy];
		_devOrientation = -1;
		[UIAccelerometer sharedAccelerometer].updateInterval = kAccelerometerIntervalS;
		[UIAccelerometer sharedAccelerometer].delegate = self;		
	} else {
		[UIAccelerometer sharedAccelerometer].delegate = nil;
	}
	
}

- (void)didReceiveMemoryWarning {
	BqsLog(@"WebviewController.didReceiveMemoryWarning");
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
    if(!_bViewVisible) {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	BqsLog(@"WebviewController.viewDidUnload");
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.webView = nil;
	self.activityView = nil;
	self.myTabBarItem = nil;
	self.errViewCtl = nil;
	self.extIfc = nil;
	self.curUrl = nil;
	self.homeUrl = nil;
	self.orientationJsCallback = nil;
}


- (void)dealloc {
	BqsLog(@"WebviewController.dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[_activityView release];
	[_webView release];
	[_myTabBarItem release];
	[_errViewCtl release];
	[_extIfc release];
	[_curUrl release];
	[_homeUrl release];
	[_orientationJsCallback release];
	
    [super dealloc];
}

#pragma mark * WebView delegation

- (void)webViewDidStartLoad:(UIWebView *)theWebView  {
	// Play any default movie
	//NSBqsLog(@"Going to play default movie");
	//	Movie* mov = (Movie*)[self getCommandInstance:@"Movie"];
	//	NSMutableArray *args = [[[NSMutableArray alloc] init] autorelease];
	//	[args addObject:@"default.mov"];
	//	NSMutableDictionary* opts = [[[NSMutableDictionary alloc] init] autorelease];
	//	[opts setObject:@"1" forKey:@"repeat"];
	//	[mov play:args withDict:opts];
	BqsLog(@"webViewDidStartLoad");
	//_activityView.hidden = NO;
	[self showProgress];
	_webViewError = NO;
}


- (void)webViewDidFinishLoad:(UIWebView *)theWebView {
	
	BqsLog(@"webViewDidFinishLoad %@", [[_webView.request URL] absoluteURL]);
	
	//[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	//_activityView.hidden = YES;
	[self hideProgress];
	_webViewError = NO;

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	int errCode = [error code];
    BqsLog(@"Failed to load webpage with error: %d %@  %@", errCode, [error localizedDescription], [[_webView.request URL] absoluteURL]);
	
	//_activityView.hidden = YES;
	[self hideProgress];
	//[self adjustAdMobPosition];
	_webViewError = YES;
	
	// 204 is issued when media player plugin is loaded.
	if (NSURLErrorCancelled != errCode &&
		204 != errCode ) {
		[self showErrorView:error FromExtIfc:NO];//[[[_webView.request URL] absoluteURL] absoluteString]];
        
        NSString *failingUrl = @"";
        if(nil != error && nil != [error userInfo]) {
            NSDictionary *dic = [error userInfo];
            id obj = [dic objectForKey:@"NSErrorFailingURLStringKey"];
            if([obj isKindOfClass:[NSURL class]]) {
                NSURL *fu = (NSURL*)obj;
                failingUrl = [fu absoluteString];
            } else if([obj isKindOfClass:[NSString class]]) {
                failingUrl = (NSString*)obj;
            }
        }
	}
}


/**
 * Start Loading Request
 * This is where most of the magic happens... We take the request(s) and process the response.
 * From here we can re direct links and other protocalls to different internal methods.
 *
 */
- (BOOL)webView:(UIWebView *)theWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSURL *url = [request URL];
	BqsLog(@"shouldStartLoadWithRequest: %@", [url absoluteString]);
	
    // check itunes
    {
        NSString *host = [url host];
        if(nil != host) {
            host = [host lowercaseString];
            if([host hasSuffix:@"itunes.apple.com"]) {
                // is itunes, 
                if([[UIApplication sharedApplication] openURL:url]) {
                    return NO;
                }
            }
        }
    }
    // chect extifc
	if([_extIfc procURLRequest:request webViewController:self]) {
		//_activityView.hidden = YES;
		[self hideProgress];
		//BqsLog(@"activityView.hidden=%d", _activityView.hidden);
		return NO;
	}
	
	self.curUrl = [url absoluteString];
	

//	// add custom headers
//	
//	NSMutableURLRequest *mutReq = (NSMutableURLRequest *)request;
//	
//    if ([mutReq respondsToSelector:@selector(setValue:forHTTPHeaderField:)]) {
//		NSBqsLog(@"Support!!!!!!");
//		Env *env = [iMobeeAppDelegate app].env;
//		
//        //[mutReq setValue:[NSString stringWithFormat:@"%dx%d", (int)env.screenSize.width, (int)env.screenSize.height] forHTTPHeaderField:kHTTP_HEADER_XDEVICERES];
//		[mutReq setValue:kHTTP_HEADER_XREQUESTBY_VALUE forHTTPHeaderField:kHTTP_HEADER_XREQUESTBY];
//		
//    } else {
//		NSBqsLog(@"Not support~~~");
//	}

	return YES;
}

#pragma mark ErrViewController delegation
-(void)showErrorView:(NSError*)error FromExtIfc:(BOOL)bFromExtIfc {
	
	_webViewErrorCallFromExtIfc = bFromExtIfc;
	
	NSString *webViewUrl = [[[_webView.request URL] absoluteURL] absoluteString];
	NSString *sBack = @"";
	if(!_webViewErrorCallFromExtIfc) {
		if(nil != webViewUrl && [webViewUrl length] > 0) {
			sBack = NSLocalizedStringFromTable(@"button.goback", @"commonlib", nil);
		} else {
			sBack = NSLocalizedStringFromTable(@"button.retry", @"commonlib", nil);
			self.curUrl = self.homeUrl;
			
			if(!_bIsPopWebView && nil != self.navigationController && [self.navigationController.viewControllers count] > 0) {
				UIViewController *vc = [self.navigationController.viewControllers objectAtIndex:0];
				if(nil != vc) {
					if(vc != self) {
						[self.navigationController setNavigationBarHidden:NO animated:YES];
					}
				}
			}
			
		}
		
	} else {
		// call from extifc
		if(_webView.canGoBack) {
			sBack = NSLocalizedStringFromTable(@"button.goback", @"commonlib", nil);
		} else {
			sBack = NSLocalizedStringFromTable(@"button.retry", @"commonlib", nil);
			self.curUrl = self.homeUrl;
			
			if(!_bIsPopWebView && nil != self.navigationController && [self.navigationController.viewControllers count] > 0) {
				UIViewController *vc = [self.navigationController.viewControllers objectAtIndex:0];
				if(nil != vc) {
					if(vc != self) {
						[self.navigationController setNavigationBarHidden:NO animated:YES];
					}
				}
			}
		}
	}
	
	if(nil != _errViewCtl) {
		[_errViewCtl.view removeFromSuperview];
		self.errViewCtl = nil;
	}
	
	ErrViewController *ev = [[ErrViewController alloc] initWithErrorTitle:NSLocalizedStringFromTable(@"title.error.network", @"commonlib",nil) 
																	  Msg:[error localizedDescription] 
																   Button:sBack 
																 Delegate: self];
	
	if(nil != ev) {
		self.errViewCtl = ev;
		[ev release];
		[self.webView addSubview: _errViewCtl.view];
	} else {
		BqsLog(@"Failed to load err view");
	}    
	
}

- (void) errViewDidDisappear: (ErrViewController*) errCtl {
	BqsLog(@"errViewDidDisappear %@ canGoBack: %d", [[_webView.request URL] absoluteURL], _webView.canGoBack);
	
	self.errViewCtl = nil;

	if(!_webViewErrorCallFromExtIfc) {
		NSString *webViewUrl = [[[_webView.request URL] absoluteURL] absoluteString];
		if(nil != webViewUrl && [webViewUrl length] > 0) {
			//[_webView goBack];
		} else {
			[self loadUrl: _curUrl];
			if(!_bIsPopWebView) {
				[self.navigationController setNavigationBarHidden:YES animated:NO];
			}
		}		
	} else {
		if(_webView.canGoBack) {
			[_webView goBack];
		} else {
			[self loadUrl: _curUrl];
			if(!_bIsPopWebView) {
				[self.navigationController setNavigationBarHidden:YES animated:NO];
			}
			
		}		
		
	}
}


#pragma mark my methods
- (void)loadUrl:(NSString*) url {
	//NSBqsLog(@"app=%d, env=%d, udid=%@", [iMobeeAppDelegate app], [iMobeeAppDelegate app].env, [iMobeeAppDelegate app].env.udid);
	//NSURL *homeURL = [NSURL URLWithString: [Utils setURL:url ParameterName:kHTTP_UDIDParamName Value: [iMobeeAppDelegate app].env.udid]];
	
	NSURL *homeURL = [NSURL URLWithString:[BqsUtils fixURLHost: url]];
    NSURLRequest *homeReq = [NSURLRequest requestWithURL:homeURL 
											 cachePolicy:NSURLRequestUseProtocolCachePolicy 
										 timeoutInterval:20.0];
	
	if(nil != _errViewCtl) {
		[_errViewCtl.view removeFromSuperview];
		self.errViewCtl = nil;
		if(!_bIsPopWebView) {
			[self.navigationController setNavigationBarHidden:YES animated:NO];
		}
		
	}

	[self.webView loadRequest:homeReq];
}

-(void)showProgress {
	if(![self.webView.subviews containsObject:_activityView]) {
		_activityView.center = self.view.center;
		[self.webView addSubview:_activityView];
	}
}

-(void)hideProgress {
	if([self.webView.subviews containsObject:_activityView]) {
		[_activityView removeFromSuperview];
	}
}


- (void)jsShowAd:(BOOL)bShow {
}

-(void)jsShowError:(NSError*)error {
	[self showErrorView:error FromExtIfc:YES];
}

-(int)adStatus {
    return 0;
}

@end
