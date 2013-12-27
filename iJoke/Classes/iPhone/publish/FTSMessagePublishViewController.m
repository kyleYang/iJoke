//
//  FTSMessagePublishViewController.m
//  iJoke
//
//  Created by Kyle on 13-9-6.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSMessagePublishViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MBProgressHUD.h"
#import "HMPopMsgView.h"
#import "FTSDataMgr.h"
#import "FTSNetwork.h"
#import "Draft.h"
#import "Msg.h"
#import "FTSImageEditViewController.h"
#import "CustomUIBarButtonItem.h"
#import <QuartzCore/QuartzCore.h>
#import "PanguCheckButton.h"
#import "UMSocial.h"

#define kButtonGap 8
#define kKeyboardAnimationID @"ResizeForKeyboard"

#define kActivityShowWidth 80
#define kActivityShowHight 80

#define kToolPanHeight 60

#define kImgWidth 50
#define kImgHeigh 50

#define kAnonymousWidth 36
#define kAnonymousHeight 50

#define kSocailWidth 30
#define kSocailHeight 30

#define kMaxCharLength 280

#define kBookMaxWidht 1280

@interface FTSMessagePublishViewController ()<UITextViewDelegate>
{
    Downloader *_downloader;
    NSArray *_contentArray;
    NSMutableArray *_haveAddArray;
    NSInteger _getWeboInfoTaskID;
    NSInteger _publisWeibTaskID;
    BOOL _keyBordHaveShow;
    BOOL _isRoot;
    __block BOOL _sharePlatformSuccess;
    int _nTaskID;
    MBProgressHUD *activityNotice;
    CGFloat _keyHeight;
    
}

@property (nonatomic, strong) UIImageView *panel;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *imageButton;
@property (nonatomic, strong) PanguCheckButton *anonymousButton;
@property (nonatomic, strong) UIButton *sinaButton;
@property (nonatomic, strong) UIButton *qzoneButton;
@property (nonatomic, strong) UIButton *tencentButton;



@property (nonatomic, strong) FTSImageEditViewController *imageEditor;
@property (nonatomic, strong) ALAssetsLibrary *library;

@property (nonatomic, strong) UIImage *publishImage;

@property (nonatomic, assign) NSUInteger wordNumber;
@property (nonatomic, assign) BOOL edited;

@property (nonatomic, strong) Downloader *downloader;
@property (nonatomic, strong) NSMutableArray *sharPlantformArray;

@end

