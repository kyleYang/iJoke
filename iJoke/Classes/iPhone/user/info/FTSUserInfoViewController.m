//
//  FTSUserInfoViewController.m
//  iJoke
//
//  Created by Kyle on 13-8-23.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSUserInfoViewController.h"
#import "FTSUserCenter.h"
#import "HMPopMsgView.h"
#import "FTSNetwork.h"
#import "MBProgressHUD.h"
#import "MTStatusBarOverlay.h"
#import "UMSocial.h"
#import "Downloader.h"
#import "FTSUserInfoCell.h"
#import "FTSUserSocialCell.h"
#import "FTSTextIndicateCell.h"
#import "UMSocial.h"
#import "CustomUIBarButtonItem.h"
#import "Msg.h"
#import "FTSResetPasswordViewController.h"
#import "FTSUIOps.h"
#import "UMSocial.h"
#import "FTSDataMgr.h"
#import "FTSPubulishMessageViewController.h"
#import "FTSCollectMessageViewController.h"

#define kBookMaxWidht 400

@interface FTSUserInfoViewController ()<UITableViewDataSource,UITableViewDelegate,UMSocialUIDelegate,UIActionSheetDelegate,UserInfoCellDelegate>{
    UISwitch *_changeSwitcher;
    UITapGestureRecognizer *_tapGesture;
    UIPanGestureRecognizer *_panGesture;
    UIView *_maskView;
    UIImage *_iconImage;
    MBProgressHUD *activityNotice;
    BOOL _edited;
    BOOL _canEdit;
    NSInteger _taskID;
    
}


@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) Downloader *downloader;
@property (nonatomic, strong) FTSUserInfoCell *userInfoCell;

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) User *myself;
@property (nonatomic, strong) UIImage *iconImage;


@end

@implementation FTSUserInfoViewController
@synthesize iconImage = _iconImage;
@synthesize user = _user;
@synthesize myself = _myself;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithUser:(User *)info{
    self = [super init];
    if (self) {
        self.user = info;
    }
    return self;
    
}


