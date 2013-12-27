//
//  FTSResetPasswordViewController.m
//  iJoke
//
//  Created by Kyle on 13-8-27.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSResetPasswordViewController.h"
#import "CustomUIBarButtonItem.h"
#import "FTSTextField.h"
#import "MBProgressHUD.h"
#import "Downloader.h"
#import "HMPopMsgView.h"
#import "FTSNetwork.h"
#import "Msg.h"
#import "FTSUserCenter.h"

#define kPointArc 60

@interface FTSResetPasswordViewController ()<FTSTextFieldDelegate>{
    
    NSUInteger _taskID;
    BOOL _keyboardVisible;
    
}


@property (nonatomic, strong) UIScrollView *contentView;
@property (nonatomic, strong) FTSTextField *passwordTextOld;
@property (nonatomic, strong) FTSTextField *passwordTextNew;
@property (nonatomic, strong) MBProgressHUD *activityNotice;

@property (nonatomic, strong) Downloader *download;

@end

@implementation FTSResetPasswordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
    
    self.passwordTextOld = [[FTSTextField alloc] initWithFrame:CGRectMake(CGRectGetMinX(inputBackground.frame), CGRectGetMinY(inputBackground.frame), CGRectGetWidth(inputBackground.frame), CGRectGetHeight(inputBackground.frame)/2)];
    self.passwordTextOld.backgroundColor = [UIColor clearColor];
    self.passwordTextOld.textField.placeholder = NSLocalizedString(@"joke.password.reset.oldpassword", nil);
    self.passwordTextOld.textField.returnKeyType = UIReturnKeyNext;
    self.passwordTextOld.delegate = self;
    self.passwordTextOld.bgImageView.image = nil;
    self.passwordTextOld.textField.font = [UIFont systemFontOfSize:14.0f];
    self.passwordTextOld.textField.secureTextEntry = YES;
    [self.contentView addSubview:self.passwordTextOld];
    
    self.passwordTextNew = [[FTSTextField alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.passwordTextOld.frame), CGRectGetMaxY(self.passwordTextOld.frame), CGRectGetWidth(self.passwordTextOld.frame), CGRectGetHeight(self.passwordTextOld.frame))];
    self.passwordTextNew.textField.placeholder = NSLocalizedString(@"joke.password.reset.newpassword", nil);
    self.passwordTextNew.delegate = self;
    self.passwordTextNew.bgImageView.image = nil;
    self.passwordTextNew.textField.returnKeyType = UIReturnKeyDone;
    self.passwordTextNew.textField.font = [UIFont systemFontOfSize:14.0f];
    self.passwordTextNew.textField.secureTextEntry = YES;
    [self.contentView addSubview:self.passwordTextNew];
    
    UIButton *resetButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.passwordTextOld.frame),CGRectGetMaxY(self.passwordTextNew.frame)+50, CGRectGetWidth(self.passwordTextOld.frame),50)];
    [resetButton setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"login_register_hilight.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateHighlighted];
    [resetButton setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"login_register_normal.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    [resetButton setTitle:NSLocalizedString(@"joke.password.reset.reset", nil) forState:UIControlStateNormal];
    [resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [resetButton addTarget:self action:@selector(passwordReset:) forControlEvents:UIControlEventTouchUpInside];
    resetButton.selected = NO;
    [self.contentView addSubview:resetButton];
    
    
    self.activityNotice = [[MBProgressHUD alloc] initWithView:self.view];
    self.activityNotice.mode = MBProgressHUDModeIndeterminate;
    self.activityNotice.animationType = MBProgressHUDAnimationZoom;
    self.activityNotice.screenType = MBProgressHUDFullScreen;
    self.activityNotice.opacity = 0.5;
    [self.view addSubview:self.activityNotice];
    [self.activityNotice hide:YES];
    
    self.download = [[Downloader alloc] init];
    self.download.bSearialLoad = YES;
    
    _keyboardVisible = FALSE;
    
}

- (void)dealloc{
    
    [self.download cancelAll];
    self.download = nil;
    
}

- (void)backSuper:(id)sender{
    
    [self.flipboardNavigationController popViewController];
    
}



- (void)viewWillAppear:(BOOL)animated
{
    BqsLog(@"viewWillAppear");
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChange:) name:UIKeyboardDidShowNotification object:nil];
    
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    BqsLog(@"viewWillDisappear");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    
    [self.download cancelAll];
    _taskID = -1;
    
    [super viewWillDisappear:animated];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if([self.passwordTextOld.textField isFirstResponder]) tf = self.passwordTextOld;
    else if([self.passwordTextNew.textField isFirstResponder]) tf = self.passwordTextNew;
    
    
    //计算获取焦点的输入框的坐标
    CGRect rcScr = [self.contentView convertRect:tf.frame toView:self.view];
    
    
    CGFloat offset = 0.0f;
    if (DeviceSystemMajorVersion()>=7.0f) {
        offset = 64.0f;
    }
    
    float h = 0.0;
    h = MAX((rcScr.origin.y - kPointArc - offset), 0);
    CGRect frame = self.contentView.frame;
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
    
    if (textField == self.passwordTextOld) {
        [self.passwordTextNew.textField becomeFirstResponder];
        [self actitvFieldChange:self.passwordTextNew];
    }else if(textField == self.passwordTextNew){
        [self passwordReset:nil];
    }
    [textField resignFirstResponder];
    return YES;
    
    
}