@implementation FTSMessagePublishViewController
@synthesize downloader = _downloader;
@synthesize publishImage = _publishImage;
@synthesize wordNumber = _wordNumber;
@synthesize edited = _edited;

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
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    Env *env = [Env sharedEnv];
    UIImage *revealLeftImagePortrait = [env cacheImage:@"content_navigationbar_back.png"];
    UIImage *revealLeftImageLandscape = [env cacheImage:@"content_navigationbar_back_highlighted.png"];
    
    UIImage *revealRightImagePortrait = [env cacheImage:@"navigationbar_account_check_os7.png"];
    UIImage *revealRightImageLandscape = [env cacheImage:@"navigationbar_account_check_highlighted_os7.png"];
    
    if (DeviceSystemMajorVersion() >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeAll;
        self.extendedLayoutIncludesOpaqueBars  = YES;
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    
    self.navigationItem.leftBarButtonItem = [CustomUIBarButtonItem initWithImage:revealLeftImagePortrait eventImg:revealLeftImageLandscape title:nil target:self action:@selector(backSuper:)];
    
    self.navigationItem.rightBarButtonItem = [CustomUIBarButtonItem initWithImage:revealRightImagePortrait eventImg:revealRightImageLandscape title:nil target:self action:@selector(publishMessage:)];
    
    
    self.navigationItem.title = NSLocalizedString(@"joke.publish.title", nil);
    
    self.contentView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-kToolPanHeight)];
    self.contentView.textColor = [UIColor blackColor];//设置textview里面的字体颜色
    self.contentView.font = [UIFont fontWithName:@"Georgia" size:15.0];//设置字体名字和字体大小
    self.contentView.delegate = self;//设置它的委托方法
    self.contentView.text = self.contentStr;
    self.contentView.backgroundColor = [UIColor whiteColor];//设置它的背景颜色
    self.contentView.returnKeyType = UIReturnKeyDefault;//返回键的类型
    self.contentView.keyboardType = UIKeyboardTypeDefault;//键盘类型
    self.contentView.scrollEnabled = YES;//是否可以拖动
    self.contentView.selectedRange = NSMakeRange(0, 0);
    [self.view addSubview: self.contentView];//加入到整个页面中
    
    BqsLog(@"the contentView orgX = %f,Height = %f",CGRectGetMinY(self.contentView.frame),CGRectGetHeight(self.contentView.frame));
    
    
    self.panel = [[UIImageView alloc] initWithFrame:CGRectMake(0,CGRectGetHeight(self.view.bounds)-kToolPanHeight, self.view.frame.size.width, kToolPanHeight)];
    self.panel.userInteractionEnabled = YES;
    self.panel.backgroundColor = [UIColor clearColor];
    self.panel.image = [[Env sharedEnv] cacheResizableImage:@"toolbar_translucent_background.png" WithCapInsets:UIEdgeInsetsMake(0, 1, 5, 5)];
    
    self.imageButton = [[UIButton alloc] initWithFrame:CGRectMake(10, (CGRectGetHeight(self.panel.frame)-kImgHeigh)/2, kImgWidth, kImgHeigh)];
    [self.imageButton addTarget:self action:@selector(imageOption:) forControlEvents:UIControlEventTouchUpInside];
    self.imageButton.clipsToBounds = TRUE;
    self.imageButton.layer.cornerRadius =10.0f;
    self.imageButton.layer.masksToBounds = TRUE;
    [self.panel addSubview:self.imageButton];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.imageButton.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.image = [[Env sharedEnv] cacheImage:@"publish_image_default.png"];
    [self.imageButton addSubview:self.imageView];
    
    self.anonymousButton = [[PanguCheckButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.imageButton.frame)+18,(CGRectGetHeight(self.panel.frame)-kAnonymousHeight)/2, kAnonymousWidth,kAnonymousHeight)] ;
    self.anonymousButton.style = CheckButtonStyleBox;
    self.anonymousButton.label.text = NSLocalizedString(@"joke.comment.anonymous", nil);
    self.anonymousButton.label.font = [UIFont systemFontOfSize:11];
    [self.anonymousButton setChecked:FALSE];
    [self.panel addSubview:self.anonymousButton];
    
    self.sinaButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.anonymousButton.frame)+15, (CGRectGetHeight(self.panel.frame)-kSocailHeight)/2 , kSocailWidth, kSocailHeight)];
    [self.sinaButton setBackgroundImage:[env cacheImage:@"share_platform_sina_gray.png"] forState:UIControlStateNormal];
    [self.sinaButton setBackgroundImage:[env cacheImage:@"share_platform_sina.png"] forState:UIControlStateSelected];
    [self.sinaButton addTarget:self action:@selector(sharePlatformLink:) forControlEvents:UIControlEventTouchUpInside];
    self.sinaButton.clipsToBounds = TRUE;
    self.sinaButton.layer.cornerRadius =kSocailWidth/2;
    self.sinaButton.layer.masksToBounds = TRUE;
    [self.panel addSubview:self.sinaButton];
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
    self.sinaButton.tag = snsPlatform.shareToType;
    NSString *platformName = [UMSocialSnsPlatformManager getSnsPlatformString:snsPlatform.shareToType];
    self.sinaButton.selected = [UMSocialAccountManager isOauthWithPlatform:platformName];
    
    self.qzoneButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.sinaButton.frame)+kButtonGap, CGRectGetMinY(self.sinaButton.frame) , CGRectGetWidth(self.sinaButton.frame), CGRectGetHeight(self.sinaButton.frame))];
    [self.qzoneButton setBackgroundImage:[env cacheImage:@"share_platform_qzone_gray.png"] forState:UIControlStateNormal];
    [self.qzoneButton setBackgroundImage:[env cacheImage:@"share_platform_qzone.png"] forState:UIControlStateSelected];
    [self.qzoneButton addTarget:self action:@selector(sharePlatformLink:) forControlEvents:UIControlEventTouchUpInside];
    self.qzoneButton.clipsToBounds = TRUE;
    self.qzoneButton.layer.cornerRadius =self.sinaButton.layer.cornerRadius;
    self.qzoneButton.layer.masksToBounds = TRUE;
    [self.panel addSubview:self.qzoneButton];
    snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQzone];
    self.qzoneButton.tag = snsPlatform.shareToType;
    platformName = [UMSocialSnsPlatformManager getSnsPlatformString:snsPlatform.shareToType];
    self.qzoneButton.selected = [UMSocialAccountManager isOauthWithPlatform:platformName];
    
    self.tencentButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.qzoneButton.frame)+kButtonGap, CGRectGetMinY(self.sinaButton.frame) , CGRectGetWidth(self.sinaButton.frame), CGRectGetHeight(self.sinaButton.frame))];
    [self.tencentButton  setBackgroundImage:[env cacheImage:@"share_platform_tencent_gray.png"] forState:UIControlStateNormal];
    [self.tencentButton  setBackgroundImage:[env cacheImage:@"share_platform_tencent.png"] forState:UIControlStateSelected];
    [self.tencentButton  addTarget:self action:@selector(sharePlatformLink:) forControlEvents:UIControlEventTouchUpInside];
    self.tencentButton.clipsToBounds = TRUE;
    self.tencentButton.layer.cornerRadius =self.sinaButton.layer.cornerRadius;
    self.tencentButton.layer.masksToBounds = TRUE;
    [self.panel addSubview:self.tencentButton];
    snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToTencent];
    self.tencentButton.tag = snsPlatform.shareToType;
    platformName = [UMSocialSnsPlatformManager getSnsPlatformString:snsPlatform.shareToType];
    self.tencentButton.selected = [UMSocialAccountManager isOauthWithPlatform:platformName];
    
    self.wordNum = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.tencentButton.frame)+15, 20, 40, 20)];
    self.wordNum.textAlignment = UITextAlignmentCenter;
    self.wordNum.font = [UIFont systemFontOfSize:12.0f];
    self.wordNum.text = @"0";
    self.wordNum.backgroundColor = [UIColor clearColor];
    [self.panel addSubview:self.wordNum];
    
    BqsLog(@"the panel orgX = %f,Height = %f",CGRectGetMinY(self.panel.frame),CGRectGetHeight(self.panel.frame));
    [self.view addSubview:self.panel];
    
    activityNotice = [[MBProgressHUD alloc] initWithView:self.view];
    activityNotice.mode = MBProgressHUDModeIndeterminate;
    activityNotice.animationType = MBProgressHUDAnimationZoom;
    activityNotice.opacity = 0.5;
    activityNotice.labelText = NSLocalizedString(@"joke.publish.publishing", nil);
    [self.view addSubview:activityNotice];
    [activityNotice hide:YES];
    
    [self loadDraftData];
    
    //    self.library = [[ALAssetsLibrary alloc] init];
    
    self.downloader = [[Downloader alloc] init];
    self.downloader.bSearialLoad = YES;
    
    _keyBordHaveShow = NO;
    
    
}