- (void)dealloc{
    
    [self.downloader cancelAll];
    self.downloader = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = NSLocalizedString(@"joke.user.usercenter", nil);
    
    Env *env = [Env sharedEnv];
    UIImage *revealLeftImagePortrait = [env cacheImage:@"content_navigationbar_back.png"];
    UIImage *revealLeftImageLandscape = [env cacheImage:@"content_navigationbar_back_highlighted.png"];
    
    UIImage *revealRightImagePortrait = [env cacheImage:@"joke_nav_setting.png"];
    UIImage *revealRightImageLandscape = [env cacheImage:@"joke_nav_setting_down.png"];
    
    self.navigationItem.leftBarButtonItem = [CustomUIBarButtonItem initWithImage:revealLeftImagePortrait eventImg:revealLeftImageLandscape title:nil target:self action:@selector(backSuper:)];
    
    self.navigationItem.rightBarButtonItem = [CustomUIBarButtonItem initWithImage:revealRightImagePortrait eventImg:revealRightImageLandscape title:nil target:self action:@selector(saveUserInfo:)];
    
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    //    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.scrollsToTop = YES;
    self.tableView.backgroundView = nil;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.allowsSelection = YES;
    self.tableView.allowsSelectionDuringEditing = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 80)];
    footView.backgroundColor = [UIColor clearColor];
    
    UIButton *logutBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 10, CGRectGetWidth(footView.frame)-30, CGRectGetHeight(footView.frame)-20)];
    [logutBtn setBackgroundColor:[UIColor clearColor]];
    [logutBtn setTitle:NSLocalizedString(@"joke.login.logout", nil) forState:UIControlStateNormal];
    [logutBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"login_register_hilight.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateHighlighted];
    [logutBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"login_register_normal.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    [logutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [logutBtn addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:logutBtn];
    
    
    activityNotice = [[MBProgressHUD alloc] initWithView:self.view];
    activityNotice.mode = MBProgressHUDModeIndeterminate;
    activityNotice.animationType = MBProgressHUDAnimationZoom;
    activityNotice.opacity = 0.5;
    activityNotice.labelText = NSLocalizedString(@"joke.publish.publishing", nil);
    [self.view addSubview:activityNotice];
    [activityNotice hide:YES];
    
    
    //    UMShareToSina,UMShareToWechatTimeline,UMShareToTencent,UMShareToQzone
    
    NSArray *infoArray = [NSArray arrayWithObject:NSLocalizedString(@"joke.userinfo.userinfo", nil)];
    NSArray *actionArray = [NSArray arrayWithObjects:NSLocalizedString(@"joke.userinfo.report", nil),NSLocalizedString(@"joke.userinfo.collect",nil),nil];
    NSArray *socialArray = [NSArray arrayWithObjects:UMShareToSina,UMShareToTencent, UMShareToQzone,nil];
    
    
    self.downloader = [[Downloader alloc] init];
    self.downloader.bSearialLoad = YES;
    
    _canEdit = FALSE; //default cant be edit the user Info
    if (_user == nil) {
        _myself = [[User alloc] init]; //when _user = nil, the infomation is myself.
        
        NSString *nikeName = [FTSUserCenter objectValueForKey:kDftUserNickName];
        _myself.nikeName = nikeName;
        
        NSString *userName = [FTSUserCenter objectValueForKey:kDftUserName];
        _myself.userName = userName;
        
        NSString *icon = [FTSUserCenter objectValueForKey:kDftUserIcon];
        _myself.icon = icon;
        
        _canEdit = TRUE;
        self.dataArray = [NSArray arrayWithObjects:infoArray,actionArray,socialArray, nil];
        self.tableView.tableFooterView = footView;
        
    }else{
        self.dataArray = [NSArray arrayWithObjects:infoArray,actionArray, nil];
    }
    
    BqsLog(@"_user = %@, _canEdit=%d", _user,_canEdit);
    
    if (!_canEdit) { //other info ,can not be edit
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    
}

- (void)viewDidUnload{
    [super viewDidUnload];
    self.tableView = nil;
}


- (void)viewDidDisappear:(BOOL)animated{
    [self.downloader cancelAll];
    [super viewDidDisappear:animated];
}

#pragma mark
#pragma mark Button method

- (void)backSuper:(id)sender{
    
    [self.flipboardNavigationController popViewController];
    
}


- (void)saveUserInfo:(id)sender{
    
    NSString *textName = self.userInfoCell.nameLable.textField.text;
    [self.userInfoCell.nameLable.textField resignFirstResponder];
    
    
    if (!_edited&& ([_myself.nikeName isEqualToString:textName]||[_myself.userName isEqualToString:textName])) {
        [HMPopMsgView showPopMsg:NSLocalizedString(@"joke.userinfo.noupdata", nil)];
        return ;
    }
    
    NSMutableData *data = nil;
    NSString *sBoundary = @"";
    NSString *sImageName = nil;
    if (_iconImage != nil) {
        NSData * imgData = [self imageScale:_iconImage];
        data = [NSMutableData dataWithData:imgData];
        sImageName = @"image.jpg";
    }
    
    if (_taskID >0) {
        [HMPopMsgView showPopMsg:NSLocalizedString(@"joke.userinfo.saving", nil)];
        return ;
    }
    
    _taskID = [FTSNetwork saveUserInfoDownloader:self.downloader Target:self Sel:@selector(updataFinished:) Attached:nil nikeName:textName FileName:sImageName Data:data ContentType:@"Content-Type"];
    [activityNotice show:TRUE];
    
    
}

- (void)logout:(id)sender{
    
    NSArray *array = [self.dataArray objectAtIndex:2]; //socail platform
    NSDictionary *snsAccountDic = [UMSocialAccountManager socialAccountDictionary];
    
    __block NSUInteger unOauthNumber = 0;
    BOOL hasOauth = FALSE;
    
    for (NSString *snsName in array) {
        unOauthNumber ++;
        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:snsName];
        UMSocialAccountEntity *accountEnitity = [snsAccountDic valueForKey:snsPlatform.platformName];
        if ([UMSocialAccountManager isOauthWithPlatform:snsPlatform.platformName]) {
            hasOauth = TRUE;
            [[UMSocialDataService defaultDataService] requestUnOauthWithType:snsPlatform.platformName completion:^(UMSocialResponseEntity *response) {
                
                if (response.responseCode == UMSResponseCodeSuccess) {
                    [FTSUserCenter setBoolVaule:NO forKey:kDftUserUnionWay];
                    [FTSUserCenter setBoolVaule:NO forKey:kDftUserUnionSuccess];
                    
                    [FTSUserCenter setBoolVaule:FALSE forKey:kDftUserLogin];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginStateChange object:nil];
                    if (unOauthNumber == [array count]) {
                        [self.flipboardNavigationController popViewController];
                    }
                    
                    
                }else{
                    [HMPopMsgView showPopMsg:[NSString stringWithFormat:NSLocalizedString(@"joke.login.union.logout.failed", nil),snsPlatform.platformName]];
                    return ;
                }
            }];
        }
    }
    if (!hasOauth) {
        [FTSUserCenter setBoolVaule:FALSE forKey:kDftUserLogin];
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoginStateChange object:nil];
        [self.flipboardNavigationController popViewController];
    }
    
    
    
    
    
    
    //    NSString *platformName = [FTSUserCenter objectValueForKey:kDftUserUnionName];
    //
    //    BOOL socailWay = [FTSUserCenter BoolValueForKey:kDftUserUnionWay];
    //    if (socailWay) {
    //        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:platformName];
    //        BOOL isOauth =  [UMSocialAccountManager isOauthWithPlatform:snsPlatform.platformName];
    //        if (isOauth) {
    //            [[UMSocialDataService defaultDataService] requestUnOauthWithType:platformName completion:^(UMSocialResponseEntity *response) {
    //
    //                if (response.responseCode == UMSResponseCodeSuccess) {
    //                    [FTSUserCenter setBoolVaule:NO forKey:kDftUserUnionWay];
    //                    [FTSUserCenter setBoolVaule:NO forKey:kDftUserUnionSuccess];
    //
    //                    [FTSUserCenter setBoolVaule:FALSE forKey:kDftUserLogin];
    //                    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginStateChange object:nil];
    //                    [self.flipboardNavigationController popViewController];
    //
    //                }else{
    //                    [HMPopMsgView showPopMsg:[NSString stringWithFormat:NSLocalizedString(@"joke.login.union.logout.failed", nil),platformName]];
    //                    return ;
    //                }
    //            }];
    //
    //        }else{
    //            [FTSUserCenter setBoolVaule:FALSE forKey:kDftUserLogin];
    //            [[NSNotificationCenter defaultCenter] postNotificationName:kLoginStateChange object:nil];
    //
    //            [self.flipboardNavigationController popViewController];
    //        }
    //    }else{
    //
    //
    //    [FTSUserCenter setBoolVaule:FALSE forKey:kDftUserLogin];
    //    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginStateChange object:nil];
    //    [self.flipboardNavigationController popViewController];
    //    }
    
}


