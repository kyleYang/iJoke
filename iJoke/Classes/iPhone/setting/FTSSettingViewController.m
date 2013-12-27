//
//  FTSSettingViewController.m
//  iJoke
//
//  Created by Kyle on 13-12-4.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSSettingViewController.h"
#import "FTSTextIndicateCell.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "iRate.h"
#import "HumDotaHelpViewController.h"

@interface FTSSettingViewController ()<UITableViewDataSource,UITableViewDelegate>{
    
    unsigned long long _totalSize;
}

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSArray *dataArray;
@property (nonatomic, strong) MBProgressHUD *activityNotice;

@end

@implementation FTSSettingViewController

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
    self.navigationItem.title = NSLocalizedString(@"joke.setting.setting", nil);
    
    Env *env = [Env sharedEnv];
    UIImage *revealLeftImagePortrait = [env cacheImage:@"content_navigationbar_back.png"];
    UIImage *revealLeftImageLandscape = [env cacheImage:@"content_navigationbar_back_highlighted.png"];
    
    UIImage *revealRightImagePortrait = [env cacheImage:@"joke_nav_setting.png"];
    UIImage *revealRightImageLandscape = [env cacheImage:@"joke_nav_setting_down.png"];
    
    self.navigationItem.leftBarButtonItem = [CustomUIBarButtonItem initWithImage:revealLeftImagePortrait eventImg:revealLeftImageLandscape title:nil target:self action:@selector(backSuper:)];
    
    
    
	// Do any additional setup after loading the view.
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    //    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    self.tableView.scrollsToTop = YES;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.allowsSelection = YES;
    self.tableView.allowsSelectionDuringEditing = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    //    joke.setting.help
    self.dataArray = @[@[NSLocalizedString(@"joke.setting.cleanmess", nil)],@[NSLocalizedString(@"joke.setting.rate", nil)],@[NSLocalizedString(@"joke.setting.help", nil),NSLocalizedString(@"joke.setting.about", nil)]];
    
    self.activityNotice = [[MBProgressHUD alloc] initWithView:self.view];
    self.activityNotice.mode = MBProgressHUDModeIndeterminate;
    self.activityNotice.animationType = MBProgressHUDAnimationZoom;
    self.activityNotice.screenType = MBProgressHUDFullScreen;
    self.activityNotice.opacity = 0.5;
    self.activityNotice.labelText = NSLocalizedString(@"joke.setting.clearing.mess", nil);
    [self.view addSubview:self.activityNotice];
    [self.activityNotice hide:YES];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
    
    __weak FTSSettingViewController *weakSelf = self;
    
    [[SDImageCache sharedImageCache] calculateSizeWithCompletionBlock:^(NSUInteger fileCount, unsigned long long totalSize){
        
        _totalSize = totalSize;
        [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }];
    
}

- (void)backSuper:(id)sender{
    
    [self.flipboardNavigationController popViewController];
    
}

#pragma mark
#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataArray count];
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionArray = [self.dataArray objectAtIndex:section];
    return [sectionArray count];
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cleanIndentify = @"userinfo";
    static NSString *rateIndent = @"action";
    static NSString *aboutIndent = @"socail";
    
    if (indexPath.section == 0) {
        FTSTextIndicateCell *cell = [aTableView dequeueReusableCellWithIdentifier:cleanIndentify];
        if (cell == nil) {
            cell = [[FTSTextIndicateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cleanIndentify];
            cell.imgDisclosure.hidden = NO;
            cell.lblRight.hidden = NO;
            cell.lblLeft.hidden = NO;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        NSArray *array = [self.dataArray objectAtIndex:indexPath.section];
        if (indexPath.row >= array.count) {
            BqsLog(@"indexPaht.row:%d >= array.count:%d",indexPath.row,array.count);
            return cell;
        }
        cell.lblLeft.text = [array objectAtIndex:indexPath.row];
        if (_totalSize > 10) {
            cell.lblRight.text = [NSString stringWithFormat:@"%0.1f MB",_totalSize/1024.0f/1024.0f];
        }else{
            cell.lblRight.text =@"0 MB";
        }
        
        return cell;
        
    }else if(indexPath.section == 1){
        FTSTextIndicateCell *cell = [aTableView dequeueReusableCellWithIdentifier:rateIndent];
        if (cell == nil) {
            cell = [[FTSTextIndicateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:rateIndent];
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
        FTSTextIndicateCell *cell = [aTableView dequeueReusableCellWithIdentifier:aboutIndent];
        if (cell == nil) {
            cell = [[FTSTextIndicateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:aboutIndent];
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
        
    }
    
    
    return nil;
    
    
}



-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    return 50;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self.activityNotice show:YES];
            __weak FTSSettingViewController *weakSelf = self;
            [[SDImageCache sharedImageCache] clearDiskWithCompletionBlock:^(void){
                _totalSize = 0;
                [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                [weakSelf.activityNotice hide:YES];
            }];
            
        }
    }else if(indexPath.section == 1){
        if (indexPath.row == 0) {
            BqsLog(@"onclickCommit");
            [[iRate sharedInstance] promptForRating];
        }
        
    }else if(indexPath.section == 2){
        if (indexPath.row == 0) {
            HumDotaHelpViewController *help = [[HumDotaHelpViewController alloc] initWithTitle:NSLocalizedString(@"joke.setting.help.title", nil) html:@"help"];
            [FTSUIOps flipNavigationController:self.flipboardNavigationController pushNavigationWithController:help];
        }else if(indexPath.row == 1){
            HumDotaHelpViewController *about = [[HumDotaHelpViewController alloc] initWithTitle:NSLocalizedString(@"joke.setting.about.title", nil) html:@"about"];
            [FTSUIOps flipNavigationController:self.flipboardNavigationController pushNavigationWithController:about];
        }
    }
    
    
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