- (void)viewDidUnload
{
    [_downloader cancelAll];
    _downloader = nil;
    self.contentView = nil;
    self.wordNum = nil;
    self.panel = nil;
    self.anonymousButton = nil;
    self.sinaButton = nil;
    self.tencentButton = nil;
    self.qzoneButton = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChange:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_downloader cancelAll];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [super viewWillDisappear:animated];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


#pragma mark
#pragma mark porperty
- (void)setPublishImage:(UIImage *)publishImage
{
    if (_publishImage == publishImage)return;
    _publishImage = publishImage;
    if (_publishImage) {
        self.imageView.image = _publishImage;
        _edited = YES;
        
    }else {
        self.imageView.image = [[Env sharedEnv] cacheImage:@"publish_image_default.png"]; //default image;
        if (self.contentView.text.length <= 1) {
            _edited = FALSE;
        }
        
    }
}


- (void)setWordNumber:(NSUInteger)wordNumber{
    if (_wordNumber == wordNumber) return;
    
    _wordNumber = wordNumber;
    
    if (_wordNumber>kMaxCharLength) {
        self.wordNum.textColor = [UIColor redColor];
    }else{
        self.wordNum.textColor = [UIColor blackColor];
    }
    
    self.wordNum.text = [NSString stringWithFormat:@"%d",_wordNumber/2];
    
}




#pragma mark
#pragma mark camera method