#pragma mark
#pragma mark property
- (void)setIconImage:(UIImage *)iconImage{
    if (_iconImage == iconImage) return;
    _iconImage = iconImage;
    
    if (_iconImage == nil) {
        return ;
    }
    
    _edited = TRUE;
    
    if (self.userInfoCell != nil) {
        self.userInfoCell.iconView.imageView.image = iconImage;
    }
    
}

#pragma mark
#pragma mark DownloadCallBack

- (void)updataFinished:(DownloaderCallbackObj *)cb
{
    [activityNotice hide:YES];
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
        
        
        return;
    }
    
    User *user = [User userInfoForLogData:cb.rspData];
    
    [FTSUserCenter setObjectValue:user.userName forKey:kDftUserName];
    [FTSUserCenter setObjectValue:user.nikeName forKey:kDftUserNickName];
    [FTSUserCenter setObjectValue:user.icon forKey:kDftUserIcon];
    
    [self backSuper:nil];
    
    
}


#pragma mark
#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataArray count];
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = [self.dataArray objectAtIndex:section];
    return [array count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *infoIndentify = @"userinfo";
    static NSString *actionIndent = @"action";
    static NSString *socailIndet = @"socail";
    
    if (indexPath.section == 0) {
        FTSUserInfoCell *cell = [aTableView dequeueReusableCellWithIdentifier:infoIndentify];
        if (cell == nil) {
            cell = [[FTSUserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:infoIndentify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        self.userInfoCell = cell;
        cell.delegate = self;
        if (_user == nil) {
            [cell configCellForWords:_myself canEdit:_canEdit];
        }else{
            [cell configCellForWords:_user canEdit:_canEdit];
        }
        return cell;
        
    }else if(indexPath.section == 1){
        FTSTextIndicateCell *cell = [aTableView dequeueReusableCellWithIdentifier:actionIndent];
        if (cell == nil) {
            cell = [[FTSTextIndicateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:actionIndent];
            cell.imgDisclosure.hidden = NO;
            cell.lblRight.hidden = YES;
            cell.lblLeft.hidden = NO;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        NSArray *array = [self.dataArray objectAtIndex:indexPath.section];
        if (indexPath.row >= array.count) {
            BqsLog(@"indexPaht.row:%d >= array.count:%d",indexPath.row,array.count);
            return cell;
        }
        cell.lblLeft.text = [array objectAtIndex:indexPath.row];
        
        return cell;
        
        
    }else if(indexPath.section == 2){
        
        FTSUserSocialCell *cell = [aTableView dequeueReusableCellWithIdentifier:socailIndet];
        if (cell == nil) {
            cell = [[FTSUserSocialCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:socailIndet];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        NSArray *array = [self.dataArray objectAtIndex:indexPath.section];
        if (indexPath.row >= array.count) {
            BqsLog(@"indexPaht.row:%d >= array.count:%d",indexPath.row,array.count);
            return cell;
        }
        
        
        NSDictionary *snsAccountDic = [UMSocialAccountManager socialAccountDictionary];
        
        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:[array objectAtIndex:indexPath.row]];
        
        UMSocialAccountEntity *accountEnitity = [snsAccountDic valueForKey:snsPlatform.platformName];
        
        
        
        UISwitch *oauthSwitch = nil;
        if ([cell viewWithTag:snsPlatform.shareToType]) {
            oauthSwitch = (UISwitch *)[cell viewWithTag:snsPlatform.shareToType];
        }
        else{
            oauthSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 10, 40, 20)];
            
            oauthSwitch.tag = snsPlatform.shareToType;
            [cell addSubview:oauthSwitch];
        }
        oauthSwitch.center = CGPointMake(aTableView.bounds.size.width - 70, 35);
        
        [oauthSwitch addTarget:self action:@selector(onSwitchOauth:) forControlEvents:UIControlEventValueChanged];
        
        NSString *showUserName = nil;
        
        //这里判断是否授权
        if ([UMSocialAccountManager isOauthWithPlatform:snsPlatform.platformName]) {
            [oauthSwitch setOn:YES];
            //这里获取到每个授权账户的昵称
            showUserName = accountEnitity.userName;
        }
        else {
            [oauthSwitch setOn:NO];
            showUserName = [NSString stringWithFormat:@"尚未授权"];
        }
        
        if ([showUserName isEqualToString:@""]) {
            cell.textLabel.text = @"已授权";
        }
        else{
            cell.textLabel.text = showUserName;
        }
        
        cell.imageView.image = [UIImage imageNamed:snsPlatform.smallImageName];
        
        return cell;
    }
    
    
    return nil;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 ) {
        return 140;
    }else if(indexPath.section == 1){
        return 50;
    }else if(indexPath.section == 2){
        return 70;
    }
    
    return 10;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            FTSPubulishMessageViewController *publishedViewController = [[FTSPubulishMessageViewController alloc] initWithUser:_user];
            [FTSUIOps flipNavigationController:self.flipboardNavigationController pushNavigationWithController:publishedViewController];
            return;
        }else if(indexPath.row == 1){
            FTSCollectMessageViewController *collectController = [[FTSCollectMessageViewController alloc] initWithUser:_user];
            [FTSUIOps flipNavigationController:self.flipboardNavigationController pushNavigationWithController:collectController];
        }
        
    }
    
    
}

-(void)onSwitchOauth:(UISwitch *)switcher
{
    _changeSwitcher = switcher;
    
    if (switcher.isOn == YES) {
        [switcher setOn:NO];
        
        //此处调用授权的方法,你可以把下面的platformName 替换成 UMShareToSina,UMShareToTencent等
        NSString *platformName = [UMSocialSnsPlatformManager getSnsPlatformString:switcher.tag];
        
        //下面设置获取关闭页面的回调方法
        [UMSocialControllerService defaultControllerService].socialUIDelegate = self;
        
        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:platformName];
        snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
            
            if (response.responseCode == UMSResponseCodeSuccess) {
                
                UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:platformName];
                BqsLog(@"username is %@, uid is %@, token is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken);
                
                UnionLogoinType socailType = UnionLogoinTypeSina;
                
                switch (switcher.tag) {
                    case UMSocialSnsTypeSina:
                        socailType = UnionLogoinTypeSina;
                        break;
                    case UMSocialSnsTypeTenc:
                        socailType = UnionLogoinTypeTenc;
                        break;
                    case UMSocialSnsTypeMobileQQ:
                        socailType = UnionLogoinTypeMobileQQ;
                        break;
                    default:
                        socailType = UnionLogoinTypeSina;
                        break;
                }
                
                [[FTSDataMgr sharedInstance] attachUnionWithSocailUserName:snsAccount.usid nickName:snsAccount.userName iconUrl:snsAccount.iconURL type:socailType];
                [self.tableView reloadData];
            }
        });
        
    }
    else {
        UIActionSheet *unOauthActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"button.cancle", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"joke.userinfo.unoauth", nil), nil];
        unOauthActionSheet.destructiveButtonIndex = 0;
        unOauthActionSheet.tag = switcher.tag;
        [unOauthActionSheet showInView:self.view];
    }
}

