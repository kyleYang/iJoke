//
//  FTSRegisterViewController.m
//  iJoke
//
//  Created by Kyle on 13-8-23.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSRegisterViewController.h"
#import "FTSTextField.h"
#import "Downloader.h"
#import "FTSUserCenter.h"
#import "HMPopMsgView.h"
#import "FTSNetwork.h"
#import "MBProgressHUD.h"
#import "MTStatusBarOverlay.h"
#import "UMSocial.h"
#import "Msg.h"
#import "CustomUIBarButtonItem.h"
#import "FTSUserInfoViewController.h"
#import "FTSUIOps.h"
#import "PanguLogoinBT.h"
#import "PanguCheckButton.h"
#import "HumDotaHelpViewController.h"

#define kPointArc 40
#define kAnonymousWidth 25
#define kAnonymousHeight 35

#define kLinkColor [UIColor colorWithRed:92.0f/255.0f green:92.0f/255.0f blue:254.0f/255.0f alpha:1.0f]

@interface FTSRegisterViewController ()<FTSTextFieldDelegate>{
    int _taskID;
    BOOL _keyboardVisible;
}

@property (nonatomic, strong) Downloader *download;
@property (nonatomic, strong) FTSTextField *username;
@property (nonatomic, strong) FTSTextField *password;
@property (nonatomic, strong) PanguCheckButton *anonymousButton;
@property (nonatomic, strong) MBProgressHUD *activityNotice;


@end

@implementation FTSRegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)dealloc{
    
    [self.download cancelAll];
    self.download = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    Env *env = [Env sharedEnv];
    UIImage *revealLeftImagePortrait = [env cacheImage:@"content_navigationbar_back.png"];
    UIImage *revealLeftImageLandscape = [env cacheImage:@"content_navigationbar_back_highlighted.png"];
    
    
    UIImage *revealRightImagePortrait = [env cacheImage:@"joke_nav_setting.png"];
    UIImage *revealRightImageLandscape = [env cacheImage:@"joke_nav_setting_down.png"];
    
    self.navigationItem.leftBarButtonItem = [CustomUIBarButtonItem initWithImage:revealLeftImagePortrait eventImg:revealLeftImageLandscape title:nil target:self action:@selector(backSuper:)];

    
    
    self.contentView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.contentView];
    
    
    UIImageView *inputBackground = [[UIImageView alloc] initWithImage:[[Env sharedEnv] cacheImage:@"input_background.png"]];
    [self.contentView addSubview:inputBackground];
    CGRect frame = inputBackground.frame;
    frame.origin.y = 25;
    frame.origin.x = (CGRectGetWidth(self.view.bounds) - CGRectGetWidth(frame))/2;
    inputBackground.frame = frame;
    
    
    self.username = [[FTSTextField alloc] initWithFrame:CGRectMake(CGRectGetMinX(inputBackground.frame), CGRectGetMinY(inputBackground.frame), CGRectGetWidth(inputBackground.frame), CGRectGetHeight(inputBackground.frame)/2)];
    self.username.backgroundColor = [UIColor clearColor];
    self.username.textField.placeholder = NSLocalizedString(@"joke.login.usename.plachold", nil);
    self.username.textField.returnKeyType = UIReturnKeyNext;
    self.username.delegate = self;
    self.username.bgImageView.image = nil;
    self.username.textField.font = [UIFont systemFontOfSize:14.0f];
    [self.contentView addSubview:self.username];
    
    self.password = [[FTSTextField alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.username.frame), CGRectGetMaxY(self.username.frame), CGRectGetWidth(self.username.frame), CGRectGetHeight(self.username.frame))];
    self.password.textField.placeholder = NSLocalizedString(@"joke.login.password.plachold", nil);
    self.password.delegate = self;
    self.password.bgImageView.image = nil;
    self.password.textField.returnKeyType = UIReturnKeyDone;
    self.password.textField.font = [UIFont systemFontOfSize:14.0f];
    self.password.textField.secureTextEntry = YES;
    [self.contentView addSubview:self.password];
    
    self.anonymousButton = [[PanguCheckButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.username.frame)+5,CGRectGetMaxY(self.password.frame)+10, kAnonymousWidth,kAnonymousHeight)] ;
    self.anonymousButton.style = CheckButtonStyleBox;
    self.anonymousButton.label.font = [UIFont systemFontOfSize:11];
    [self.anonymousButton setChecked:FALSE];
    [self.contentView addSubview:self.anonymousButton];
    
    PanguLogoinBT *siteBt = [[PanguLogoinBT alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.anonymousButton.frame)-3,CGRectGetMinY(self.anonymousButton.frame),250,CGRectGetHeight(self.anonymousButton.frame))];
    [siteBt addTarget:self action:@selector(openEual:) forControlEvents:UIControlEventTouchUpInside];
    siteBt.txtFont = [UIFont systemFontOfSize:12.0f];
    siteBt.txtColor = kLinkColor;
    siteBt.lineName = @"pg_link_line.png";
    siteBt.userName = NSLocalizedString(@"joke.user.eula", nil);
    siteBt.message.text = nil;
    siteBt.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:siteBt];

    
    
    UIButton *registerButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.username.frame),CGRectGetMaxY(self.password.frame)+50, CGRectGetWidth(self.username.frame),50)];
    [registerButton setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"login_register_hilight.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateHighlighted];
    [registerButton setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"login_register_normal.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    [registerButton setTitle:NSLocalizedString(@"joke.login.resgister", nil) forState:UIControlStateNormal];
    [registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [registerButton addTarget:self action:@selector(userRegister:) forControlEvents:UIControlEventTouchUpInside];
    registerButton.selected = NO;
    [self.contentView addSubview:registerButton];
    
    
    
    
    self.activityNotice = [[MBProgressHUD alloc] initWithView:self.view];
    self.activityNotice.mode = MBProgressHUDModeIndeterminate;
    self.activityNotice.animationType = MBProgressHUDAnimationZoom;
    self.activityNotice.screenType = MBProgressHUDFullScreen;
    self.activityNotice.opacity = 0.5;
    [self.view addSubview:self.activityNotice];
    [self.activityNotice hide:YES];
    
    self.download = [[Downloader alloc] init];
    self.download.bSearialLoad = YES;
    
    
    
}



- (void)backSuper:(id)sender{
    
    [self.flipboardNavigationController popViewController];
    
}



- (void)viewWillAppear:(BOOL)animated
{
    BqsLog(@"viewWillAppear");
    [super viewWillAppear:animated];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChange:) name:UIKeyboardDidShowNotification object:nil];
    
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    BqsLog(@"viewWillDisappear");
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
//    
    [self.download cancelAll];
    _taskID = -1;
    
    [super viewWillDisappear:animated];
    
}