- (void)sharePlatformLink:(id)sender{
    
    UIButton *button = (UIButton *)sender;
    
    NSString *platformName = [UMSocialSnsPlatformManager getSnsPlatformString:button.tag];
    if(![UMSocialAccountManager isOauthWithPlatform:platformName]){ //not link
        
        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:platformName];
        snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
            
            if (response.responseCode == UMSResponseCodeSuccess) {
                
                UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:platformName];
                BqsLog(@"username is %@, uid is %@, token is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken);
                
                UnionLogoinType socailType = UnionLogoinTypeSina;
                
                switch (button.tag) {
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
                button.selected = YES;
                
            }
        });
        
        return;
        
    }
    
    button.selected = !button.selected;
    
}


- (void)imageOption:(id)sender{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"joke.publish.image.option", nil) delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    
    NSUInteger cancelIndex = 0;
    if (self.publishImage) {
        [sheet addButtonWithTitle:NSLocalizedString(@"joke.publish.image.delete", nil)];
        cancelIndex++;
    }
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
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex //选择分享方式
{
    if(buttonIndex == 0) {
        if (self.publishImage) {
            [self deleteImage:nil];
        }else if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]){
            [self cameraDeviceOpen:nil];
        }else if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary]){
            [self photoLibOpen:nil];
        }
        
    }else if(buttonIndex == 1) {
        if (self.publishImage && [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
            [self cameraDeviceOpen:nil];
            
        }else if(self.publishImage == nil && [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary]){
            [self photoLibOpen:nil];
        }else {
            
        }
        
    }else if(buttonIndex == 2) {
        if (self.publishImage && [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary]) {
            [self photoLibOpen:nil];
        }
        
    }
    
    
}

//删除照片
- (void)deleteImage:(id)sender{
    
    self.publishImage = nil;
    NSString *path = [[FTSDataMgr sharedInstance].publishPath stringByAppendingPathComponent:kJokePublishImg];
    [BqsUtils deletePath:path];
    self.imageView.image = [[Env sharedEnv] cacheImage:@"publish_image_default.png"];
    
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
    
    
    UIImage *image =  [info objectForKey:UIImagePickerControllerOriginalImage];
    //    NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    
    __weak FTSMessagePublishViewController *wself = self;
    
    wself.publishImage = image;
    [picker dismissViewControllerAnimated:YES completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *path = [[FTSDataMgr sharedInstance].publishPath stringByAppendingPathComponent:kJokePublishImg];
            [BqsUtils deletePath:path];
            NSFileManager *fm = [[NSFileManager alloc] init];
            NSData* data = UIImagePNGRepresentation(wself.publishImage);
            [fm createFileAtPath:path contents:data  attributes:nil];
        });
        
        
    }];
    
    
    
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ //parase xml and save data to database;
    //
    //                       wself.edited = TRUE;
    //                        NSString *path = [[FTSDataMgr sharedInstance].publishPath stringByAppendingPathComponent:kJokePublishImg];
    //                        [BqsUtils deletePath:path];
    //                        NSFileManager *fm = [[NSFileManager alloc] init];
    //                        NSData* data = UIImagePNGRepresentation(wself.publishImage);
    //                        [fm createFileAtPath:path contents:data  attributes:nil];
    //
    //                });
    
    
    
    
    //    self.imageEditor = [[FTSImageEditViewController alloc] initWithNibName:nil bundle:nil];
    //    self.imageEditor.checkBounds = YES;
    //
    //    __weak FTSMessagePublishViewController *wself = self;
    //
    //    self.imageEditor.doneCallback = ^(UIImage *editedImage, BOOL canceled){
    //        if(!canceled) {
    //            wself.publishImage = editedImage;
    //
    //            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ //parase xml and save data to database;
    //
    //                wself.edited = TRUE;
    //                NSString *path = [[FTSDataMgr sharedInstance].publishPath stringByAppendingPathComponent:kJokePublishImg];
    //                [BqsUtils deletePath:path];
    //                NSFileManager *fm = [[NSFileManager alloc] init];
    //                NSData* data = UIImagePNGRepresentation(wself.publishImage);
    //                [fm createFileAtPath:path contents:data  attributes:nil];
    //
    //            });
    //
    //
    //             [picker dismissModalViewControllerAnimated:YES];
    //        }else{
    //            [picker popViewControllerAnimated:YES];
    //        }
    //
    //    };
    //
    //
    //
    //    [self.library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
    //        UIImage *preview = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
    //
    //        self.imageEditor.sourceImage = image;
    //        self.imageEditor.previewImage = image;
    ////        [self.imageEditor reset:NO];
    //
    //
    //        [picker pushViewController:self.imageEditor animated:YES];
    //        [picker setNavigationBarHidden:YES animated:NO];
    //
    //    } failureBlock:^(NSError *error) {
    //        NSLog(@"Failed to get asset from library");
    //    }];
    
    
    
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissModalViewControllerAnimated:YES];
}