#pragma UIActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == 10000) {
        if(buttonIndex == 0) {
            if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]){
                [self cameraDeviceOpen:nil];
            }else if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary]){
                [self photoLibOpen:nil];
            }
            
        }else if(buttonIndex == 1) {
            if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] && [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary]){
                [self photoLibOpen:nil];
            }else {
                
            }
            
        }else if(buttonIndex == 2) {
            
            
        }
        
    }else{
        
        if (buttonIndex == 0) {
            NSString *platformType = [UMSocialSnsPlatformManager getSnsPlatformString:actionSheet.tag];
            [[UMSocialDataService defaultDataService] requestUnOauthWithType:platformType completion:^(UMSocialResponseEntity *response) {
                [self.tableView reloadData];
            }];
        }
        else {//按取消
            [_changeSwitcher setOn:YES animated:YES];
        }
    }
}

#pragma mark
#pragma mark UserInfoCellDelegate
- (void)userInfoCellDidBeginEditing:(FTSUserInfoCell *)cell{
    BqsLog(@"userInfoCellDidBeginEditing :%@",cell);
    _maskView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_maskView];
    
    [_maskView addGestureRecognizer:_panGesture];
    [_maskView addGestureRecognizer:_tapGesture];
    
}

- (BOOL)userInfoCellShouldReturn:(FTSUserInfoCell *)cell{
    BqsLog(@"userInfoCellShouldReturn :%@",cell);
    [_maskView removeGestureRecognizer:_tapGesture];
    [_maskView removeGestureRecognizer:_panGesture];
    
    [_maskView removeFromSuperview];
    
    return YES;
}


