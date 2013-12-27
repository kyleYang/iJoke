//
//  FTSDataMgr.m
//  iJoke
//
//  Created by Kyle on 13-7-30.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSDataMgr.h"
#import "Words.h"
#import "Image.h"
#import "Video.h"
#import "Review.h"
#import "Topic.h"
#import "FTSNetwork.h"
#import "FTSUserCenter.h"
#import "Msg.h"


#define kFTSJoke @"iJoker"
#define kDoucumet @"doucument"
#define kJokeImage @"image"
#define kJokeVideo @"video"
#define kJokeTopic @"topic"

#define kJokePublish @"publish"

#define kNewWords @"newwords.xml"
#define kHotWords @"hotWords.xml"
#define kWordsRcords @"wordsrecords.xml"

#define kNewImage @"newimage.xml"
#define kHotImage @"hotimage.xml"
#define kImageRcords @"imagerecords.xml"

#define kNewVideo @"newvideo.xml"
#define kHotVideo @"hotvideo.xml"
#define kVideoRcords @"videorecords.xml"

#define kTopic @"topic.xml"
#define kTopicWords @"topicWords_%d.xml"
#define kTopicImage @"topicImage_%d.xml"
#define kTopicVideo @"topicVideo_%d.xml"

#define kCollectMessage @"collectmessage.xml"
#define kPublishMessage @"publishmessage.xml"

#define kMaxRecord 500
#define kRemoveTimeInterval (32*24*60*60) //32 days ago

@interface FTSDataMgr()

@property (nonatomic, strong, readwrite) NSString *rootPath;

@property (nonatomic, strong, readwrite) NSString *doucument;

@property (nonatomic, strong, readwrite) Downloader *downloader;

@property (nonatomic, strong, readwrite) NSMutableArray *wordsRecords;
@property (nonatomic, strong, readwrite) NSMutableArray *imageRecords;
@property (nonatomic, strong, readwrite) NSMutableArray *videoRecords;

@property (nonatomic, strong, readwrite) NSMutableArray *collectArray;
@property (nonatomic, strong, readwrite) NSMutableArray *publishArray;

@property (nonatomic, strong, readwrite) NSString *publishPath;

@end



@implementation FTSDataMgr

@synthesize wordsRecords = _wordsRecords;
@synthesize imageRecords = _imageRecords;
@synthesize videoRecords = _videoRecords;

@synthesize publishPath = _publishPath;

@synthesize collectArray = _collectArray;
@synthesize publishArray = _publishArray;

static FTSDataMgr *sharedMgr = nil;

+(FTSDataMgr *)sharedInstance{
    
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        sharedMgr = [[FTSDataMgr alloc] init];
    });
    return sharedMgr;
    
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.downloader cancelAll];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}


-(id)init
{
    self = [super init];
    if(nil == self) return nil;
    
    self.rootPath = [[Env sharedEnv].dirCache stringByAppendingPathComponent:kFTSJoke];
    self.doucument = [self.rootPath stringByAppendingPathComponent:kDoucumet];
   
   	BqsLog(@"iJoke rootPath=%@,wordsPaht = %@", self.rootPath,self.doucument);
    
    self.downloader = [[Downloader alloc] init];
    self.downloader.bSearialLoad = YES;
    
    [self doNetworkUpdataChecks];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appTermNtf:) name:UIApplicationWillResignActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appResumeNtf:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    return self;
}



