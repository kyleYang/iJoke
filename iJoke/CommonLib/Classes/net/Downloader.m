//
//  Downloader.m
//  iMobee
//
//  Created by ellison on 10-9-17.
//  Copyright 2010 borqs. All rights reserved.
//

#import "Downloader.h"
#import "DownloadTask.h"
#import "BqsUtils.h"
#import "PackageFile.h"

#define kDataSubfix_Header @".header_20110815"

#define kHeader_ExpireTS @"app.expired.ts" // seconds since 1970
#define kHeader_DataLen @"app.data.len" 
#define kHeader_ETag @"app.etag" // etag
#define kHeader_LastModified @"app.lastmodified" // last modified
#define kHeader_ContentType @"app.contenttype" // content_type
#define kHeader_PoweredByBorqs @"app.powered_by_borqs"

#if __has_feature(objc_arc)
#error This file cannot be compiled with ARC. Either turn off ARC for the project or use -fno-objc-arc flag
#endif


@interface BqsDownloaderItem : NSObject
{
	NSInteger _taskId;
	id _cbTarget;
	SEL _cbSelector;
	id _attached;
	DownloadTask *_downloadTask;
}
@property (nonatomic, assign) NSInteger taskId;
@property (nonatomic, assign) id cbTarget;
@property (nonatomic, assign) SEL cbSelector;
@property (nonatomic, retain) id attached;
@property (nonatomic, retain) DownloadTask *downloadTask;
@property (nonatomic, retain) PackageFile *pkgFile;
@end

@implementation BqsDownloaderItem
@synthesize taskId = _taskId;
@synthesize cbTarget = _cbTarget;
@synthesize cbSelector = _cbSelector;
@synthesize attached = _attached;
@synthesize downloadTask = _downloadTask;
@synthesize pkgFile;

-(void)dealloc{
	[_downloadTask release];
    _downloadTask = nil;
    self.pkgFile = nil;
    [_attached release];
	[super dealloc];
}
@end



@implementation DownloaderCallbackObj 
@synthesize taskId=_taskId;
@synthesize url=_url;
@synthesize httpStatus=_httpStatus;
@synthesize httpContentType=_httpContentType;
@synthesize httpETag;
@synthesize httpLastModified;
@synthesize rspHeaders=_rspHeaders;
@synthesize rspData=_rspData;
@synthesize error=_error;
@synthesize attached=_attached;

-(void)dealloc {
    [_url release];
	[_httpContentType release];
    self.httpETag = nil;
    self.httpLastModified = nil;
    [_rspHeaders release];
	[_rspData release];
	[_error release];
    [_attached release];
	
	[super dealloc];
}

@end

@interface Downloader() <DownloadCallback>
@property (nonatomic, retain) NSMutableDictionary *netTasks;

-(NSString *)pathOfUrlHeader:(NSString*)url;

-(void)downloadTask: (DownloadTask*)tsk DidFinishWithError: (NSError*)error;

-(NSInteger)doAddDownloadTask:(NSString*)url IsPost:(BOOL)bPost PostData:(NSData*)postData PostContentType:(NSString*)postContentType AppendPassport:(BOOL)bAppendPassport UserName:(NSString*)userName Passwrod:(NSString*)password Target:(id)target Callback:(SEL)sel Attached:(id)attached AdditionalHeader:(NSDictionary*)dic CachedPkgFile:(PackageFile*)pkg;
-(void)doDownloadCallback:(BqsDownloaderItem*)di Task: (DownloadTask*)tsk Error:(NSError*)error;

@end


@implementation Downloader
@synthesize bSearialLoad,nRetryCnt,bAppendBqsHeaders;
@synthesize netTasks = _netTasks;


-(id)init {
	self = [super init];
	if(nil == self) return nil;
	
	_taskId = 1;
	_netTasks = [[NSMutableDictionary alloc] initWithCapacity:10];
    _serialLoadTask = [[NSMutableArray alloc] initWithCapacity:30];
    
    self.bAppendBqsHeaders = YES;
    
    _bAlive = YES;
	return self;
}

-(void)dealloc {
    BqsLog(@"dealloc: %d",self);
    _bAlive = NO;
    
	[self cancelAll];
	[_netTasks release];
    _netTasks = nil;
    [_serialLoadTask release];
    _serialLoadTask = nil;
	
	[super dealloc];
}

-(NSString *)pathOfUrlHeader:(NSString*)url {
    if(nil == url || [url length] < 1) return @"";
    
    return [url stringByAppendingString:kDataSubfix_Header];
}


