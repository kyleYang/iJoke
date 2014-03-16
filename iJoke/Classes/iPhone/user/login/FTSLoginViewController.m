//
//  FTSLoginViewController.m
//  iJoke
//
//  Created by Kyle on 13-8-22.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSLoginViewController.h"
#import "FTSRegisterViewController.h"
#import "FTSTextField.h"
#import "Downloader.h"
#import "FTSUserCenter.h"
#import "HMPopMsgView.h"
#import "FTSNetwork.h"
#import "FTSDataMgr.h"
#import "MBProgressHUD.h"
#import "MTStatusBarOverlay.h"
#import "UMSocial.h"
#import "FTSUIOps.h"
#import "CustomUIBarButtonItem.h"
#import "Msg.h"
#import "FTSUserInfoViewController.h"
#import "FTSLineButton.h"
#import "FTSFindPasswordViewController.h"

#define kPointArc 80

@interface FTSLoginViewController ()<FTSTextFieldDelegate,UIActionSheetDelegate>{
    int _taskID;
    BOOL _keyboardVisible;
}

@property (nonatomic, strong) Downloader *download;
@property (nonatomic, strong) FTSTextField *username;
@property (nonatomic, strong) FTSTextField *password;
@property (nonatomic, strong) MBProgressHUD *activityNotice;

@end

