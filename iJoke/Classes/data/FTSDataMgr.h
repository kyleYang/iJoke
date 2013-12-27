//
//  FTSDataMgr.h
//  iJoke
//
//  Created by Kyle on 13-7-30.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Downloader.h"
#import "PackageFile.h"
#import "Downloader.h"
#import "Record.h"
#import "FTSNetwork.h"

@class Words;
@class Image;
@class Video;
@class Record;
@class Review;

#define kJokePublishImg @"publish.png"
#define kJokePublishMeesage @"message.xml"

@interface FTSDataMgr : NSObject

@property (nonatomic, strong, readonly) NSString *rootPath;

@property (nonatomic, strong, readonly) NSString *doucument;
@property (nonatomic, strong, readonly) NSString *publishPath;

@property (nonatomic, strong, readonly) NSMutableArray *collectArray;
@property (nonatomic, strong, readonly) NSMutableArray *publishArray;


@property (nonatomic, strong, readonly) Downloader *downloader;

//record : up down and favorite
@property (nonatomic, strong, readonly) NSMutableArray *wordsRecords;
@property (nonatomic, strong, readonly) NSMutableArray *imageRecords;
@property (nonatomic, strong, readonly) NSMutableArray *videoRecords;


+(FTSDataMgr *)sharedInstance;

//record upDown
- (NSString *)pathOfWordsRecords;
- (NSString *)pathOfImageRecords;
- (NSString *)pathOfVideoRecords;

- (Record*)judgeWordsUpType:(Words*)words;
- (BOOL)addRecordWords:(Words *)words upType:(iJokeUpDownType)type;
- (BOOL)addFavoritedWords:(Words *)words addType:(BOOL)value; //true for add,false for del

- (Record*)judgeImagesUpType:(Image*)image;
- (BOOL)addRecordImages:(Image *)image upType:(iJokeUpDownType)type;
- (BOOL)addFavoritedImages:(Image *)image addType:(BOOL)value; //true for add,false for del

- (Record*)judgeVideoUpType:(Video *)video;
- (BOOL)addRecordVideo:(Video *)video upType:(iJokeUpDownType)type;
- (BOOL)addFavoritedVideo:(Video *)video addType:(BOOL)value;

//favorite



//newswords save path
- (NSString *)pathOfNewWords;
- (NSArray *)arrayOfSaveNewWords;
- (BOOL)saveNewWordsArray:(NSArray *)arr;


//hotwords save path
- (NSString *)pathOfHotWords;
- (NSArray *)arrayOfSaveHotWords;
- (BOOL)saveHotWordsArray:(NSArray *)arr;


//newsImage save path
- (NSString *)pathOfNewImage;
- (NSArray *)arrayOfSaveNewImage;
- (BOOL)saveNewImageArray:(NSArray *)arr;

//hotimage save path
- (NSString *)pathOfHotImage;
- (NSArray *)arrayOfSaveHotImage;
- (BOOL)saveHotImageArray:(NSArray *)arr;

//image save path
- (NSString *)pathOfNewVideo;
- (NSArray *)arrayOfSaveNewVideo;
- (BOOL)saveNewVideoArray:(NSArray *)arr;

- (NSString *)pathOfHotVideo;
- (NSArray *)arrayOfSaveHotVideo;
- (BOOL)saveHotVideoArray:(NSArray *)arr;


//topic
- (NSString *)pathOfTopic;
- (NSArray *)arrayOfSaveTopic;
- (BOOL)saveTopicArray:(NSArray *)arr;

- (NSString *)pathOfTpoicImageDetailForId:(NSUInteger)topicId;
- (NSArray *)arrayOfSaveTpoicImageDetailForId:(NSUInteger)topicId;
- (BOOL)saveTpoicImageDetailArray:(NSArray *)arr froId:(NSUInteger)topicId;

- (NSString *)pathOfTpoicVideoDetailForId:(NSUInteger)topicId;
- (NSArray *)arrayOfSaveTpoicVideoDetailForId:(NSUInteger)topicId;
- (BOOL)saveTpoicVideoDetailArray:(NSArray *)arr froId:(NSUInteger)topicId;

//user action
- (NSString *)pathOfCollectSaveMessage;
- (BOOL)addOneJokeSave:(id)joke;
- (BOOL)removeOneJoke:(id)joke;
- (BOOL)saveCollectMessageArray:(NSArray *)arr;

- (NSString *)pathOfPublishSaveMessage;
- (BOOL)savePublishMessageArray:(NSArray *)arr;


//record message use
- (void)synchronizationRecordMessage;

- (void)loginUnionWithSocail;
- (void)attachUnionWithSocailUserName:(NSString *)userName nickName:(NSString *)nikeName iconUrl:(NSString *)iconUrl type:(UnionLogoinType)socailType;

@end