- (void)actitvFieldChange:(FTSTextField *)textField{
//    CGRect rcScr = textField.frame;
//    
//    CGFloat offset = 0.0f;
//    if (DeviceSystemMajorVersion()>=7.0f) {
//        offset = 64.0f;
//    }
//    
//    float h = 0.0;
//    h = MAX((rcScr.origin.y - kPointArc - offset), 0);
//    CGRect frame = self.contentView.bounds;
//    frame.origin.y -= h;
//    
//    [UIView animateWithDuration:0.2 animations:^(void){
//        self.contentView.frame = frame;
//    }];
    
}



#pragma mark login
//登陆启动，进行网络操作
- (void)passwordReset:(id)sender
{
    [self.passwordTextOld.textField resignFirstResponder];
    [self.passwordTextNew.textField resignFirstResponder];
    
    if (_taskID > 0) {
        
        [HMPopMsgView showPopMsg:NSLocalizedString(@"joke.password.reset.running", nil)];
        
        return ;
    }
    
    NSString *oldPassword = self.passwordTextOld.text;
    
    if (!oldPassword) {
        [HMPopMsgView showPopMsg:NSLocalizedString(@"joke.password.reset.noold", nil)];
        return;
        
    }
    
    NSString * regex     = @"^[\\w!@#$%\\^&\\*\(\\)_]{6,20}$";
    NSPredicate * pred    = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL match           = [pred evaluateWithObject:oldPassword]; //判断旧密码
    
    //输入信息有误，则提示
    if (!match) {
        [HMPopMsgView showPopMsg:NSLocalizedString(@"joke.password.reset.olderror", nil)];
        return;
    }
    
    
    
    NSString *newPassword = self.passwordTextNew.text;
    if(!newPassword){
        [HMPopMsgView showPopMsg:NSLocalizedString(@"joke.password.reset.nonew", nil)];
        return;
    }
    
    match = [pred evaluateWithObject:newPassword];
    if(!match){
        [HMPopMsgView showPopMsg:NSLocalizedString(@"joke.password.reset.newerror", nil)];
        return;
        
    }
    
    _taskID = [FTSNetwork passwordResetDownloader:self.download Target:self Sel:@selector(resetPasswordCB:) Attached:nil  oldPassword:oldPassword newPassword:newPassword]; //
    
    self.activityNotice.labelText = NSLocalizedString(@"joke.password.reset.changing", nil);
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
    
    [FTSUserCenter setObjectValue:msg.passport forKey:kDftUserPassport];
    [FTSUserCenter setObjectValue:self.passwordTextNew.text forKey:kDftUserPassword];
    
    [self.flipboardNavigationController popViewController];
    
    
    
    
}


@end