@implementation FTSLoginViewController

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
    
    self.navigationItem.title = NSLocalizedString(@"joke.loing.title", nil);
    
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
    
    UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.password.frame),CGRectGetMaxY(self.password.frame)+30, CGRectGetWidth(self.password.frame),50)];
    [loginButton setBackgroundColor:[UIColor clearColor]];
    [loginButton setTitle:NSLocalizedString(@"joke.login.login", nil) forState:UIControlStateNormal];
    [loginButton setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"login_register_hilight.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateHighlighted];
    [loginButton setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"login_register_normal.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(userLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:loginButton];
    
    UIButton *registerButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(loginButton.frame), CGRectGetMaxY(loginButton.frame)+20,CGRectGetWidth(loginButton.frame),CGRectGetHeight(loginButton.frame))];
    registerButton.backgroundColor = [UIColor clearColor];
    [registerButton setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"login_button_hilight.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateHighlighted];
    [registerButton setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"login_button_normal.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    [registerButton setTitle:NSLocalizedString(@"joke.login.resgister", nil) forState:UIControlStateNormal];
    [registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [registerButton addTarget:self action:@selector(userRegister:) forControlEvents:UIControlEventTouchUpInside];
    registerButton.selected = NO;
    [self.contentView addSubview:registerButton];
    
    
    
    UIButton *forgetBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(registerButton.frame) - 100,CGRectGetMaxY(registerButton.frame)+10, 100, 15)];
//    [self.contentView addSubview:forgetBtn];
    [forgetBtn setBackgroundColor:[UIColor clearColor]];
    [forgetBtn addTarget:self action:@selector(forgetPassword:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *txtLabel = [[UILabel alloc] initWithFrame:forgetBtn.bounds];
    [forgetBtn addSubview:txtLabel];
    txtLabel.textColor = HexRGB(0xFF5858);
    txtLabel.font = [UIFont systemFontOfSize:14.0f];
    txtLabel.text =  NSLocalizedString(@"joke.login.forgetpassword", nil);
    txtLabel.backgroundColor = [UIColor clearColor];
    txtLabel.textAlignment = UITextAlignmentRight;

    
    
    
    
    UIButton *sinaButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(registerButton.frame), CGRectGetMaxY(registerButton.frame)+70,CGRectGetWidth(loginButton.frame),CGRectGetHeight(loginButton.frame))];
    sinaButton.backgroundColor = [UIColor clearColor];
    sinaButton.tag = UMSocialSnsTypeSina;
    [sinaButton setTitle:NSLocalizedString(@"joke.login.sina.button", nil) forState:UIControlStateNormal];
    [sinaButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sinaButton addTarget:self action:@selector(weiboLogin:) forControlEvents:UIControlEventTouchUpInside];
    sinaButton.selected = NO;
    sinaButton.backgroundColor = [UIColor clearColor];
    [sinaButton setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"login_register_hilight.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateHighlighted];
    [sinaButton setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"login_register_normal.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    [self.contentView addSubview:sinaButton];
    
//    UIButton *tencentButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(sinaButton.frame)+20, CGRectGetMinY(sinaButton.frame),CGRectGetWidth(sinaButton.frame),CGRectGetHeight(sinaButton.frame))];
//    tencentButton.backgroundColor = [UIColor clearColor];
//    [tencentButton setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"login_register_hilight.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateHighlighted];
//    [tencentButton setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"login_register_normal.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
//    tencentButton.tag = UMSocialSnsTypeQzone;
//    [tencentButton setTitle:NSLocalizedString(@"joke.login.qq.button", nil) forState:UIControlStateNormal];
//    [tencentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [tencentButton addTarget:self action:@selector(weiboLogin:) forControlEvents:UIControlEventTouchUpInside];
//    tencentButton.selected = NO;
//    [self.contentView addSubview:tencentButton];

    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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




//输入框获得焦点，获得keyboardshow 焦点
-(void)onKeyboardShow:(NSNotification*)ntf {
    BqsLog(@"onKeyboardShow");
    if(_keyboardVisible) {
        BqsLog(@"keyboard already visible");
        return;
    }
    _keyboardVisible = YES;
    
    NSDictionary *dic = [ntf userInfo];
    NSValue *val = [dic objectForKey:UIKeyboardFrameEndUserInfoKey];

    CGRect keyboardRect = [val CGRectValue];
    NSTimeInterval animationDuration = [[dic objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGSize keyboardSize = keyboardRect.size;
    
    float fKeyboardHeight = keyboardSize.height;
    if(!UIInterfaceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
        fKeyboardHeight = keyboardSize.width;
    }
    
    CGSize ctSize = self.contentView.contentSize;
    ctSize.height = fKeyboardHeight + self.contentView.frame.size.height;
  
    FTSTextField *tf = nil;
    if([self.username.textField isFirstResponder]) tf = self.username;
    else if([self.password.textField isFirstResponder]) tf = self.password;
    
    
    //计算获取焦点的输入框的坐标
    CGRect rcScr = [self.contentView convertRect:tf.frame toView:self.view];
    if(DeviceSystemMajorVersion() >=7){
        rcScr.origin.y -= 64.0f;
    }
    
    //
    float h = 0.0;
    h = MAX((rcScr.origin.y - kPointArc), 0);
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
//登陆启动，进行网络操作
- (void)userLogin:(id)sender
{
    [self.username.textField resignFirstResponder];
    [self.password.textField resignFirstResponder];
    
    if (_taskID > 0) {
        [HMPopMsgView showPopMsg:NSLocalizedString(@"joke.login.running", nil)];
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
    
    _taskID = [FTSNetwork userLoginDownloader:self.download Target:self Sel:@selector(loginCB:) Attached:nil userName:name password:pass]; //
    
    self.activityNotice.labelText = NSLocalizedString(@"joke.login.longining", nil);
    [self.activityNotice show:YES];
}



- (void)userRegister:(id)sender{
    
    FTSRegisterViewController *registerController = [[FTSRegisterViewController alloc] initWithNibName:nil bundle:nil];
    registerController.popViewControllers = @[self.navigationController];
    [FTSUIOps flipNavigationController:self.flipboardNavigationController pushNavigationWithController:registerController];
    
    
}


- (void)forgetPassword:(id)sender{
    FTSFindPasswordViewController *findpasswordController = [[FTSFindPasswordViewController alloc] initWithNibName:nil bundle:nil];
    [FTSUIOps flipNavigationController:self.flipboardNavigationController pushNavigationWithController:findpasswordController];
}


- (void)weiboLogin:(id)sender{
    
    
    NSString *platformName = [UMSocialSnsPlatformManager getSnsPlatformString:((UIButton *)sender).tag];
    
    [FTSUserCenter setObjectValue:platformName forKey:kDftUserUnionName];
    
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:platformName];
    
    BOOL isOauth =  [UMSocialAccountManager isOauthWithPlatform:snsPlatform.platformName];
    if (isOauth) { //已经授权，解除授权
        
        UIActionSheet *unOauthActionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat: NSLocalizedString(@"joke.login.unOauth", nil),platformName]delegate:self cancelButtonTitle:NSLocalizedString(@"button.cancle", ni) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"button.sure", nil), nil];
        unOauthActionSheet.destructiveButtonIndex = 0;
        unOauthActionSheet.tag = ((UIButton *)sender).tag;
        [unOauthActionSheet showInView:self.view];
        
        
    }else{
        [FTSUserCenter setBoolVaule:YES forKey:kDftUserUnionWay];
        
        snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
            
            //          获取微博用户名、uid、token等
            if (response.responseCode == UMSResponseCodeSuccess) {
        
                UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:platformName];
                BqsLog(@"username is %@, uid is %@, token is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken);
                
                [FTSUserCenter setObjectValue:snsAccount.usid forKey:kDftUserName];
                [FTSUserCenter setObjectValue:snsAccount.userName forKey:kDftUserNickName];
                [FTSUserCenter setObjectValue:snsAccount.iconURL forKey:kDftUserIcon];
                [FTSUserCenter setBoolVaule:TRUE forKey:kDftUserLogin];
                
                switch (((UIButton *)sender).tag) {
                    case UMSocialSnsTypeSina:
                        [FTSUserCenter setIntValue:UnionLogoinTypeSina forKey:kDftUserUnionType];
                        break;
                    case UMSocialSnsTypeTenc:
                        [FTSUserCenter setIntValue:UnionLogoinTypeTenc forKey:kDftUserUnionType];
                        break;
                    case UMSocialSnsTypeMobileQQ:
                        [FTSUserCenter setIntValue:UnionLogoinTypeMobileQQ forKey:kDftUserUnionType];
                        break;
                    default:
                        [FTSUserCenter setIntValue:UnionLogoinTypeSina forKey:kDftUserUnionType];
                        break;
                }
                
                [[FTSDataMgr sharedInstance] loginUnionWithSocail];
                
                [self loginSuccess:TRUE];
                
            }

        
        });
    }
    
    

    
}


- (void)loginCB:(DownloaderCallbackObj*)cb
{
    [self.activityNotice hide:YES];
    _taskID = -1;
    if(nil == cb) return;
    
    if(nil != cb.error || 200 != cb.httpStatus) {
		BqsLog(@"Error: len:%d, http%d, %@", [cb.rspData length], cb.httpStatus, cb.error);
        [HMPopMsgView showPopError:cb.error];
		return;
	}
    
    Msg *msg = [Msg parseJsonData:cb.rspData];
    if (!msg.code) {//登陆失败，statebar 给出相应提示
        [HMPopMsgView showPopMsg:msg.msg];
        
//        MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
//        overlay.animation = MTStatusBarOverlayAnimationFallDown;  // MTStatusBarOverlayAnimationShrink
//        overlay.detailViewMode = MTDetailViewModeHistory;         // enable automatic history-tracking and show in detail-view
//        overlay.progress = 0.0;
//        overlay.screenType = MTStatusBarRightScreen;
//        [overlay postErrorMessage:NSLocalizedString(@"joke.login.failed", nil) duration:2 animated:YES];
        
        [FTSUserCenter setBoolVaule:FALSE forKey:kDftUserLogin];
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoginStateChange object:nil];
        
        return;
    }
    
//    MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
//    overlay.animation = MTStatusBarOverlayAnimationFallDown;  // MTStatusBarOverlayAnimationShrink
//    overlay.detailViewMode = MTDetailViewModeHistory;         // enable automatic history-tracking and show in detail-view
//    overlay.progress = 0.0;
//    overlay.screenType = MTStatusBarRightScreen;
//    [overlay postFinishMessage:NSLocalizedString(@"joke.login.success", nil) duration:2 animated:YES];
    
    //每次登陆成功进行用户信息保存，则能够同步web端，以及其他移动客户端造成的信息不同步问题
    
    User *user = [User userInfoForLogData:cb.rspData];
    
    [FTSUserCenter setObjectValue:user.userName forKey:kDftUserName];
    [FTSUserCenter setObjectValue:user.nikeName forKey:kDftUserNickName];
    [FTSUserCenter setObjectValue:user.icon forKey:kDftUserIcon];
    [FTSUserCenter setObjectValue:msg.passport forKey:kDftUserPassport];
    [FTSUserCenter setObjectValue:self.password.text forKey:kDftUserPassword];
    [FTSUserCenter setBoolVaule:TRUE forKey:kDftUserLogin];

    [[FTSDataMgr sharedInstance] synchronizationRecordMessage]; //synchronize record message when login
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginStateChange object:nil];
    [self loginSuccess:TRUE];
    
    
}


