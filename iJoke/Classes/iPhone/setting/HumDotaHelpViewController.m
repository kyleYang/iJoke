//
//  PanguHelpViewController.m
//  pangu
//
//  Created by yang zhiyun on 12-6-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HumDotaHelpViewController.h"
#import "CustomUIBarButtonItem.h"
#import "Env.h"


@interface HumDotaHelpViewController ()<UIWebViewDelegate>
{
    BOOL _rootVale;
}

@property (nonatomic, copy) NSString *titleName;
@property (nonatomic, copy) NSString *contentFile;
@property (nonatomic, retain) UIWebView *htmlWeb;
@end

@implementation HumDotaHelpViewController
@synthesize htmlWeb;
@synthesize titleName;
@synthesize contentFile;


- (void)dealloc
{
    self.htmlWeb = nil;
    self.titleName = nil;
    self.contentFile = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (id)initWithTitle:(NSString *)title html:(NSString *)html
{
    self = [super init];
    if (self) {
        self.titleName = title;
        self.contentFile = html;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    if (_rootVale) {
//        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"pg.button.return", nil) style:UIBarButtonItemStylePlain target:self action:@selector(backSuper:)] autorelease];
//    }
    Env *env = [Env sharedEnv];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (DeviceSystemMajorVersion() >= 7) {
        
        self.automaticallyAdjustsScrollViewInsets = YES;
        
    }
    UIImage *revealLeftImagePortrait = [env cacheImage:@"content_navigationbar_back.png"];
    UIImage *revealLeftImageLandscape = [env cacheImage:@"content_navigationbar_back_highlighted.png"];
    
    
    
    self.navigationItem.leftBarButtonItem = [CustomUIBarButtonItem initWithImage:revealLeftImagePortrait eventImg:revealLeftImageLandscape title:nil target:self action:@selector(backSuper:)];
    self.navigationItem.title = self.titleName;
    
    self.htmlWeb = [[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))] autorelease];
    self.htmlWeb.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.htmlWeb.delegate = self;

    
    NSString *txtPath = [[NSBundle mainBundle] pathForResource:self.contentFile ofType:@"html"];
    NSData *ruleData = [NSData dataWithContentsOfFile:txtPath];
    if (ruleData) {
        [self.htmlWeb loadData:ruleData MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:nil];
    }else {
        [self.htmlWeb loadHTMLString:@"未提供相关内容" baseURL:nil];
    }
    
   
    [self.view addSubview:self.htmlWeb];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)backSuper:(id)sender
{
    [self.flipboardNavigationController popViewController];
}

- (void)cancelBT:(id)sender
{
    UIViewController *root = (UIViewController*)[self.navigationController.viewControllers objectAtIndex:0];
    if (root == self) {
        [self dismissModalViewControllerAnimated:YES];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSRange range = [request.URL.absoluteString rangeOfString:@"http://"];
    if (range.location != NSNotFound) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return FALSE;
    }
    
   
    return TRUE;
}



- (BOOL)shouldAutorotate{
    return NO;
}
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

@end