- (void)userInfoCellRegisterFirstResponder:(FTSUserInfoCell *)cell{
    BqsLog(@"userInfoCellShouldReturn :%@",cell);
    [_maskView removeGestureRecognizer:_tapGesture];
    [_maskView removeGestureRecognizer:_panGesture];
    
    [_maskView removeFromSuperview];
}

- (void)userInfoCellChangePassword:(FTSUserInfoCell *)cell{
    BqsLog(@"userInfoCellChangePassword :%@",cell);
    FTSResetPasswordViewController *resetViewController = [[FTSResetPasswordViewController alloc] initWithNibName:nil bundle:nil];
    [FTSUIOps flipNavigationController:self.flipboardNavigationController pushNavigationWithController:resetViewController];
    
}

- (void)userInfoCellTapIconView:(FTSUserInfoCell *)cell{
    BqsLog(@"userInfoCellTapIconView :%@",cell);
    
    if (!_canEdit) { //other info ,can not be edit
        BqsLog(@"check other use infomation,can not be edit");
        return;
    }
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"joke.publish.image.option", nil) delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    
    NSUInteger cancelIndex = 0;
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        [sheet addButtonWithTitle:NSLocalizedString(@"joke.publish.image.camera", nil)];
        cancelIndex++;
    }
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary]) {
        [sheet addButtonWithTitle:NSLocalizedString(@"joke.publish.image.library", nil)];
        cancelIndex++;
    }
    [sheet addButtonWithTitle:NSLocalizedString(@"button.cancle", nil)];
    sheet.cancelButtonIndex = cancelIndex;
    sheet.tag = 10000;
    [sheet showInView:self.view];
    
}



