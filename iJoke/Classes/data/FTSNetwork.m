//
//  FTSNetwork.m
//  iJoke
//
//  Created by Kyle on 13-7-30.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSNetwork.h"

//newword
#define kSENewWordsFreshList @"newwordsfrsh"
#define kSEDefNewWordsFreshURL @"/ijoke/front/listTopArticle.action"

#define kSENewWordsNextList @"newwordsnext"
#define kSEDefNewWordsNextURL @"/ijoke/front/listNextArticle.action"

//hotword



#define kSEDingWords @"dingwords"
#define kSEDefDingWordsURL @"/ijoke/front/addArticleUpDown.action"

#define kSEShareCountWords @"sharcountwords"
#define kSEDefShareCountWordsURL @"/ijoke/front/addArticleShare.action"

#define kSECommentList @"commentlist"
#define kSEDefCommentListURL @"/ijoke/front/listArticleComment.action"

#define kSECommitWords @"commitwords"
#define kSEDefCommitWordsURL @"/ijoke/front/addArticleComment.action"

#define kSEAddFavWords @"addfavwords"
#define kSEDefAddFavWordsURL @"/ijoke/front/addArticleCollect.action"

#define kSEDelFavWords @"delfavwords"
#define kSEDefDelFavWordsURL @"/ijoke/front/delArticleCollect.action"


//newimage
#define kSENewImageFreshList @"newImagefrsh"
#define kSEDefNewImageFreshURL @"/ijoke/front/listTopPicture.action"

#define kSENewImageNextList @"newImagenext"
#define kSEDefNewImageNextURL @"/ijoke/front/listNextPicture.action"



//new video
#define kSENewVideoFreshList @"newvideofrsh"
#define kSEDefNewVideoFreshURL @"/ijoke/front/listTopVideo.action"

#define kSENewVideoNextList @"newvideonext"
#define kSEDefNewVideoNextURL @"/ijoke/front/listNextVideo.action"


//topic

#define kSETopicTitleFreshList @"topictitlefresh"
#define kSEDefTopicTitleFreshURL @"/ijoke/front/listTopic.action"

//review
#define kSEReviewFreshList @"reviewfresh"
#define kSEDefReviewFreshURL @"/ijoke/front/listTopArticleToAudit.action"

#define kSEReviewNextList @"reviewnext"
#define kSEDefReviewNextURL @"/ijoke/front/listNextArticleToAudit.action"

#define kSEReviewAuditorList @"reviewauditor"
#define kSEDefReviewAuditorURL @"/ijoke/front/addArticleAudit.action"

//publish
#define kSEPublishMessage @"publishmessage"
#define kSEDefPublishMessageURL @"/ijoke/front/addJoke.action"


//user

#define kSEUserLoginAction @"userLogoin"
#define kSEDefUserLogin @"/user/front/login.action"

#define kSEUserRegisterAction @"userRegister"
#define kSEDefUserRegister @"/user/front/addUser.action"

#define kSEUserInfoSaveAction @"userinfosave"
#define kSEDefUserIndosSave @"/user/front/updateUser.action"

#define kSEUserChangePasswordAction @"userpasswordchang"
#define kSEDefUserChangePassword @"/user/front/changePassword.action"

#define kSERecordMessageAction @"recordmessage"
#define kSEDefRecordMessageURL @"/ijoke/front/listCollectAndUpdown.action"

#define kSEUnionLoginAction @"unionlogin"
#define kSEDefUnionLoginURL @"/user/front/unitLogin.action"


//user info
#define kSECollectCheckAction @"collectcheck"
#define kSEDefCollectCheckActionURL @"/ijoke/front/listArticleCollect.action"

#define kSEPublishTopInfoAction @"publishtopinfo"
#define kSEDefPublishTopInfoActionURL @"/ijoke/front/listTopArticleToUser.action"
#define kSEPublishNextInfoAction @"publishnextinfo"
#define kSEDefPublishNextInfoActionURL @"/ijoke/front/listNextArticleToUser.action"

@implementation FTSNetwork


/**
 *	GetNewWordsList
 *
 *	@param	dl	Downloader
 *	@param	target	target
 *	@param	action	action
 *	@param	att	attacth
 *	@param	words	para
 *
 *	@return	taskid
 */