#pragma mark
#pragma mark edit method

- (int)getStringLength:(NSString*)strtemp //Chinese char length = 2 ,and English char = 1

{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData* da = [strtemp dataUsingEncoding:enc];
    return da.length;
}



- (void)textViewDidChange:(UITextView *)textView
{
    _edited = TRUE;
    self.wordNumber = [self getStringLength:textView.text];
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

//- (void)textViewDidBeginEditing:(UITextView *)textView {
//
//    self.navigationItem.rightBarButtonItem = [CustomUIBarButtonItem initWithImage:[_env cacheScretchableImage:@"pg_bar_done.png" X:kBarStrePosX Y:kBarStrePosY] eventImg:[_env cacheScretchableImage:@"pg_bar_donedown.png" X:kBarStrePosX Y:kBarStrePosY]  title:NSLocalizedString(@"pg.all.done", nil) target:self action:@selector(leaveEditMode)];
//
//}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
}


#pragma mark
#pragma mark UINavigation button method
- (void)backSuper:(id)sender{
    
    if (_edited) {
        if (self.publishImage || self.contentView.text.length > 0) {
            UIAlertView *notice = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"joke.publish.savemessage", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"button.sure", nil) otherButtonTitles:NSLocalizedString(@"button.cancle", nil), nil];
            [notice show];
            return;
        }
    }
    [self popflipboard];
    
}

- (void)publishMessage:(id)sender{
    [self.contentView resignFirstResponder];
    
    if (_nTaskID > 0) {
        BqsLog(@"publish message nowing");
        return;
    }
    
    if (!_edited) {
        [HMPopMsgView showPopMsg:NSLocalizedString(@"joke.publish.nomessage", nil)];
        return;
    }
    
    NSMutableData *data = nil;
    NSString *sBoundary = @"";
    NSString *sImageName = nil;
    if (self.publishImage != nil) {
        NSData * imgData = [self imageScale:self.publishImage];
        data = [NSMutableData dataWithData:imgData];
        sImageName = @"image.png";
    }
    
    _nTaskID =  [FTSNetwork publishMessageDownloader:self.downloader Target:self Sel:@selector(publishCB:) Attached:nil Content:self.contentView.text ShowUser:self.anonymousButton.isChecked Title:nil FileName:sImageName Data:data ContentType:@"Content-Type"];
    activityNotice.labelText = NSLocalizedString(@"joke.publish.publishing", nil);
    [activityNotice show:TRUE];
    
    self.sharPlantformArray = [NSMutableArray arrayWithCapacity:3];
    if (self.sinaButton.selected) {
        [self.sharPlantformArray addObject:UMShareToSina];
    }
    if (self.qzoneButton.selected) {
        [self.sharPlantformArray addObject:UMShareToQzone];
    }
    if (self.tencentButton.selected) {
        [self.sharPlantformArray addObject:UMShareToTencent];
    }
    
    //    __weak FTSMessagePublishViewController *weakSelf = self;
    if ([self.sharPlantformArray count] != 0) {
        _sharePlatformSuccess = NO;
        [[UMSocialDataService defaultDataService]  postSNSWithTypes:self.sharPlantformArray content:self.contentView.text  image:self.publishImage location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *shareResponse){
            if (shareResponse.responseCode == UMSResponseCodeSuccess) {
                _sharePlatformSuccess = YES;
                if (_nTaskID <= 0 ) {
                    [activityNotice hide:YES];
                }
            }
        }];
        
    }
    
    
    
    
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



- (void)popflipboard{
    [self.flipboardNavigationController popViewController];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        
        [self savePublishMessage];
        [self popflipboard];
    }else if (buttonIndex == 1){
        [self deleteImage:nil];
        [self popflipboard];
    }
    
}