#pragma mark
#pragma mark - ntf handler
-(void)appTermNtf:(NSNotification*)ntf {
    BqsLog(@"appTermNtf");
    
    [self.downloader cancelAll];
    [Record saveToFile:[self pathOfWordsRecords] Arr:self.wordsRecords];
    [Record saveToFile:[self pathOfImageRecords] Arr:self.imageRecords];
    [Record saveToFile:[self pathOfVideoRecords] Arr:self.videoRecords];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

-(void)appResumeNtf:(NSNotification*)ntf {
    BqsLog(@"appResumeNtf");
    
    [self performSelector:@selector(doNetworkUpdataChecks) withObject:nil afterDelay:3];
}


#pragma mark
#pragma mark UpdataCheck
- (void)doNetworkUpdataChecks{
    
    BOOL login = [FTSUserCenter BoolValueForKey:kDftUserLogin];
    
    if (!login) {
        return;
    }
    
    BOOL socialWay = [FTSUserCenter BoolValueForKey:kDftUserUnionWay];
    BOOL socailSuccess = [FTSUserCenter BoolValueForKey:kDftUserUnionSuccess];
    BOOL synchronizSuccess = [FTSUserCenter BoolValueForKey:kDftMessageSynchroniz];
    
    if (socialWay) {
    
        if (!socailSuccess) {
            [self loginUnionWithSocail];
        }else{
            
            if (!synchronizSuccess) {
                [self synchronizationRecordMessage];
            }
        }
        
    }else{
        if (!synchronizSuccess) {
            [self synchronizationRecordMessage];
        }
    }
    
}


#pragma mark
#pragma mark records




- (NSString *)pathOfWordsRecords{
    NSString *path = [self.doucument stringByAppendingPathComponent:kWordsRcords];
    return path;
}

- (NSString *)pathOfImageRecords{
    NSString *path = [self.doucument stringByAppendingPathComponent:kImageRcords];
    return path;
}
- (NSString *)pathOfVideoRecords{
    NSString *path = [self.doucument stringByAppendingPathComponent:kVideoRcords];
    return path;
}

//mutable arrary
- (NSMutableArray *)wordsRecords{
    
    if (_wordsRecords) {
        return _wordsRecords;
    }
    
    if (!_wordsRecords) {
        _wordsRecords = [Record parseXmlData:[NSData dataWithContentsOfFile:[self pathOfWordsRecords]]];
    }
    
    if (!_wordsRecords) {
        _wordsRecords = [NSMutableArray arrayWithCapacity:10];
    }
    
    return _wordsRecords;

}


- (NSMutableArray *)imageRecords{
    
    if (_imageRecords) {
        return _imageRecords;
    }
    
    if (!_imageRecords) {
        _imageRecords = [Record parseXmlData:[NSData dataWithContentsOfFile:[self pathOfImageRecords]]];
    }
    
    if (!_imageRecords) {
        _imageRecords = [NSMutableArray arrayWithCapacity:10];
    }
    
    return _imageRecords;
    
}

- (NSMutableArray *)videoRecords{
    
    if (_videoRecords) {
        return _videoRecords;
    }
    
    if (!_videoRecords) {
        _videoRecords = [Record parseXmlData:[NSData dataWithContentsOfFile:[self pathOfVideoRecords]]];
    }
    
    if (!_videoRecords) {
        _videoRecords = [NSMutableArray arrayWithCapacity:10];
    }
    
    return _videoRecords;
    
}



// words

- (Record*)judgeWordsUpType:(Words *)words{
    
    int i = 0;
    int j = [self.wordsRecords count] -1;
    
    while (i<=j) {
        
        NSInteger temp = (i+j)/2;
        Record *tRecord = [self.wordsRecords objectAtIndex:temp];
        if (tRecord.itemId == words.wordId) {
            return tRecord;
        }else if (tRecord.itemId<words.wordId){
            j = temp-1;
        }else{
            i = temp+1;
        }
    }
    
    return nil;
}

- (BOOL)addRecordWords:(Words *)words upType:(iJokeUpDownType)type{
    
    int i = 0;
    int j = [self.wordsRecords count] -1;
    
    NSInteger temp = 0;
    BOOL exist = FALSE;
    while (i<=j && !exist) {
        
        temp = (i+j)/2;
        Record *tRecord = [self.wordsRecords objectAtIndex:temp];
        if (tRecord.itemId == words.wordId) {
            tRecord.type = type;
           
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            NSString *time = [dateFormatter stringFromDate:[NSDate date]];
            BqsLog(@"exist time:%@",time);
            tRecord.time = time;
            
            exist = TRUE;
        }else if (tRecord.itemId<words.wordId){
            j = temp-1;
        }else{
            i = temp+1;
        }
    }
    
    if (!exist) {
        Record *record = [[Record alloc] init];
        record.itemId = words.wordId;
        record.type = type;
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSString *time = [dateFormatter stringFromDate:[NSDate date]];
        BqsLog(@"not exist time:%@",time);
        
        record.time = time;
        
        [self.wordsRecords insertObject:record atIndex:i];
        
    }
    
    if ([self.wordsRecords count] > kMaxRecord) {
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        
        NSTimeInterval nowTimeinterval = [NSDate timeIntervalSinceReferenceDate];
        
        for (int k= [self.wordsRecords count]-1; k>=0;k--) {
            
            Record *record = [self.wordsRecords objectAtIndex:k];
            NSDate *rDate =[ dateFormatter dateFromString:record.time];
            NSTimeInterval rTimeInterval = [rDate timeIntervalSinceReferenceDate];
            if ((nowTimeinterval - rTimeInterval)>kRemoveTimeInterval) {
                
                [self.wordsRecords removeObjectAtIndex:k];
                
            }
            
        }
        
    }

    
    
    return TRUE;
    
}


- (BOOL)addFavoritedWords:(Words *)words addType:(BOOL)value{ //true for add,false for del
    
    int i = 0;
    int j = [self.wordsRecords count] -1;
    
    NSInteger temp = 0;
    BOOL exist = FALSE;
    while (i<=j && !exist) {
        
        temp = (i+j)/2;
        Record *tRecord = [self.wordsRecords objectAtIndex:temp];
        if (tRecord.itemId == words.wordId) {
            exist = TRUE;
            if (!value) { //del favorite
                if (tRecord.type == iJokeUpDownNone) {//have no up and down ,remove item
                    [self.wordsRecords removeObjectAtIndex:temp];
                    break;
                }
            }
            
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            NSString *time = [dateFormatter stringFromDate:[NSDate date]];
            BqsLog(@"exist time:%@",time);
            tRecord.favorite = value;
            tRecord.time = time;
            
            
        }else if (tRecord.itemId<words.wordId){
            j = temp-1;
        }else{
            i = temp+1;
        }
    }
    
    if (!exist&&!value) { //not exist and remove favorite ,not need to rewrite
        
        return FALSE;
        
    } else if (!exist&&value) { //not exist and add favorite ,add a record
        
        Record *record = [[Record alloc] init];
        record.itemId = words.wordId;
        record.favorite = value;
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSString *time = [dateFormatter stringFromDate:[NSDate date]];
        BqsLog(@"not exist time:%@",time);
        
        record.time = time;
        
        [self.wordsRecords insertObject:record atIndex:i];
        
    }
    
    if ([self.wordsRecords count] > kMaxRecord) {
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        
        NSTimeInterval nowTimeinterval = [NSDate timeIntervalSinceReferenceDate];
        
        for (int k= [self.wordsRecords count]-1; k>=0;k--) {
            
            Record *record = [self.wordsRecords objectAtIndex:k];
            NSDate *rDate =[ dateFormatter dateFromString:record.time];
            NSTimeInterval rTimeInterval = [rDate timeIntervalSinceReferenceDate];
            if ((nowTimeinterval - rTimeInterval)>kRemoveTimeInterval) {
                
                [self.wordsRecords removeObjectAtIndex:k];
                
            }
            
        }
        
    }
    
    return TRUE;
}


//image
- (Record*)judgeImagesUpType:(Image*)image{
    
    int i = 0;
    int j = [self.imageRecords count] -1;
    
    while (i<=j) {
        
        NSInteger temp = (i+j)/2;
        Record *tRecord = [self.imageRecords objectAtIndex:temp];
        if (tRecord.itemId == image.imageId) {
            return tRecord;
        }else if (tRecord.itemId<image.imageId){
            j = temp-1;
        }else{
            i = temp+1;
        }
    }
    
    return nil;
}
- (BOOL)addRecordImages:(Image *)image upType:(iJokeUpDownType)type{
    
    int i = 0;
    int j = [self.imageRecords count] -1;
    
    NSInteger temp = 0;
    BOOL exist = FALSE;
    while (i<=j && !exist) {
        
        temp = (i+j)/2;
        Record *tRecord = [self.imageRecords objectAtIndex:temp];
        if (tRecord.itemId == image.imageId) {
            tRecord.type = type;
            
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            NSString *time = [dateFormatter stringFromDate:[NSDate date]];
            BqsLog(@"exist time:%@",time);
            tRecord.time = time;
            
            exist = TRUE;
        }else if (tRecord.itemId<image.imageId){
            j = temp-1;
        }else{
            i = temp+1;
        }
    }
    
    if (!exist) {
        Record *record = [[Record alloc] init];
        record.itemId = image.imageId;
        record.type = type;
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSString *time = [dateFormatter stringFromDate:[NSDate date]];
        BqsLog(@"not exist time:%@",time);
        
        record.time = time;
        
        [self.imageRecords insertObject:record atIndex:i];
        
    }
    
    if ([self.imageRecords count] > kMaxRecord) {
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        
        NSTimeInterval nowTimeinterval = [NSDate timeIntervalSinceReferenceDate];
        
        for (int k= [self.imageRecords count]-1; k>=0;k--) {
            
            Record *record = [self.imageRecords objectAtIndex:k];
            NSDate *rDate =[ dateFormatter dateFromString:record.time];
            NSTimeInterval rTimeInterval = [rDate timeIntervalSinceReferenceDate];
            if ((nowTimeinterval - rTimeInterval)>kRemoveTimeInterval) {
                
                [self.imageRecords removeObjectAtIndex:k];
                
            }
            
        }
        
    }
    
   
    
    return TRUE;
    
}
- (BOOL)addFavoritedImages:(Image *)image addType:(BOOL)value{ //true for add,false for del
    
    int i = 0;
    int j = [self.imageRecords count] -1;
    
    NSInteger temp = 0;
    BOOL exist = FALSE;
    while (i<=j && !exist) {
        
        temp = (i+j)/2;
        Record *tRecord = [self.imageRecords objectAtIndex:temp];
        if (tRecord.itemId == image.imageId) {
            exist = TRUE;
            if (!value) { //del favorite
                if (tRecord.type == iJokeUpDownNone) {//have no up and down ,remove item
                    [self.imageRecords removeObjectAtIndex:temp];
                    break;
                }
            }
            
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            NSString *time = [dateFormatter stringFromDate:[NSDate date]];
            BqsLog(@"exist time:%@",time);
            tRecord.favorite = value;
            tRecord.time = time;
            
            
        }else if (tRecord.itemId<image.imageId){
            j = temp-1;
        }else{
            i = temp+1;
        }
    }
    
    if (!exist&&!value) { //not exist and remove favorite ,not need to rewrite
        
        return FALSE;
        
    } else if (!exist&&value) { //not exist and add favorite ,add a record
        
        Record *record = [[Record alloc] init];
        record.itemId = image.imageId;
        record.favorite = value;
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSString *time = [dateFormatter stringFromDate:[NSDate date]];
        BqsLog(@"not exist time:%@",time);
        
        record.time = time;
        
        [self.imageRecords insertObject:record atIndex:i];
        
    }
    
    if ([self.imageRecords count] > kMaxRecord) {
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        
        NSTimeInterval nowTimeinterval = [NSDate timeIntervalSinceReferenceDate];
        
        for (int k= [self.imageRecords count]-1; k>=0;k--) {
            
            Record *record = [self.imageRecords objectAtIndex:k];
            NSDate *rDate =[ dateFormatter dateFromString:record.time];
            NSTimeInterval rTimeInterval = [rDate timeIntervalSinceReferenceDate];
            if ((nowTimeinterval - rTimeInterval)>kRemoveTimeInterval) {
                
                [self.imageRecords removeObjectAtIndex:k];
                
            }
            
        }
        
    }
    
    return TRUE;
}

#pragma mark
#pragma mark Video Judege

- (Record*)judgeVideoUpType:(Video *)video{
    
    int i = 0;
    int j = [self.videoRecords count] -1;
    
    while (i<=j) {
        
        NSInteger temp = (i+j)/2;
        Record *tRecord = [self.videoRecords objectAtIndex:temp];
        if (tRecord.itemId == video.videoId) {
            return tRecord;
        }else if (tRecord.itemId<video.videoId){
            j = temp-1;
        }else{
            i = temp+1;
        }
    }
    
    return nil;
}

- (BOOL)addRecordVideo:(Video *)video upType:(iJokeUpDownType)type{
    
    int i = 0;
    int j = [self.videoRecords count] -1;
    
    NSInteger temp = 0;
    BOOL exist = FALSE;
    while (i<=j && !exist) {
        
        temp = (i+j)/2;
        Record *tRecord = [self.videoRecords objectAtIndex:temp];
        if (tRecord.itemId == video.videoId) {
            tRecord.type = type;
            
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            NSString *time = [dateFormatter stringFromDate:[NSDate date]];
            BqsLog(@"exist time:%@",time);
            tRecord.time = time;
            
            exist = TRUE;
        }else if (tRecord.itemId<video.videoId){
            j = temp-1;
        }else{
            i = temp+1;
        }
    }
    
    if (!exist) {
        Record *record = [[Record alloc] init];
        record.itemId = video.videoId;
        record.type = type;
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSString *time = [dateFormatter stringFromDate:[NSDate date]];
        BqsLog(@"not exist time:%@",time);
        
        record.time = time;
        
        [self.videoRecords insertObject:record atIndex:i];
        
    }
    
    if ([self.videoRecords count] > kMaxRecord) {
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        
        NSTimeInterval nowTimeinterval = [NSDate timeIntervalSinceReferenceDate];
        
        for (int k= [self.videoRecords count]-1; k>=0;k--) {
            
            Record *record = [self.videoRecords objectAtIndex:k];
            NSDate *rDate =[ dateFormatter dateFromString:record.time];
            NSTimeInterval rTimeInterval = [rDate timeIntervalSinceReferenceDate];
            if ((nowTimeinterval - rTimeInterval)>kRemoveTimeInterval) {
                
                [self.videoRecords removeObjectAtIndex:k];
                
            }
            
        }
        
    }
    
    
    
    return TRUE;
    
}


- (BOOL)addFavoritedVideo:(Video *)video addType:(BOOL)value{ //true for add,false for del
    
    int i = 0;
    int j = [self.videoRecords count] -1;
    
    NSInteger temp = 0;
    BOOL exist = FALSE;
    while (i<=j && !exist) {
        
        temp = (i+j)/2;
        Record *tRecord = [self.videoRecords objectAtIndex:temp];
        if (tRecord.itemId == video.videoId) {
            exist = TRUE;
            if (!value) { //del favorite
                if (tRecord.type == iJokeUpDownNone) {//have no up and down ,remove item
                    [self.videoRecords removeObjectAtIndex:temp];
                    break;
                }
            }
            
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            NSString *time = [dateFormatter stringFromDate:[NSDate date]];
            BqsLog(@"exist time:%@",time);
            tRecord.favorite = value;
            tRecord.time = time;
            
            
        }else if (tRecord.itemId<video.videoId){
            j = temp-1;
        }else{
            i = temp+1;
        }
    }
    
    if (!exist&&!value) { //not exist and remove favorite ,not need to rewrite
        
        return FALSE;
        
    } else if (!exist&&value) { //not exist and add favorite ,add a record
        
        Record *record = [[Record alloc] init];
        record.itemId = video.videoId;
        record.favorite = value;
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSString *time = [dateFormatter stringFromDate:[NSDate date]];
        BqsLog(@"not exist time:%@",time);
        
        record.time = time;
        
        [self.videoRecords insertObject:record atIndex:i];
        
    }
    
    if ([self.videoRecords count] > kMaxRecord) {
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        
        NSTimeInterval nowTimeinterval = [NSDate timeIntervalSinceReferenceDate];
        
        for (int k= [self.videoRecords count]-1; k>=0;k--) {
            
            Record *record = [self.videoRecords objectAtIndex:k];
            NSDate *rDate =[ dateFormatter dateFromString:record.time];
            NSTimeInterval rTimeInterval = [rDate timeIntervalSinceReferenceDate];
            if ((nowTimeinterval - rTimeInterval)>kRemoveTimeInterval) {
                
                [self.videoRecords removeObjectAtIndex:k];
                
            }
            
        }
        
    }
    
    return TRUE;
}



#pragma mark
#pragma mark newsWords

- (NSString *)pathOfNewWords{
    NSString *path = [self.doucument stringByAppendingPathComponent:kNewWords];
    BqsLog(@"pathOfNewWords :%@",path);
	return path;
}
- (NSArray *)arrayOfSaveNewWords{
    return [Words parseXmlData:[NSData dataWithContentsOfFile:[self pathOfNewWords]]];
}
- (BOOL)saveNewWordsArray:(NSArray *)arr{
    return [Words saveToFile:[self pathOfNewWords] Arr:arr];
}



#pragma mark
#pragma mark hotwords


- (NSString *)pathOfHotWords{
    NSString *path = [self.doucument stringByAppendingPathComponent:kHotWords];
    BqsLog(@"pathOfVideoMessageForCat :%@",path);
	return path;

}

- (NSArray *)arrayOfSaveHotWords{
    return [Words parseXmlData:[NSData dataWithContentsOfFile:[self pathOfHotWords]]];
}

- (BOOL)saveHotWordsArray:(NSArray *)arr{
    return [Words saveToFile:[self pathOfHotWords] Arr:arr];

}


#pragma mark
#pragma mark newimage
- (NSString *)pathOfNewImage{
    NSString *path = [self.doucument stringByAppendingPathComponent:kNewImage];
    BqsLog(@"pathOfVideoMessageForCat :%@",path);
	return path;

    
}
- (NSArray *)arrayOfSaveNewImage{
     return [Image parseXmlData:[NSData dataWithContentsOfFile:[self pathOfNewImage]]];
}
- (BOOL)saveNewImageArray:(NSArray *)arr{
    return [Image saveToFile:[self pathOfNewImage] Arr:arr];
}

#pragma mark
#pragma mark hotimage
- (NSString *)pathOfHotImage{
    NSString *path = [self.doucument stringByAppendingPathComponent:kHotImage];
    BqsLog(@"pathOfVideoMessageForCat :%@",path);
	return path;
    
}
- (NSArray *)arrayOfSaveHotImage{
    return [Image parseXmlData:[NSData dataWithContentsOfFile:[self pathOfHotImage]]];
}
- (BOOL)saveHotImageArray:(NSArray *)arr{
    return [Image saveToFile:[self pathOfHotImage] Arr:arr];

}


#pragma mark
#pragma mark video
- (NSString *)pathOfNewVideo{
    NSString *path = [self.doucument stringByAppendingPathComponent:kNewVideo];
    BqsLog(@"pathOfNewVideo :%@",path);
	return path;
}
- (NSArray *)arrayOfSaveNewVideo{
    return [Video parseXmlData:[NSData dataWithContentsOfFile:[self pathOfNewVideo]]];
}
- (BOOL)saveNewVideoArray:(NSArray *)arr{
    return [Video saveToFile:[self pathOfNewVideo] Arr:arr];
}


- (NSString *)pathOfHotVideo{
    NSString *path = [self.doucument stringByAppendingPathComponent:kHotVideo];
    BqsLog(@"pathOfNewVideo :%@",path);
	return path;
}
- (NSArray *)arrayOfSaveHotVideo{
    return [Video parseXmlData:[NSData dataWithContentsOfFile:[self pathOfHotVideo]]];
}
- (BOOL)saveHotVideoArray:(NSArray *)arr{
    return [Video saveToFile:[self pathOfHotVideo] Arr:arr];
}


#pragma mark
#pragma mark topic
- (NSString *)pathOfTopic{
    NSString *path = [self.doucument stringByAppendingPathComponent:kTopic];
    BqsLog(@"pathOfNewVideo :%@",path);
	return path;
}
- (NSArray *)arrayOfSaveTopic{
    return [Topic parseXmlData:[NSData dataWithContentsOfFile:[self pathOfTopic]]];
}
- (BOOL)saveTopicArray:(NSArray *)arr{
    return [Topic saveToFile:[self pathOfTopic] Arr:arr];
}


- (NSString *)pathOfTpoicImageDetailForId:(NSUInteger)topicId{
    
    NSString *path = [self.doucument stringByAppendingPathComponent:[NSString stringWithFormat:kTopicImage, topicId]];
    BqsLog(@"pathOfVideoMessageForCat :%@",path);
	return path;
    
    
}
- (NSArray *)arrayOfSaveTpoicImageDetailForId:(NSUInteger)topicId{
    return [Image parseXmlData:[NSData dataWithContentsOfFile:[self pathOfTpoicImageDetailForId:topicId]]];
}
- (BOOL)saveTpoicImageDetailArray:(NSArray *)arr froId:(NSUInteger)topicId{
    return [Image saveToFile:[self pathOfTpoicImageDetailForId:topicId] Arr:arr];
}


- (NSString *)pathOfTpoicVideoDetailForId:(NSUInteger)topicId{
    
    NSString *path = [self.doucument stringByAppendingPathComponent:[NSString stringWithFormat:kTopicVideo, topicId]];
    BqsLog(@"pathOfVideoMessageForCat :%@",path);
	return path;

    
}
- (NSArray *)arrayOfSaveTpoicVideoDetailForId:(NSUInteger)topicId{
    return [Video parseXmlData:[NSData dataWithContentsOfFile:[self pathOfTpoicVideoDetailForId:topicId]]];
}

- (BOOL)saveTpoicVideoDetailArray:(NSArray *)arr froId:(NSUInteger)topicId{
    return [Video saveToFile:[self pathOfTpoicVideoDetailForId:topicId] Arr:arr];

}



- (NSString *)pathOfCollectSaveMessage{
    NSString *path = [self.doucument stringByAppendingPathComponent:kCollectMessage];
    BqsLog(@"pathOfVideoMessageForCat :%@",path);
	return path;

}
- (NSMutableArray *)collectArray{
    
    if (_collectArray != nil) {
        return _collectArray;
    }
    
    if (_collectArray == nil) {
        _collectArray = (NSMutableArray *)[Review parseXmlData:[NSData dataWithContentsOfFile:[self pathOfCollectSaveMessage]]];
    }
    
    if (_collectArray == nil) {
        _collectArray = [NSMutableArray arrayWithCapacity:10];
    }

    
    return _collectArray;
    
}

- (BOOL)addOneJokeSave:(id)joke{
    
    [self.collectArray insertObject:joke atIndex:0];
   return [self saveCollectMessageArray:self.collectArray];
    
}

- (BOOL)removeOneJoke:(id)joke{
   
    for (id sub in self.collectArray) {
        
        if ([sub isKindOfClass:[Words class]]&&[joke isKindOfClass:[Words class]]) {
            if(((Words *)sub).wordId == ((Words *)joke).wordId){
                [self.collectArray removeObject:sub];
                return [self saveCollectMessageArray:self.collectArray];
            }
        }else  if ([sub isKindOfClass:[Image class]]&&[joke isKindOfClass:[Image class]]) {
            if(((Image *)sub).imageId == ((Image *)joke).imageId){
                [self.collectArray removeObject:sub];
                return [self saveCollectMessageArray:self.collectArray];
            }
        }else  if ([sub isKindOfClass:[Video class]]&&[joke isKindOfClass:[Video class]]) {
            if(((Video *)sub).videoId == ((Video *)joke).videoId){
                [self.collectArray removeObject:sub];
                return [self saveCollectMessageArray:self.collectArray];
            }
        }
        
    }
    
    return FALSE;

}

- (BOOL)saveCollectMessageArray:(NSArray *)arr{
    _collectArray = [NSMutableArray arrayWithArray:arr];
    return [Review saveToFile:[self pathOfCollectSaveMessage] Arr:arr];
}



- (NSMutableArray *)publishArray{
    
    if (_publishArray != nil) {
        return _publishArray;
    }
    
    if (_publishArray == nil) {
        _publishArray = (NSMutableArray *)[Review parseXmlData:[NSData dataWithContentsOfFile:[self pathOfPublishSaveMessage]]];
    }
    
    if (_publishArray == nil) {
        _publishArray = [NSMutableArray arrayWithCapacity:10];
    }
    
    return _publishArray;
    
}



- (NSString *)pathOfPublishSaveMessage{
    
    NSString *path = [self.doucument stringByAppendingPathComponent:kPublishMessage];
    BqsLog(@"pathOfVideoMessageForCat :%@",path);
	return path;
    
}
- (BOOL)savePublishMessageArray:(NSArray *)arr{
    return [Review saveToFile:[self pathOfPublishSaveMessage] Arr:arr];
}



#pragma mark
#pragma mark publish 

- (NSString *)publishPath{
    if (_publishPath) return _publishPath;
    
    _publishPath = [self.rootPath stringByAppendingPathComponent:kJokePublish];
    
    return _publishPath;
    
}


#pragma mark
#pragma mark record message
- (void)synchronizationRecordMessage{
    
    [FTSUserCenter setBoolVaule:NO forKey:kDftMessageSynchroniz];
    
    [FTSNetwork getRecordMessageDownloader:self.downloader Target:self Sel:@selector(recordMessageCB:) Attached:nil];
}

- (void)loginUnionWithSocail{
    NSString *userName = [FTSUserCenter objectValueForKey:kDftUserName];
    NSString *nikeName = [FTSUserCenter objectValueForKey:kDftUserNickName];
    NSString *iconUrl = [FTSUserCenter objectValueForKey:kDftUserIcon];
    NSInteger socailType = [FTSUserCenter intValueForKey:kDftUserUnionType];
    
    [FTSNetwork loginUnionDownloader:self.downloader Target:self Sel:@selector(loginUnionCB:) Attached:nil userName:userName nickName:nikeName iconUrl:iconUrl type:socailType userAddType:UnionLoginUserNew];
    
    
}

- (void)attachUnionWithSocailUserName:(NSString *)userName nickName:(NSString *)nikeName iconUrl:(NSString *)iconUrl type:(UnionLogoinType)socailType{
    
    [FTSNetwork loginUnionDownloader:self.downloader Target:self Sel:@selector(attachUnionCB:) Attached:nil userName:userName nickName:nikeName iconUrl:iconUrl type:socailType userAddType:UnionLoginUserAttach];
}




#pragma mark
#pragma mark downloader callback
- (void)recordMessageCB:(DownloaderCallbackObj *)cb{
    if(nil == cb) return;
    
    if(nil != cb.error || 200 != cb.httpStatus) {
		BqsLog(@"Error: len:%d, http%d, %@", [cb.rspData length], cb.httpStatus, cb.error);
        return;
	}
    
    
    
    NSMutableArray *array = [Record parseJsonData:cb.rspData]; //server record contain words image video
    if (array != nil) {
        _wordsRecords = array;
        [Record saveToFile:[self pathOfWordsRecords] Arr:self.wordsRecords];
    }
    [FTSUserCenter setBoolVaule:YES forKey:kDftMessageSynchroniz];
    
}

- (void)loginUnionCB:(DownloaderCallbackObj *)cb{
    if(nil == cb) return;
    
    if(nil != cb.error || 200 != cb.httpStatus) {
		BqsLog(@"Error: len:%d, http%d, %@", [cb.rspData length], cb.httpStatus, cb.error);
        return;
	}
    
    Msg *msg = [Msg parseJsonData:cb.rspData];
    if (!msg.code) {//登陆失败，statebar 给出相应提示
        
        return;
    }

    User *user = [User userInfoForLogData:cb.rspData];
    
    [FTSUserCenter setIntValue:user.userId forKey:kDftUserId];
    [FTSUserCenter setObjectValue:user.nikeName forKey:kDftUserNickName];
    [FTSUserCenter setObjectValue:user.icon forKey:kDftUserIcon];
    [FTSUserCenter setObjectValue:msg.passport forKey:kDftUserPassport];
    [FTSUserCenter setBoolVaule:TRUE forKey:kDftUserLogin];
    
    [FTSUserCenter setBoolVaule:TRUE forKey:kDftUserUnionSuccess];
    
    [self synchronizationRecordMessage];

    
}

- (void)attachUnionCB:(DownloaderCallbackObj *)cb{
    
    if(nil == cb) return;
    
    if(nil != cb.error || 200 != cb.httpStatus) {
		BqsLog(@"Error: len:%d, http%d, %@", [cb.rspData length], cb.httpStatus, cb.error);
        return;
	}
    
    Msg *msg = [Msg parseJsonData:cb.rspData];
    if (!msg.code) {//登陆失败，statebar 给出相应提示
        
        return;
    }

    
}



@end