+(int)newWordsFreshDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att wordId:(int)words{
    
    Env *env = [Env sharedEnv];
    NSString *url = [env getSEKey:kSENewWordsFreshList Def:kSEDefNewWordsFreshURL];
    
    url = [BqsUtils setURL:url ParameterName:@"id" Value:[NSString stringWithFormat:@"%d",words]];
    return [dl addTask:url Target:target Callback:action Attached:att];
}


+(int)newWordsNextDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att wordId:(int)words{
    
    Env *env = [Env sharedEnv];
    NSString *url = [env getSEKey:kSENewWordsNextList Def:kSEDefNewWordsNextURL];
    
    url = [BqsUtils setURL:url ParameterName:@"id" Value:[NSString stringWithFormat:@"%d",words]];
    return [dl addTask:url Target:target Callback:action Attached:att];
}









 /**
  *	latest image
  *
  *	@param	dl	dow
  *	@param	target	<#target description#>
  *	@param	action	<#action description#>
  *	@param	att	<#att description#>
  *	@param	imageId	<#imageId description#>
  *
  *	@return	<#return value description#>
  */


+(int)newImageFreshDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att imageId:(int)imageId{
    
    Env *env = [Env sharedEnv];
    NSString *url = [env getSEKey:kSENewImageFreshList Def:kSEDefNewImageFreshURL];
    
    url = [BqsUtils setURL:url ParameterName:@"id" Value:[NSString stringWithFormat:@"%d",imageId]];
    return [dl addTask:url Target:target Callback:action Attached:att];
}


+(int)newImageNextDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att imageId:(int)imageId{
    
    Env *env = [Env sharedEnv];
    NSString *url = [env getSEKey:kSENewImageNextList Def:kSEDefNewImageNextURL];
    
    url = [BqsUtils setURL:url ParameterName:@"id" Value:[NSString stringWithFormat:@"%d",imageId]];
    return [dl addTask:url Target:target Callback:action Attached:att];
}



#pragma makr Video
+(int)newVideoFreshDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att videoId:(int)videoId{
    Env *env = [Env sharedEnv];
    NSString *url = [env getSEKey:kSENewVideoFreshList Def:kSEDefNewVideoFreshURL];
    
    url = [BqsUtils setURL:url ParameterName:@"id" Value:[NSString stringWithFormat:@"%d",videoId]];
    return [dl addTask:url Target:target Callback:action Attached:att];

}
+(int)newVideoNextDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att videoId:(int)videoId{
    Env *env = [Env sharedEnv];
    NSString *url = [env getSEKey:kSENewVideoNextList Def:kSEDefNewVideoNextURL];
    
    url = [BqsUtils setURL:url ParameterName:@"id" Value:[NSString stringWithFormat:@"%d",videoId]];
    return [dl addTask:url Target:target Callback:action Attached:att];

}



#pragma mark ding cai
+(int)dingCaiWordsDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att artId:(int)artId type:(NSInteger)type upDown:(NSInteger)updown{
    
    Env *env = [Env sharedEnv];
    NSString *url = [env getSEKey:kSEDingWords Def:kSEDefDingWordsURL];
    
    url = [BqsUtils setURL:url ParameterName:@"articleId" Value:[NSString stringWithFormat:@"%d",artId]];
    url = [BqsUtils setURL:url ParameterName:@"type" Value:[NSString stringWithFormat:@"%d",type]]; //"0" for words
    url = [BqsUtils setURL:url ParameterName:@"updown" Value:[NSString stringWithFormat:@"%d",updown]];
    return [dl addTask:url Target:target Callback:action Attached:att];
    
}


+(int)shareCountDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att artId:(int)artId type:(NSInteger)type{
    Env *env = [Env sharedEnv];
    NSString *url = [env getSEKey:kSEShareCountWords Def:kSEDefShareCountWordsURL];
    
    url = [BqsUtils setURL:url ParameterName:@"articleId" Value:[NSString stringWithFormat:@"%d",artId]];
    url = [BqsUtils setURL:url ParameterName:@"type" Value:[NSString stringWithFormat:@"%d",type]];
    return [dl addTask:url Target:target Callback:action Attached:att];
}