//调用照相机
- (void)cameraDeviceOpen:(id)sender
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        [HMPopMsgView showPopMsg:NSLocalizedString(@"joke.publish.nocamera", nil)];
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = (id<UINavigationControllerDelegate,UIImagePickerControllerDelegate>)self;
    picker.allowsEditing = NO;
    picker.sourceType = sourceType;
    [self presentModalViewController:picker animated:YES];
    
}
//调用图库
- (void)photoLibOpen:(id)sender
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary]) {
        [HMPopMsgView showPopMsg:NSLocalizedString(@"joke.publish.nolibrary", nil)];
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = (id<UINavigationControllerDelegate,UIImagePickerControllerDelegate>)self;
    picker.allowsEditing = NO;
    picker.sourceType = sourceType;
    [self presentModalViewController:picker animated:YES];
    
}

#pragma mark UIImagePickerControllerDelegate
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissModalViewControllerAnimated:YES];
    
    UIImage *image =  [info objectForKey:UIImagePickerControllerOriginalImage];
    
    
    
    self.iconImage = image;
    
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissModalViewControllerAnimated:YES];
}


- (NSData *)imageScale:(UIImage *)img{//图片处理，压缩图片
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    CGSize size = img.size;
    size_t pixelsWide = size.width;
    size_t pixelsHigh = size.height;
    
    if (pixelsWide>kBookMaxWidht || pixelsHigh>kBookMaxWidht) {
        if (pixelsWide >= pixelsHigh) {
            pixelsWide = kBookMaxWidht;
            pixelsHigh = size.height*pixelsWide/size.width;
        }else if(pixelsHigh>pixelsWide){
            pixelsHigh = kBookMaxWidht;
            pixelsWide = size.width*pixelsHigh/size.height;
        }
    }
    size.width = pixelsWide;
    size.height = pixelsHigh;
    
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    NSData *data = UIImageJPEGRepresentation(scaledImage, 0.6);
    return data;
    
}




#pragma mark
#pragma mark GestureRecognizer

- (void)tapGestureRecognizer:(UITapGestureRecognizer *)recognizer {
    [self.userInfoCell registerFirstResponder];
}

- (void)panGestureRecognizer:(UIPanGestureRecognizer *)recognizer{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged:
            break;
        case UIGestureRecognizerStateEnded:
            [self.userInfoCell registerFirstResponder];
            break;
        case UIGestureRecognizerStateFailed:
            [self.userInfoCell registerFirstResponder];
            break;
            
        default:
            [self.userInfoCell registerFirstResponder];
            break;
    }
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