//输入框获得焦点，获得keyboardshow 焦点
-(void)onKeyboardShow:(NSNotification*)ntf {
    BqsLog(@"onKeyboardShow");
    if(_keyboardVisible) {
        BqsLog(@"keyboard already visible");
        return;
    }
    _keyboardVisible = YES;
    
    //获得键盘尺寸，系统动画时间
    
    
    
    // get size of keyboard
    NSDictionary *dic = [ntf userInfo];
    NSValue *val = [dic objectForKey:UIKeyboardFrameEndUserInfoKey];
//    if(nil == val) {
//        val = [dic objectForKey:UIKeyboardBoundsUserInfoKey];
//    }
    CGRect keyboardRect = [val CGRectValue];
    NSTimeInterval animationDuration = [[dic objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGSize keyboardSize = keyboardRect.size;
    
    float fKeyboardHeight = keyboardSize.height;
    if(!UIInterfaceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
        fKeyboardHeight = keyboardSize.width;
    }
    
    CGSize ctSize = self.contentView.contentSize;
    ctSize.height = fKeyboardHeight + self.contentView.frame.size.height;
    //    self.contentView.contentSize = ctSize;
    
    FTSTextField *tf = nil;
    if([self.username.textField isFirstResponder]) tf = self.username;
    else if([self.password.textField isFirstResponder]) tf = self.password;
    
    
    //计算获取焦点的输入框的坐标
    CGRect rcScr = [self.contentView convertRect:tf.frame toView:self.view];
    
    CGFloat offset = 0.0f;
    if (DeviceSystemMajorVersion()>=7.0f) {
        offset = 64.0f;
    }
    
    float h = 0.0;
    h = MAX((rcScr.origin.y - kPointArc - offset), 0);
    CGRect frame = self.view.bounds;
    frame.origin.y -= h;
    
    [UIView animateWithDuration:animationDuration animations:^(void){
        self.contentView.frame = frame;
    }];
    
}
//输入框失去焦点，获得keyboardhide
-(void)onKeyboardHide:(NSNotification*)aNotification {
    BqsLog(@"onKeyboardHide");
    if(!_keyboardVisible) {
        BqsLog(@"keyboard is not hidden");
        return;
    }
    _keyboardVisible = NO;
    
    //    CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = self.contentView.frame;
    frame.origin.y =0;
    
    [UIView animateWithDuration:animationDuration animations:^(void){
        self.contentView.frame = frame;
    }];
    
}

//keyboard 切换输入法，预留了位置，不需要变化
- (void)keyboardFrameChange:(NSNotification *)aNotification
{
    
    //    CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //    CGFloat chHeight = keyboardRect.size.height - _keyHeight;
    //    CGRect frame = self.contentView.frame;
    //    frame.size.height -= chHeight;
    //    self.contentView.frame = frame;
    //
    //    _keyHeight = keyboardRect.size.height;
    
    
}




#pragma mark
#pragma mark FTSTextFieldDelegate

-(BOOL)textFieldShouldReturn:(FTSTextField *)textField{
    
    if (textField == self.username) {
        [self.password.textField becomeFirstResponder];
        [self actitvFieldChange:self.password];
    }else if(textField == self.password){
        
    }
    [textField resignFirstResponder];
    return YES;
    
    
}

- (void)actitvFieldChange:(FTSTextField *)textField{
//    CGRect rcScr = textField.frame;
//    float h = 0.0;
//    h = MAX((rcScr.origin.y - kPointArc), 0);
//    CGRect frame = self.contentView.bounds;
//    frame.origin.y -= h;
//    
//    [UIView animateWithDuration:0.2 animations:^(void){
//        self.contentView.frame = frame;
//    }];
    
}



#pragma mark login

- (void)openEual:(id)sender{
    HumDotaHelpViewController *about = [[HumDotaHelpViewController alloc] initWithTitle:NSLocalizedString(@"joke.setting.eula.title", nil) html:@"eula"];
    [FTSUIOps flipNavigationController:self.flipboardNavigationController pushNavigationWithController:about];
}


//登陆启动，进行网络操作
- (void)userRegister:(id)sender
{
    [self.username.textField resignFirstResponder];
    [self.password.textField resignFirstResponder];
    
    if (_taskID > 0) {
        
        [HMPopMsgView showPopMsg:NSLocalizedString(@"joke.register.running", nil)];
        
        return ;
    }
    
    NSString *name = self.username.text;
    
    if (!name) {
        [HMPopMsgView showPopMsg:NSLocalizedString(@"joke.login.nousername", nil)];
        return;
        
    }
    
    NSString * regex     = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate * pred    = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL match           = [pred evaluateWithObject:name]; //判断是不是邮箱
    
    //输入信息有误，则提示
    if (!match) {
        [HMPopMsgView showPopMsg:NSLocalizedString(@"joke.login.username.macth.no", nil)];
        return;
    }
    
    
    
    NSString *pass = self.password.text;
    if(!pass){
        [HMPopMsgView showPopMsg:NSLocalizedString(@"joke.login.password.no", nil)];
        return;
    }
    
    regex  = @"^[\\w!@#$%\\^&\\*\(\\)_]{6,20}$";
    pred    = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    match = [pred evaluateWithObject:pass];
    if(!match){
        [HMPopMsgView showPopMsg:NSLocalizedString(@"joke.login.passowrd.match.no", nil)];
        return;
        
    }
    
    
    if (!self.anonymousButton.isChecked) {
        [HMPopMsgView showPopMsg:NSLocalizedString(@"joke.user.register.noeula", nil)];
        
        return;
    }
    
       
    _taskID = [FTSNetwork userRegisterDownloader:self.download Target:self Sel:@selector(registerCB:) Attached:nil userName:name password:pass]; //
    
    self.activityNotice.labelText = NSLocalizedString(@"joke.user.registering", nil);
    [self.activityNotice show:YES];
}


- (void)registerCB:(DownloaderCallbackObj *)cb{
    _taskID = -1;
    
    [self.activityNotice hide:YES];
    if(nil == cb) return;
    
    if(nil != cb.error || 200 != cb.httpStatus) {
		BqsLog(@"Error: len:%d, http%d, %@", [cb.rspData length], cb.httpStatus, cb.error);
        [HMPopMsgView showPopMsgError:cb.error Msg:NSLocalizedString(@"error.networkfailed", nil) Delegate:nil];
        return;
	}
    Msg *msg = [Msg parseJsonData:cb.rspData];
    if (!msg.code) {
        [HMPopMsgView showPopMsg:msg.msg];
        return;
    }
    
    
    [FTSUserCenter setObjectValue:self.username.text forKey:kDftUserName];
    [FTSUserCenter setObjectValue:msg.passport forKey:kDftUserPassport];
    [FTSUserCenter setObjectValue:self.password.text forKey:kDftUserPassword];
    [FTSUserCenter setBoolVaule:TRUE forKey:kDftUserLogin];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginStateChange object:nil];
    
    

    
    FTSUserInfoViewController *userInfo = [[FTSUserInfoViewController alloc] initWithNibName:nil bundle:nil];
    [FTSUIOps flipNavigationController:self.flipboardNavigationController pushNavigationWithController:userInfo];
    
    [self performSelector:@selector(popNoNecessaryViewControllers) withObject:nil afterDelay:2];
    
}


- (void)popNoNecessaryViewControllers{
    
    NSMutableArray *popArray = [[NSMutableArray alloc] initWithCapacity:4];
    for (UIViewController *viewController in self.popViewControllers) {
        [popArray addObject:viewController];
    }
    
    [popArray addObject:self.navigationController];
    [self.flipboardNavigationController removeViewControllerArray:popArray];
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