+(int)postCommitDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att artId:(int)artId  comment:(NSString *)comment type:(NSInteger)type hiddenUser:(BOOL)hidden{//comment should url encode
    
    Env *env = [Env sharedEnv];
    NSString *url = [env getSEKey:kSECommitWords Def:kSEDefCommitWordsURL];
    
    url = [BqsUtils setURL:url ParameterName:@"articleId" Value:[NSString stringWithFormat:@"%d",artId]];
    url = [BqsUtils setURL:url ParameterName:@"comment" Value:[BqsUtils urlEncodedString:comment]];
    url = [BqsUtils setURL:url ParameterName:@"type" Value:[NSString stringWithFormat:@"%d",type]];
    url = [BqsUtils setURL:url ParameterName:@"showUser" Value:[NSString stringWithFormat:@"%d",hidden]]; //hidden:1 hidden user's comment
    return [dl addTask:url Target:target Callback:action Attached:att];
    
    
}


+(int)commitListDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att artId:(int)artId page:(NSInteger)page type:(NSInteger)type{
    Env *env = [Env sharedEnv];
    NSString *url = [env getSEKey:kSECommentList Def:kSEDefCommentListURL];
    
    url = [BqsUtils setURL:url ParameterName:@"articleId" Value:[NSString stringWithFormat:@"%d",artId]];
    url = [BqsUtils setURL:url ParameterName:@"page" Value:[NSString stringWithFormat:@"%d",page]];
    url = [BqsUtils setURL:url ParameterName:@"type" Value:[NSString stringWithFormat:@"%d",type]]; //0 for
    return [dl addTask:url Target:target Callback:action Attached:att];
    
}


+(int)addFavoriteDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att artId:(int)artId type:(NSInteger)type{
    
    Env *env = [Env sharedEnv];
    NSString *url = [env getSEKey:kSEAddFavWords Def:kSEDefAddFavWordsURL];
    
    url = [BqsUtils setURL:url ParameterName:@"articleId" Value:[NSString stringWithFormat:@"%d",artId]];
    url = [BqsUtils setURL:url ParameterName:@"type" Value:[NSString stringWithFormat:@"%d",type]];
    return [dl addTask:url Target:target Callback:action Attached:att];
    
}



+(int)delFavoriteDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att artId:(int)artId type:(NSInteger)type{
    Env *env = [Env sharedEnv];
    NSString *url = [env getSEKey:kSEDelFavWords Def:kSEDefDelFavWordsURL];
    
    url = [BqsUtils setURL:url ParameterName:@"articleId" Value:[NSString stringWithFormat:@"%d",artId]];
    url = [BqsUtils setURL:url ParameterName:@"type" Value:[NSString stringWithFormat:@"%d",type]];
    return [dl addTask:url Target:target Callback:action Attached:att];
}




#pragma mark topic
+(int)topicTitleFreshDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att{
    Env *env = [Env sharedEnv];
    NSString *url = [env getSEKey:kSETopicTitleFreshList Def:kSEDefTopicTitleFreshURL];
    return [dl addTask:url Target:target Callback:action Attached:att];
    
}

+(int)topicImageFreshDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att imageId:(int)imageId topicID:(NSInteger)topicId{
    
    Env *env = [Env sharedEnv];
    NSString *url = [env getSEKey:kSENewImageFreshList Def:kSEDefNewImageFreshURL];
    
    url = [BqsUtils setURL:url ParameterName:@"id" Value:[NSString stringWithFormat:@"%d",imageId]];
    url = [BqsUtils setURL:url ParameterName:@"topicId" Value:[NSString stringWithFormat:@"%d",topicId]];
    return [dl addTask:url Target:target Callback:action Attached:att];
}


+(int)topicImageNextDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att imageId:(int)imageId topicID:(NSInteger)topicId{
    
    Env *env = [Env sharedEnv];
    NSString *url = [env getSEKey:kSENewImageNextList Def:kSEDefNewImageNextURL];
    
    url = [BqsUtils setURL:url ParameterName:@"id" Value:[NSString stringWithFormat:@"%d",imageId]];
    url = [BqsUtils setURL:url ParameterName:@"topicId" Value:[NSString stringWithFormat:@"%d",topicId]];
    return [dl addTask:url Target:target Callback:action Attached:att];
}



+(int)topicVideoFreshDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att videoId:(int)videoId topicID:(NSInteger)topicId{
    
    Env *env = [Env sharedEnv];
    NSString *url = [env getSEKey:kSENewVideoFreshList Def:kSEDefNewVideoFreshURL];
    
    url = [BqsUtils setURL:url ParameterName:@"id" Value:[NSString stringWithFormat:@"%d",videoId]];
    url = [BqsUtils setURL:url ParameterName:@"topicId" Value:[NSString stringWithFormat:@"%d",topicId]];
    return [dl addTask:url Target:target Callback:action Attached:att];
}


