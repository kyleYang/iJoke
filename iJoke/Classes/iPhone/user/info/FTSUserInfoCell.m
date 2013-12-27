//
//  FTSUserInfoCell.m
//  iJoke
//
//  Created by Kyle on 13-8-26.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSUserInfoCell.h"
#import <QuartzCore/QuartzCore.h>

#define kIcon_X 20
#define kIcon_Y 10
#define kIcon_W 80
#define kIcon_H 80

#define kIconNameGap 10
#define kNameHeight 30
#define kNameSignGap 10


@interface FTSUserInfoCell()<FTSTextFieldDelegate>

@property (nonatomic, strong, readwrite) FTSCircleImageView *iconView;
@property (nonatomic, strong, readwrite) FTSTextField *nameLable;
@property (nonatomic, strong, readwrite) FTSTextField *signLable;

@property (nonatomic, strong) User *user;


@property (nonatomic, strong) UIButton *changeBtn;

@end

@implementation FTSUserInfoCell
@synthesize user = _user;
@synthesize delegate = _delegate;
@synthesize canEdit = _canEdit;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.iconView = [[FTSCircleImageView alloc] initWithFrame:CGRectMake(kIcon_X, kIcon_Y, kIcon_H, kIcon_W)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
        [self.iconView addGestureRecognizer:tap];
        [self addSubview: self.iconView];
        
        self.nameLable = [[FTSTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.iconView.frame)+kIconNameGap, CGRectGetMinY(self.iconView.frame), CGRectGetWidth(self.bounds)-kIcon_X-CGRectGetMaxX(self.iconView.frame)-kIconNameGap, kNameHeight)];
        self.nameLable.delegate = self;
        [self addSubview:self.nameLable];
        
        self.signLable = [[FTSTextField alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.signLable.frame), CGRectGetMaxY(self.nameLable.frame)+kNameSignGap, CGRectGetWidth(self.nameLable.bounds), CGRectGetHeight(self.nameLable.frame))];
        self.signLable.delegate = self;
//        [self addSubview:self.signLable];
        
        self.changeBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.nameLable.frame) - 100,CGRectGetMaxY(self.nameLable.frame)+20, 100, 15)];
        [self addSubview:self.changeBtn];
        [self.changeBtn setBackgroundColor:[UIColor clearColor]];
        [self.changeBtn addTarget:self action:@selector(changePassword:) forControlEvents:UIControlEventTouchUpInside];
        UILabel *txtLabel = [[UILabel alloc] initWithFrame:self.changeBtn.bounds];
        [self.changeBtn addSubview:txtLabel];
        txtLabel.textColor = HexRGB(0xFF5858);
        txtLabel.font = [UIFont systemFontOfSize:14.0f];
        txtLabel.text =  NSLocalizedString(@"joke.login.changepassword", nil);
        txtLabel.backgroundColor = [UIColor clearColor];
        txtLabel.textAlignment = UITextAlignmentRight;
        
        _canEdit = TRUE;
        
    

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setCanEdit:(BOOL)canEdit{
    
    if (_canEdit == canEdit) return;
    
    _canEdit = canEdit;
    
    if (_canEdit) {
        self.nameLable.textField.enabled = TRUE;
        self.signLable.textField.enabled = TRUE;
    }else{
        self.nameLable.textField.enabled = FALSE;
        self.signLable.textField.enabled = FALSE;
    }
    
    
}

- (void)configCellForWords:(User *)user canEdit:(BOOL)value;{
    
    _user = user;
    _canEdit = value;
    
    if (_canEdit) {
        self.nameLable.textField.enabled = TRUE;
        self.signLable.textField.enabled = TRUE;
        self.changeBtn.hidden = FALSE;
    }else{
        self.nameLable.textField.enabled = FALSE;
        self.signLable.textField.enabled = FALSE;
        self.changeBtn.hidden = TRUE;
    }
    
    self.iconView.frame = CGRectMake(kIcon_X, kIcon_Y, kIcon_H, kIcon_W);
    self.nameLable.frame = CGRectMake(CGRectGetMaxX(self.iconView.frame)+kIconNameGap, CGRectGetMinY(self.iconView.frame), CGRectGetWidth(self.bounds)-kIcon_X-CGRectGetMaxX(self.iconView.frame)-kIconNameGap, kNameHeight);
    self.signLable.frame = CGRectMake(CGRectGetMinX(self.signLable.frame), CGRectGetMaxY(self.nameLable.frame)+kNameSignGap, CGRectGetWidth(self.nameLable.bounds), CGRectGetHeight(self.nameLable.frame));
    self.changeBtn.frame = CGRectMake(CGRectGetMaxX(self.nameLable.frame) - 100,CGRectGetMaxY(self.nameLable.frame)+20, 100, 15);
    
    __weak FTSUserInfoCell *wself = self;
    


    [self.iconView.imageView setImageWithURL:[NSURL URLWithString:_user.icon] placeholderImage:[[Env sharedEnv] cacheImage:@"user_message_icon_default.png"] options:SDWebImageLowPriority progress:^(NSUInteger receiveSize, long long excepectedSize){
        
        if (excepectedSize <= -0) {
            return ;
        }
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
        
        
        wself.iconView.imageView.alpha = 0.0f;
        
        
        [UIView animateWithDuration:0.25 animations:^(void){
            
            wself.iconView.imageView.alpha = 1.0f;
            
        }];
        
        
    }];
    
    if (_user.nikeName && [user.nikeName length] != 0) {
        self.nameLable.text = _user.nikeName;
    }else if(_user.nikeName && [user.nikeName length] != 0){
        self.nameLable.text = _user.userName;
    }
    
    
}

+(float)caculateHeighForWords:(User *)user{
    
    
    return 100;
    
}

#pragma mark
#pragma mark FTSTextFieldDelegate
- (void)textFieldDidBeginEditing:(FTSTextField *)textField{
    if([_delegate respondsToSelector:@selector(userInfoCellDidBeginEditing:)]){
        [_delegate userInfoCellDidBeginEditing:self];
    }
    
}

- (BOOL)textFieldShouldReturn:(FTSTextField *)textField{
    if ([_delegate respondsToSelector:@selector(userInfoCellShouldReturn:)]) {
        return [_delegate userInfoCellShouldReturn:self];
    }
    
    return YES;
}

- (void)registerFirstResponder{
    
    if ([_delegate respondsToSelector:@selector(userInfoCellRegisterFirstResponder:)]) {
        [_delegate userInfoCellRegisterFirstResponder:self];
    }
    
    [self.nameLable.textField resignFirstResponder];
    [self.signLable.textField resignFirstResponder];
}

#pragma mark
#pragma mark UITapGestureRecognizer
- (void)tapGestureRecognizer:(UITapGestureRecognizer *)recognizer{
    
    if ([_delegate respondsToSelector:@selector(userInfoCellTapIconView:)]) {
        [_delegate userInfoCellTapIconView:self];
    }
}

- (void)changePassword:(id)sender{
    if ([_delegate respondsToSelector:@selector(userInfoCellChangePassword:)]) {
        [_delegate userInfoCellChangePassword:self];
    }

}



@end
