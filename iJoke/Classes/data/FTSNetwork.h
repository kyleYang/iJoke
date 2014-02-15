//
//  FTSNetwork.h
//  iJoke
//
//  Created by Kyle on 13-7-30.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Downloader.h"
#import "Constants.h"

@interface FTSNetwork : NSObject

//new words
+(int)newWordsFreshDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att wordId:(int)words;
+(int)newWordsNextDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att wordId:(int)words;



//new image
+(int)newImageFreshDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att imageId:(int)imageId;
+(int)newImageNextDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att imageId:(int)imageId;


//new video
+(int)newVideoFreshDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att videoId:(int)videoId;
+(int)newVideoNextDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att videoId:(int)videoId;

//user way such as ding cai

//type word = 0; image = 1, video = 2;

+(int)dingCaiWordsDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att artId:(int)artId type:(NSInteger)type upDown:(NSInteger)updown;//1 for ding and -1 for cai
+(int)shareCountDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att artId:(int)artId type:(NSInteger)type;//statistics share count
+(int)postCommitDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att artId:(int)artId  comment:(NSString *)comment type:(NSInteger)type hiddenUser:(BOOL)hidden;
+(int)commitListDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att artId:(int)artId page:(NSInteger)page type:(NSInteger)type;
+(int)addFavoriteDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att artId:(int)artId type:(NSInteger)type;
+(int)delFavoriteDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att artId:(int)artId type:(NSInteger)type;
+(int)reportMessageDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att artId:(int)artId type:(NSInteger)type;
+(int)deleteMessageDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att artId:(int)artId type:(NSInteger)type;

//topic
+(int)topicTitleFreshDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att;
+(int)topicImageFreshDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att imageId:(int)imageId topicID:(NSInteger)topicId;
+(int)topicImageNextDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att imageId:(int)imageId topicID:(NSInteger)topicId;
+(int)topicVideoFreshDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att videoId:(int)videoId topicID:(NSInteger)topicId;
+(int)topicVideoNextDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att videoId:(int)videoId topicID:(NSInteger)topicId;

//review
+(int)reviewFreshDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att;
+(int)reviewNextDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att wordId:(int)wordId;
+(int)reviewAuditorDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att wordId:(int)wordId type:(NSInteger)type;

//publish message
+(int)publishMessageDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att Content:(NSString *)content ShowUser:(BOOL)show Title:(NSString *)title FileName:(NSString *)fileName Data:(NSData *)data ContentType:(NSString *)sContentType;

//download m3u8
+(int)videoM3u8Downloader:(Downloader *)dl Url:(NSString *)url PkgFile:(PackageFile *)pkf Target:(id)target  Sel:(SEL)action Attached:(id)att;


//user
+(int)userLoginDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att userName:(NSString *)username password:(NSString *)password;
+(int)userRegisterDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att userName:(NSString *)username password:(NSString *)password;
+(int)saveUserInfoDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att nikeName:(NSString *)nikeName FileName:(NSString *)fileName Data:(NSData *)data ContentType:(NSString *)sContentType;
+(int)passwordResetDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att oldPassword:(NSString *)oldPas newPassword:(NSString *)newPas;
+(int)getRecordMessageDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att;
+(int)loginUnionDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att userName:(NSString *)userName nickName:(NSString *)nikeName iconUrl:(NSString *)iconUrl type:(UnionLogoinType)type userAddType:(UnionLoginUserType)userType;
//userType = 0 ,attach to a user that has exist, userType = 1,add a new user

+(int)collectInfoDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att page:(NSInteger)page userId:(NSString *)userId;

+(int)publishTopInfoDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att userId:(NSString *)userid;
+(int)publishNextInfoDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att jokeId:(NSString *)jokeId userId:(NSString *)userid;

//userAction


@end