+(int)topicVideoNextDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att videoId:(int)videoId topicID:(NSInteger)topicId{
    
    Env *env = [Env sharedEnv];
    NSString *url = [env getSEKey:kSENewVideoNextList Def:kSEDefNewVideoNextURL];
    
    url = [BqsUtils setURL:url ParameterName:@"id" Value:[NSString stringWithFormat:@"%d",videoId]];
    url = [BqsUtils setURL:url ParameterName:@"topicId" Value:[NSString stringWithFormat:@"%d",topicId]];
    return [dl addTask:url Target:target Callback:action Attached:att];
}


#pragma mark review
+(int)reviewFreshDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att
{
    Env *env = [Env sharedEnv];
    NSString *url = [env getSEKey:kSEReviewFreshList Def:kSEDefReviewFreshURL];
    return [dl addTask:url Target:target Callback:action Attached:att];

    
}


+(int)reviewNextDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att wordId:(int)wordId
{
    Env *env = [Env sharedEnv];
    NSString *url = [env getSEKey:kSEReviewNextList Def:kSEDefReviewNextURL];
    url = [BqsUtils setURL:url ParameterName:@"id" Value:[NSString stringWithFormat:@"%d",wordId]];
    return [dl addTask:url Target:target Callback:action Attached:att];
    
    
}


+(int)reviewAuditorDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att wordId:(int)wordId type:(NSInteger)type{
    Env *env = [Env sharedEnv];
    NSString *url = [env getSEKey:kSEReviewAuditorList Def:kSEDefReviewAuditorURL];
    url = [BqsUtils setURL:url ParameterName:@"id" Value:[NSString stringWithFormat:@"%d",wordId]];
    url = [BqsUtils setURL:url ParameterName:@"type" Value:[NSString stringWithFormat:@"%d",type]];
    return [dl addTask:url Target:target Callback:action Attached:att];

}


#pragma mark publish message
+(int)publishMessageDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att Content:(NSString *)content ShowUser:(BOOL)show Title:(NSString *)title FileName:(NSString *)fileName Data:(NSData *)data ContentType:(NSString *)sContentType{
    
    Env *env = [Env sharedEnv];
    NSString *url = [env getSEKey:kSEPublishMessage Def:kSEDefPublishMessageURL];
    
    url = [BqsUtils setURL:url ParameterName:@"content" Value:[BqsUtils urlEncodedString:content]];
    url = [BqsUtils setURL:url ParameterName:@"showUser" Value:[NSString stringWithFormat:@"%d",!show]];
    url = [BqsUtils setURL:url ParameterName:@"title" Value:[BqsUtils urlEncodedString:title]];
    url = [BqsUtils setURL:url ParameterName:@"fileName" Value:fileName];
    
//    if (data == nil) {
//        return [dl addTask:url Target:target Callback:action Attached:att];
//    }
    
    return [dl addPostTask:url Data:data ContentType:sContentType Target:target Callback:action Attached:att];
    

    
}


//download m3u8 file
+(int)videoM3u8Downloader:(Downloader *)dl Url:(NSString *)url PkgFile:(PackageFile *)pkf Target:(id)target  Sel:(SEL)action Attached:(id)att{
    
    return [dl addCachedTask:url PkgFile:pkf Target:target Callback:action Attached:att];
    

}

 /**
  *	User 
  *
  *	@param	dl	<#dl description#>
  *	@param	target	<#target description#>
  *	@param	action	<#action description#>
  *	@param	att	<#att description#>
  *	@param	username	<#username description#>
  *	@param	password	<#password description#>
  *
  *	@return	<#return value description#>
  */

+(int)userLoginDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att userName:(NSString *)username password:(NSString *)password{
    
    Env *env = [Env sharedEnv];
    NSString *url = [env getSEKey:kSEUserLoginAction Def:kSEDefUserLogin];
    
    url = [BqsUtils setURL:url ParameterName:@"name" Value:username];
    url = [BqsUtils setURL:url ParameterName:@"password" Value:password];
    return [dl addTask:url Target:target Callback:action Attached:att];

    
}



+(int)userRegisterDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att userName:(NSString *)username password:(NSString *)password{
    
    Env *env = [Env sharedEnv];
    NSString *url = [env getSEKey:kSEUserRegisterAction Def:kSEDefUserRegister];
    
    url = [BqsUtils setURL:url ParameterName:@"name" Value:username];
    url = [BqsUtils setURL:url ParameterName:@"password" Value:password];
    
    return [dl addTask:url Target:target Callback:action Attached:att];

    
}