- (void)loadDraftData{
    
    NSString *path = [[FTSDataMgr sharedInstance].publishPath stringByAppendingPathComponent:kJokePublishImg];
    NSData *imgData = [NSData dataWithContentsOfFile:path];
    
    if (imgData) {
        _edited = TRUE;
        self.publishImage = [UIImage imageWithData:imgData];
    }
    
    NSData *messageData = [NSData dataWithContentsOfFile:[[FTSDataMgr sharedInstance].publishPath stringByAppendingPathComponent:kJokePublishMeesage]];
    if (messageData) {
        _edited = TRUE;
        NSArray *ary = [Draft parseXmlData:messageData];
        Draft *draft = nil;
        if (ary.count>0) {
            draft = [ary objectAtIndex:0];
        }else {
            BqsLog(@"draft read message count == 0");
            return;
        }
        
        NSString *content = draft.content;
        
        NSUInteger length = [self getStringLength:content];
        self.wordNumber = length;
        self.contentView.text = content;
        self.contentView.selectedRange = NSMakeRange(length/2, 0);
    }
    [BqsUtils deletePath:[[FTSDataMgr sharedInstance].publishPath stringByAppendingPathComponent:kJokePublishMeesage]];
    
}

- (void)savePublishMessage
{
    
    
    NSMutableArray *savedAry = [[NSMutableArray alloc] initWithCapacity:1];
    
    Draft *save = [[Draft alloc] init];
    
    NSDate *date = [NSDate date]; //获得微博保存时间按
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *str = [formatter stringFromDate:date];
    [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    
    NSString *pngPath = [[FTSDataMgr sharedInstance].publishPath stringByAppendingPathComponent:kJokePublishImg];
    
    save.title = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"joke.publish.draft", nil),str];
    save.content = self.contentView.text;
    save.picurl = pngPath;
    
    [savedAry addObject:save]; //保存微博到xml
    
    [Draft saveToFile:[[FTSDataMgr sharedInstance].publishPath stringByAppendingPathComponent:kJokePublishMeesage] Arr:savedAry];
    
}


#pragma mark
#pragma mark publish message cb
- (void)publishCB:(DownloaderCallbackObj *)cb{
    BqsLog(@"FTSMessagePublish publishCB:%@",cb);
    
    _nTaskID = -1;
    
    if ([self.sharPlantformArray count] != 0 && !_sharePlatformSuccess) {
        activityNotice.labelText = NSLocalizedString(@"joke.publish.shareing", nil);
    }else{
        [activityNotice hide:TRUE];
    }
    
    if(nil == cb) return;
    
    if(nil != cb.error || 200 != cb.httpStatus) {
		BqsLog(@"Error: len:%d, http%d, %@", [cb.rspData length], cb.httpStatus, cb.error);
        [HMPopMsgView showPopError:cb.error];
        return;
	}
    
    Msg *msg = [Msg parseJsonData:cb.rspData];
    [HMPopMsgView showPopMsg:msg.msg];
    if (!msg.code) {
        return;
    }
    self.contentView.text = @"";
    [self deleteImage:nil];
    _edited = FALSE;
    
}




#pragma mark
#pragma mark KeyBoard Notifacation
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    if (_keyBordHaveShow) {
        return;
    }
    
    CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = self.contentView.frame;
    CGRect panelFram = self.panel.frame;
    frame.size.height -= keyboardRect.size.height;
    panelFram.origin.y -= keyboardRect.size.height;
    _keyHeight = keyboardRect.size.height;
    _keyBordHaveShow = YES;
    [UIView beginAnimations:kKeyboardAnimationID context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.contentView.frame = frame;
    self.panel.frame = panelFram;
    
    [UIView commitAnimations];
    
    
    
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    if (!_keyBordHaveShow) {
        return;
    }
    
    CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = self.contentView.frame;
    CGRect panelFram = self.panel.frame;
    //    CGRect activityFram = activityNotice.frame;
    frame.size.height += keyboardRect.size.height;
    panelFram.origin.y += keyboardRect.size.height;
    _keyHeight = 0.0f;
    //    activityFram.size.height = self.view.frame.size.height;
    _keyBordHaveShow = NO;
    [UIView beginAnimations:kKeyboardAnimationID context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.contentView.frame = frame;
    self.panel.frame = panelFram;
    [UIView commitAnimations];
    //    activityNotice.frame = activityFram;
}


- (void)keyboardFrameChange:(NSNotification *)aNotification
{
    
    CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat chHeight = keyboardRect.size.height - _keyHeight;
    CGRect frame = self.contentView.frame;
    CGRect panelFram = self.panel.frame;
    frame.size.height -= chHeight;
    panelFram.origin.y -= chHeight;
    self.contentView.frame = frame;
    self.panel.frame = panelFram;
    _keyHeight = keyboardRect.size.height;
    
    
}




@end