// callback select must has the form:
// (void)callbackName:(DownloaderCallbackObj*)obj
-(NSInteger)addTask:(NSString*)url Target:(id)target Callback:(SEL)sel Attached:(id)attached {
    return [self doAddDownloadTask:url IsPost:NO PostData:nil PostContentType:nil AppendPassport:YES UserName:nil Passwrod:nil Target:target Callback:sel Attached:attached AdditionalHeader:nil CachedPkgFile:nil];
}
-(NSInteger)addTask:(NSString*)url Target:(id)target Callback:(SEL)sel Attached:(id)attached AppendHeaders:(NSDictionary*)dic {
    return [self doAddDownloadTask:url IsPost:NO PostData:nil PostContentType:nil AppendPassport:YES UserName:nil Passwrod:nil Target:target Callback:sel Attached:attached AdditionalHeader:dic CachedPkgFile:nil];    
}
-(NSInteger)addTask:(NSString*)url Target:(id)target Callback:(SEL)sel Attached:(id)attached AppendPassport:(BOOL)bAppendPassport {
    return [self doAddDownloadTask:url IsPost:NO PostData:nil PostContentType:nil AppendPassport:bAppendPassport UserName:nil Passwrod:nil Target:target Callback:sel Attached:attached AdditionalHeader:nil CachedPkgFile:nil];
}
-(NSInteger)addTask:(NSString*)url Target:(id)target Callback:(SEL)sel Attached:(id)attached UserName:(NSString*)user Password:(NSString*)password {
    return [self doAddDownloadTask:url IsPost:NO PostData:nil PostContentType:nil AppendPassport:NO UserName:user Passwrod:password Target:target Callback:sel Attached:attached AdditionalHeader: nil CachedPkgFile:nil];
}

-(NSInteger)addPostTask:(NSString*)url Data:(NSData*)data ContentType:(NSString*)sContentType Target:(id)target Callback:(SEL)sel Attached:(id)attached {
    return [self doAddDownloadTask:url IsPost:YES PostData:data PostContentType:sContentType AppendPassport:YES UserName:nil Passwrod:nil Target:target Callback:sel Attached:attached AdditionalHeader: nil CachedPkgFile:nil];
}

-(NSInteger)addPostTask:(NSString*)url Data:(NSData*)data ContentType:(NSString*)sContentType Target:(id)target Callback:(SEL)sel Attached:(id)attached AppendPassport:(BOOL)bAppendPassport {
    return [self doAddDownloadTask:url IsPost:YES PostData:data PostContentType:sContentType AppendPassport:bAppendPassport UserName:nil Passwrod:nil Target:target Callback:sel Attached:attached AdditionalHeader: nil CachedPkgFile:nil];
}
-(NSInteger)addPostTask:(NSString*)url Data:(NSData*)data ContentType:(NSString*)sContentType Target:(id)target Callback:(SEL)sel Attached:(id)attached AppendPassport:(BOOL)bAppendPassport AdditionalHeader:(NSDictionary*)hdr {
    return [self doAddDownloadTask:url IsPost:YES PostData:data PostContentType:sContentType AppendPassport:bAppendPassport UserName:nil Passwrod:nil Target:target Callback:sel Attached:attached AdditionalHeader: hdr CachedPkgFile:nil];
}