+(int)saveUserInfoDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att nikeName:(NSString *)nikeName FileName:(NSString *)fileName Data:(NSData *)data ContentType:(NSString *)sContentType{
    
    Env *env = [Env sharedEnv];
    NSString *url = [env getSEKey:kSEUserInfoSaveAction Def:kSEDefUserIndosSave];
    
    url = [BqsUtils setURL:url ParameterName:@"nickName" Value:[BqsUtils urlEncodedString:nikeName]];
    url = [BqsUtils setURL:url ParameterName:@"fileName" Value:fileName];
    
    return [dl addPostTask:url Data:data ContentType:sContentType Target:target Callback:action Attached:att];

    
}


+(int)passwordResetDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att oldPassword:(NSString *)oldPas newPassword:(NSString *)newPas{
    
    Env *env = [Env sharedEnv];
    NSString *url = [env getSEKey:kSEUserChangePasswordAction Def:kSEDefUserChangePassword];
    
    url = [BqsUtils setURL:url ParameterName:@"oldpassword" Value:oldPas];
    url = [BqsUtils setURL:url ParameterName:@"password" Value:newPas];
    
    return [dl addTask:url Target:target Callback:action Attached:att];
    
}

+(int)getRecordMessageDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att{
    
    Env *env = [Env sharedEnv];
    NSString *url = [env getSEKey:kSERecordMessageAction Def:kSEDefRecordMessageURL];
    return [dl addTask:url Target:target Callback:action Attached:att];
}

+(int)loginUnionDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att userName:(NSString *)userName nickName:(NSString *)nikeName iconUrl:(NSString *)iconUrl type:(UnionLogoinType)type userAddType:(UnionLoginUserType)userType{
    
    Env *env = [Env sharedEnv];
    NSString *url = [env getSEKey:kSEUnionLoginAction Def:kSEDefUnionLoginURL];
    url = [BqsUtils setURL:url ParameterName:@"unitNickName" Value:[BqsUtils urlEncodedString:nikeName]];
    url = [BqsUtils setURL:url ParameterName:@"unitIcon" Value:[BqsUtils urlEncodedString:iconUrl]];
    url = [BqsUtils setURL:url ParameterName:@"unitName" Value:userName];
    url = [BqsUtils setURL:url ParameterName:@"unitType" Value:[NSString stringWithFormat:@"%d",type]];
    url = [BqsUtils setURL:url ParameterName:@"isAdd" Value:[NSString stringWithFormat:@"%d",userType]];
    return [dl addTask:url Target:target Callback:action Attached:att];

}


///ijoke/front/ listArticleCollect.action?page=0
+(int)collectInfoDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att page:(NSInteger)page userId:(NSString *)userId{
    
    Env *env = [Env sharedEnv];
    NSString *url = [env getSEKey:kSECollectCheckAction Def:kSEDefCollectCheckActionURL];
    
    url = [BqsUtils setURL:url ParameterName:@"page" Value:[NSString stringWithFormat:@"%d",page]];
    url = [BqsUtils setURL:url ParameterName:@"userid" Value:userId];
    return [dl addTask:url Target:target Callback:action Attached:att];
    
}

+(int)publishTopInfoDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att userId:(NSString *)userid{
    
    Env *env = [Env sharedEnv];
    NSString *url = [env getSEKey:kSEPublishTopInfoAction Def:kSEDefPublishTopInfoActionURL];
    url = [BqsUtils setURL:url ParameterName:@"userid" Value:userid];
    return [dl addTask:url Target:target Callback:action Attached:att];
    
}

+(int)publishNextInfoDownloader:(Downloader *)dl Target:(id)target Sel:(SEL)action Attached:(id)att jokeId:(NSString *)jokeId userId:(NSString *)userid{
    
    Env *env = [Env sharedEnv];
    NSString *url = [env getSEKey:kSEPublishNextInfoAction Def:kSEDefPublishNextInfoActionURL];
    url = [BqsUtils setURL:url ParameterName:@"id" Value:jokeId];
    url = [BqsUtils setURL:url ParameterName:@"userid" Value:userid];
    return [dl addTask:url Target:target Callback:action Attached:att];
    
}


//http://42.96.151.160/ijoke/front/ listTopArticleToUser.action? userid=2


@end