- (void)loginSuccess:(BOOL)value
{
    BqsLog(@"login success in PanguLogoinViewController");
    if (self.action == nil) {
        FTSUserInfoViewController *userInfoController = [[FTSUserInfoViewController alloc] initWithNibName:nil bundle:nil];
        
        [FTSUIOps flipNavigationController:self.flipboardNavigationController pushNavigationWithController:userInfoController];
    
    }else if(_delegate && [_delegate respondsToSelector:@selector(loginSuccess:action:)]) {
        [_delegate loginSuccess:value action:self.action];
        
    }
    
     [self performSelector:@selector(popNoNecessaryViewControllers) withObject:nil afterDelay:.5];
    
}

- (void)popNoNecessaryViewControllers{
    
    [self.flipboardNavigationController removeViewControllerArray:@[self.navigationController]];
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSString *platformType = [UMSocialSnsPlatformManager getSnsPlatformString:actionSheet.tag];
        [[UMSocialDataService defaultDataService] requestUnOauthWithType:platformType completion:^(UMSocialResponseEntity *response) {
    
            if (response.responseCode == UMSResponseCodeSuccess) {
                [FTSUserCenter setBoolVaule:NO forKey:kDftUserUnionWay];
                [FTSUserCenter setBoolVaule:NO forKey:kDftUserUnionSuccess];
            }
        }];
    }
    else {//按取消
    }
}





@end