-(NSInteger)addCachedTask:(NSString*)url PkgFile:(PackageFile*)pkgFile Target:(id)target Callback:(SEL)sel Attached:(id)attached {
    return [self addCachedTask:url PkgFile:pkgFile Target:target Callback:sel Attached:attached AppendPassport:YES];
}
-(NSInteger)addCachedTask:(NSString*)url PkgFile:(PackageFile*)pkgFile Target:(id)target Callback:(SEL)sel Attached:(id)attached AppendPassport:(BOOL)bAppendPassport {
    if(nil == pkgFile) {
        return [self doAddDownloadTask:url IsPost:NO PostData:nil PostContentType:nil AppendPassport:bAppendPassport UserName:nil Passwrod:nil Target:target Callback:sel Attached:attached AdditionalHeader:nil CachedPkgFile:nil];
    }
    
    NSMutableDictionary *dicReqAddHeader = nil;
    
    // check cache
    int dataLen = [pkgFile getDataLength:url];
    if(dataLen > 0) {
        
        // read header
        NSString *hdrPath = [self pathOfUrlHeader:url];
        NSData *data = [pkgFile readDataName:hdrPath];
        if(nil != data && [data length] > 0) {
            id unaobj = nil;
            @try {
                unaobj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            }
            @catch (NSException *exception) {
            }
            @finally {
            }
            
            if(nil != unaobj || [unaobj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dicHeader = (NSDictionary*)unaobj;
                
                
                double now = [[NSDate date] timeIntervalSince1970];
                
                double fExpire = -1.0;
                int iDatalen = 0;
                BOOL bPoweredByBorqs = NO;
                NSString *sContentType = nil;
                dicReqAddHeader = [NSMutableDictionary dictionaryWithCapacity:2];
                
                // read 
                NSString *sV = [dicHeader objectForKey:kHeader_ExpireTS];
                if(nil != sV && [sV length] > 0) fExpire = [sV floatValue];
                
                sV = [dicHeader objectForKey:kHeader_PoweredByBorqs];
                bPoweredByBorqs = [BqsUtils parseBoolean:sV Def:NO];
                
                sV = [dicHeader objectForKey:kHeader_DataLen];
                if(nil != sV && [sV length] > 0) iDatalen = [sV intValue];
                
                sV = [dicHeader objectForKey:kHeader_ContentType];
                if(nil != sV && [sV length] > 0) sContentType = [[sV copy] autorelease];
                
                
                sV = [dicHeader objectForKey:kHeader_ETag];
                if(nil != sV && [sV length] > 0) [dicReqAddHeader setValue:[[sV copy] autorelease] forKey:kHttpHeader_ReqETag];
                sV = [dicHeader objectForKey:kHeader_LastModified];
                if(nil != sV && [sV length] > 0) [dicReqAddHeader setValue:[[sV copy] autorelease] forKey:kHttpHeader_ReqLastModifed];
                
                // check expire
                if(fExpire > now) {
                    NSData *cachedBodyData = [pkgFile readDataName:url];
                    if(nil != cachedBodyData && 
                       iDatalen == [cachedBodyData length] && 
                       iDatalen == dataLen) {
                        
                        // not yet expire 
                        BqsLog(@"data not yet expire: %@", url);
                        
                        [pkgFile updateDataTimeToNow:hdrPath Flush:NO];
                        [pkgFile updateDataTimeToNow:url Flush:NO];
                        
                        int tskId = -1;
                        @synchronized(self) {
                            tskId = _taskId ++;
                        }
                        
                        DownloaderCallbackObj *cbO = [[DownloaderCallbackObj alloc] init];
                        cbO.taskId = tskId;
                        cbO.url = url;
                        cbO.httpStatus = 200;
                        cbO.httpContentType = sContentType;
                        cbO.rspHeaders = dicHeader;
                        cbO.rspData = cachedBodyData;
                        cbO.error = nil;
                        cbO.attached = attached;
                        
                        if(nil != target && [target respondsToSelector:sel]) {
                            [target performSelector:sel withObject:cbO afterDelay:.01];
                        }
                        [cbO release];
                        return tskId;
                    } else {
                        // data not exist
                        dicReqAddHeader = nil;
                    }
                }
            }
        }
    }
        
    return [self doAddDownloadTask:url IsPost:NO PostData:nil PostContentType:nil AppendPassport:bAppendPassport UserName:nil Passwrod:nil Target:target Callback:sel Attached:attached AdditionalHeader:dicReqAddHeader CachedPkgFile:pkgFile];

}


-(NSInteger)doAddDownloadTask:(NSString*)url IsPost:(BOOL)bPost PostData:(NSData*)postData PostContentType:(NSString*)postContentType AppendPassport:(BOOL)bAppendPassport UserName:(NSString*)userName Passwrod:(NSString*)password Target:(id)target Callback:(SEL)sel Attached:(id)attached AdditionalHeader:(NSDictionary*)dic CachedPkgFile:(PackageFile*)pkg{
    @synchronized(self) {
        BqsDownloaderItem *di = [[BqsDownloaderItem alloc] init];
        di.taskId = _taskId ++;
        di.cbTarget = target;
        di.cbSelector = sel;
        di.attached = attached;
        DownloadTask *dt = nil;
        
        if(!bPost) {
            dt = [[DownloadTask alloc] initWithUrl:url Path:nil Callback:self ProgressCallback:nil Resume:NO Attached:di AppendPassport:bAppendPassport UserName:userName Password:password AddtionalHeaders:dic];
        } else {
            dt = [[DownloadTask alloc] initPostWithUrl:url Data:postData ContentType:postContentType Path:nil Callback:self ProgressCallback:nil Attached:di AppendPassport:bAppendPassport UserName:userName Password:password AddtionalHeaders:dic];
        }
        di.downloadTask = dt;
        dt.attached = di;
        dt.taskId = di.taskId;
        dt.nRetryCnt = self.nRetryCnt;
        dt.bAppendBqsHeaders = self.bAppendBqsHeaders;
        di.pkgFile = pkg;
        [dt release];
        
        [self.netTasks setObject:di forKey:[NSNumber numberWithInt:di.taskId]];
        [di release];
        
        BOOL bStarted = YES;
        if(!self.bSearialLoad) {
            [dt start];	
            
        } else {
            if([self.netTasks count] == 1) {
                [dt start];
                BqsLog(@"Task start: %d, %@", di.taskId, url);
            } else {
                [_serialLoadTask addObject:di];
                bStarted = NO;
            }
        }
        if(bStarted) {
            BqsLog(@"Task start: %d, %@", di.taskId, url);
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        } else {
            BqsLog(@"Task append: %d, %@", di.taskId, url);
        }
        
        return di.taskId;
    }

}

-(void)cancelTask:(NSInteger)taskId {
    BqsLog(@"cancelTask: %d", taskId);
    @synchronized(self) {
        NSNumber *key = [NSNumber numberWithInt:taskId];
        BqsDownloaderItem *di = [_netTasks objectForKey:key];
        if(nil == di) return;

        [_serialLoadTask removeObject:di];
        
        if(nil != di.downloadTask) [di.downloadTask cancel: NO];
        
        [_netTasks removeObjectForKey:key];
        
        if([_netTasks count] < 1) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    }
	return;
}

-(void)cancelAll {
    BqsLog(@"cancelTaskAll %d. serial: %@, tasks: %@",self, _serialLoadTask, _netTasks);
    
    @synchronized(self) {
        [_serialLoadTask removeAllObjects];
        
        if([_netTasks count] > 0) {
            NSArray *arr = [_netTasks allValues];
            if(nil != arr && [arr count] > 0) {
                for (BqsDownloaderItem *di in arr) {
                    if(nil != di.downloadTask) [di.downloadTask cancel: NO];
                }
            }
            [_netTasks removeAllObjects];

        }
    }
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(int)count {
    @synchronized(self) {
        return [_netTasks count];
    }
}

-(void)handleCachedDownloadCallback:(BqsDownloaderItem*)di Task:(DownloadTask*)tsk Error:(NSError*)error {
    if(nil == tsk || nil == di) return;
    if(nil == di.pkgFile) return;
    if(nil != error) return;
    
    PackageFile *pkgFile = di.pkgFile;
    NSString *url = tsk.url;
    
    if(304 == tsk.httpStatus) {
        // not modified
        // read old data
        tsk.downloadedData = (NSMutableData*)[pkgFile readDataName:url];
        tsk.httpStatus = 200;
        
        [pkgFile updateDataTimeToNow:url Flush:NO];
    } else if(200 == tsk.httpStatus) {
        // save to cache
        [pkgFile writeDataName:url Data:tsk.downloadedData];
    } else {
        // server return error
        return;
    }
    
    // update header meta
    
    if(nil != tsk.rspHeaders && [tsk.rspHeaders count] > 0) {
        // update last modify, etag, expires
        double fExpires = 0;
        
        NSString *sExpire = tsk.httpExpires;
        NSString *sETag = tsk.httpETag;
        NSString *sLastModified = tsk.httpLastModified;

        if(nil != sExpire && [sExpire length] > 0) {
            if([@"0" isEqualToString:sExpire] || [@"-1" isEqualToString:sExpire]) {
                
            } else {
                NSDateFormatter *rfc1123DateFormatter = [[[NSDateFormatter alloc] init] autorelease];
                [rfc1123DateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
                [rfc1123DateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
                [rfc1123DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                [rfc1123DateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
                
                NSDate *tm = [rfc1123DateFormatter dateFromString:sExpire];
                if(nil != tm) {
//                    BqsLog(@"expires: %@->%@", sExpire, tm);
                    fExpires = [tm timeIntervalSince1970];
                }
            }
        }
        if((nil == sETag || [sETag length] < 1) && nil != tsk.reqHeader) {
            sETag = [tsk.reqHeader objectForKey:@"If-None-Match"];
        }
        if((nil == sLastModified || [sLastModified length] < 1) && nil != tsk.reqHeader) {
            sLastModified = [tsk.reqHeader objectForKey:@"If-Modified-Since"];
        }
        
        
        // write to data
        NSMutableDictionary *dicHeader = [NSMutableDictionary dictionaryWithCapacity:6];
        if(fExpires > 0) [dicHeader setObject:[NSString stringWithFormat:@"%.1f", fExpires] forKey:kHeader_ExpireTS];
        if(nil != sETag && [sETag length] > 0) [dicHeader setObject:sETag forKey:kHeader_ETag];
        if(nil != sLastModified && [sLastModified length] > 0) [dicHeader setObject:sLastModified forKey:kHeader_LastModified];
        if(nil != tsk.httpContentType && [tsk.httpContentType length] > 0) [dicHeader setObject:tsk.httpContentType forKey:kHeader_ContentType];
        if(nil != tsk.downloadedData) [dicHeader setObject:[NSString stringWithFormat:@"%d", [tsk.downloadedData length]] forKey:kHeader_DataLen];
        
//        BqsLog(@"write meta: %@, %@", dicHeader, url);
        [pkgFile writeDataName:[self pathOfUrlHeader:url] Data:[NSKeyedArchiver archivedDataWithRootObject:dicHeader]];
    }

}

-(void)doDownloadCallback:(BqsDownloaderItem*)di Task: (DownloadTask*)tsk Error:(NSError*)error {
    if(nil != di.cbTarget && nil != di.cbSelector) {
        DownloaderCallbackObj *cbO = [[DownloaderCallbackObj alloc] init];
        cbO.taskId = di.taskId;
        cbO.url = tsk.url;
        cbO.httpStatus = tsk.httpStatus;
        cbO.httpContentType = tsk.httpContentType;
        cbO.httpETag = tsk.httpETag;
        cbO.httpLastModified = tsk.httpLastModified;
        cbO.rspHeaders = tsk.rspHeaders;
        cbO.rspData = tsk.downloadedData;
        cbO.error = error;
        cbO.attached = di.attached;
        
        {
            NSAutoreleasePool *subPool = [[NSAutoreleasePool alloc] init];
            
            //            @try {
            if(nil != di.cbTarget && [di.cbTarget respondsToSelector:di.cbSelector]) {
                [di.cbTarget performSelector:di.cbSelector withObject:cbO];
            }
            //            }
            //            @catch (NSException *exception) {
            //                BqsLog(@"exception: %@!!!\n!!!\n!!!\n!!!\n!!!\n!!!\n!!!\n!!!\n!!!\n", exception);
            //            }
            //            @finally {
            //            }
            
            [subPool drain];
        }
        
        [cbO release];
    }

}

-(void)downloadTask: (DownloadTask*)tsk DidFinishWithError: (NSError*)error {
    
    [[self retain] autorelease];
    
    @synchronized(self) {
        if(!_bAlive||nil == _netTasks) return;

        BqsLog(@"Task finished: %d, %d, %@, 0x%x", tsk.taskId, tsk.httpStatus, tsk.url, tsk.attached);

        BqsDownloaderItem *di = [_netTasks objectForKey:[NSNumber numberWithInt:tsk.taskId]];
        assert(di == tsk.attached);
        
        if(nil == di) return;
        
        [di retain];
        
        [_netTasks removeObjectForKey:[NSNumber numberWithInt:tsk.taskId]];
        
        [self handleCachedDownloadCallback:di Task:tsk Error:error];
        [self doDownloadCallback:di Task:tsk Error:error];
        
        if(tsk.bAuthFailed) {
            [di release];
            BqsLog(@"auth failed, cancel all other tasks");
            [self cancelAll];
            UIApplication *app = [UIApplication sharedApplication];
            if(nil != app) {
                app.networkActivityIndicatorVisible = NO;
            }
            return;
        }
        [di release];
        
        BqsLog(@"_bAlive: %d, %d",_bAlive, self);
        if(!_bAlive) return;
        
        if(nil == _netTasks || [_netTasks count] < 1) {
            UIApplication *app = [UIApplication sharedApplication];
            if(nil != app) {
                app.networkActivityIndicatorVisible = NO;
            }
        } else {
            if(bSearialLoad && [_serialLoadTask count] > 0) {
                
                BqsDownloaderItem *di = [_serialLoadTask objectAtIndex:0];
                NSNumber *k = [NSNumber numberWithInt:di.taskId];
                if(di != [_netTasks objectForKey:k]) {
                    BqsLog(@"di Not match: %@ != %@", di, [_netTasks objectForKey:k]);
                    [_netTasks setObject:di forKey:k];
                }
                [_serialLoadTask removeObjectAtIndex:0];
                [di.downloadTask start];
                BqsLog(@"Serial Task start: %d, %@", di.taskId, di.downloadTask.url);
            }
        }
    }
}


@end



#pragma mark NetOpCbs
@implementation NetOpCbs
@synthesize target=_target;
@synthesize sel=_sel;
@synthesize attached=_attached;

-(void)dealloc {
    [_attached release];
    [super dealloc];
}
@end

