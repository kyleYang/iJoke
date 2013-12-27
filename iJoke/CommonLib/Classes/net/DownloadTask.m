//
//  DownloadTask.m
//  iMobee
//
//  Created by ellison on 10-9-17.
//  Copyright 2010 borqs. All rights reserved.
//

#import "DownloadTask.h"
#import "BqsUtils.h"
#import "Env.h"
#import "UserMgr.h"
#import "FTSUserCenter.h"

#define kNetworkTimeout 60.0 //seconds

#if __has_feature(objc_arc)
#error This file cannot be compiled with ARC. Either turn off ARC for the project or use -fno-objc-arc flag
#endif


@interface DownloadTask()<NSURLConnectionDataDelegate>

@property (assign, readwrite) BOOL bIsPost;
@property (copy, readwrite) NSString *postContentType;
@property (retain, readwrite) NSData *postBody;
@property (retain, readwrite) NSDictionary *reqHeader;

@property (retain) NSURLConnection *connection;
@property (retain) NSOutputStream *fileStream;
@property (copy) NSString *authUserName; // user name for login
@property (copy) NSString *authPassword; // password for login

- (void)doCallbackFinish;
- (void)stopReceiveWithError:(NSInteger)errCode Msg:(NSString*)msg;
@end

@implementation DownloadTask
@synthesize bIsPost;
@synthesize postContentType;
@synthesize postBody;
@synthesize reqHeader;

@synthesize url = _url;
@synthesize path = _path;
@synthesize bResume = _bResumeDownload;
@synthesize curBytes = _curBytes;
@synthesize totalBytes = _totalBytes;
@synthesize attached = _attached;
@synthesize nRetryCnt;
@synthesize taskId = _taskId;
@synthesize progressCallback = _cbProgress;
@synthesize callback = _cbCallback;
@synthesize error = _error;
@synthesize connection = _connection;
@synthesize fileStream = _fileStream;
@synthesize downloadedData = _downloadedData;
@synthesize httpStatus = _httpStatus;
@synthesize httpContentType = _httpContentType;
@synthesize httpExpires;
@synthesize httpLastModified;
@synthesize httpETag;
@synthesize authUserName;
@synthesize authPassword;
@synthesize rspHeaders;
@synthesize bAuthFailed;
@synthesize bAppendBqsHeaders;

-(id)initWithUrl:(NSString*)sUrl Path:(NSString*)sPath Callback: (id<DownloadCallback>)cb ProgressCallback: (id<DownloadProgressCallback>)pcb Resume: (BOOL)bResume Attached:(id)iAttached {
    return [self initWithUrl:sUrl Path:sPath Callback:cb ProgressCallback:pcb Resume:bResume Attached:iAttached AppendPassport:YES];
}
-(id)initWithUrl:(NSString*)sUrl Path:(NSString*)sPath Callback: (id<DownloadCallback>)cb ProgressCallback: (id<DownloadProgressCallback>)pcb Resume: (BOOL)bResume Attached:(id)iAttached AppendPassport:(BOOL)bAppendPassport {
    return [self initWithUrl:sUrl Path:sPath Callback:cb ProgressCallback:pcb Resume:bResume Attached:iAttached AppendPassport:bAppendPassport UserName:nil Password:nil AddtionalHeaders:nil];
}
-(id)initWithUrl:(NSString*)sUrl Path:(NSString*)sPath Callback: (id<DownloadCallback>)cb ProgressCallback: (id<DownloadProgressCallback>)pcb Resume: (BOOL)bResume Attached:(id)iAttached AppendPassport:(BOOL)bAppendPassport UserName:(NSString*)userName Password:(NSString*)password AddtionalHeaders:(NSDictionary*)aReqHeader{
	self = [super init];
	if(nil == self) return nil;
	
    self.bIsPost = NO;
	self.url = sUrl;
	self.path = sPath;
	self.progressCallback = pcb;
	self.callback = cb;
	self.bResume = bResume;
    self.attached = iAttached;
    _bAppendPassport = bAppendPassport;
    self.authUserName = userName;
    self.authPassword = password;
    self.reqHeader = aReqHeader;

    _bCanceled = NO;
    
    self.bAppendBqsHeaders = YES;
	
	return self;
}
-(id)initWithUrl:(NSString*)sUrl Callback: (id<DownloadCallback>)cb Attached:(id)iAttached {
    return [self initWithUrl:sUrl Callback:cb Attached:iAttached AppendPassport:YES];
}
-(id)initWithUrl:(NSString*)sUrl Callback: (id<DownloadCallback>)cb Attached:(id)iAttached AppendPassport:(BOOL)bAppendPassport {
    return [self initWithUrl:sUrl Path:nil Callback:cb ProgressCallback:nil Resume:NO Attached:iAttached AppendPassport:YES];
}

-(id)initPostWithUrl:(NSString*)sUrl Data:(NSData*)data ContentType:(NSString*)sContentType Path:(NSString*)sPath Callback: (id<DownloadCallback>)cb ProgressCallback: (id<DownloadProgressCallback>)pcb Attached:(id)iAttached AppendPassport:(BOOL)bAppendPassport UserName:(NSString*)userName Password:(NSString*)password AddtionalHeaders:(NSDictionary*)aReqHeader{
	self = [super init];
	if(nil == self) return nil;
    
    self.bIsPost = YES;
    self.postBody = data;
    self.postContentType = sContentType;
	
	self.url = sUrl;
	self.path = sPath;
	self.progressCallback = pcb;
	self.callback = cb;
	self.bResume = NO;
    self.attached = iAttached;
    _bAppendPassport = bAppendPassport;
    self.authUserName = userName;
    self.authPassword = password;
    self.reqHeader = aReqHeader;

    _bCanceled = NO;
    
    self.bAppendBqsHeaders = YES;
	
	return self;
    
}

-(void)dealloc {
    BqsLog(@"dealloc: %d", _taskId);
	if(nil != _connection) {
		[_connection cancel];
		[_connection release];
	}
	if(nil != _fileStream) {
		[_fileStream close];
		[_fileStream release];
	}
    
    self.postContentType = nil;
    self.postBody = nil;
    self.reqHeader = nil;

	
	[_url release];
	[_path release];
	[_error release];
	[_downloadedData release];
	[_httpContentType release];
    self.httpExpires = nil;
    self.httpLastModified = nil;
    self.httpETag = nil;

    self.authUserName = nil;
    self.authPassword = nil;
    self.rspHeaders = nil;

	[super dealloc];
}

- (BOOL)isReceiving
{
    return (self.connection != nil);
}

-(void)start {
    
    assert(_connection == nil); // don't tap receive twice in a row!
    assert(_fileStream == nil); // ditto
	
	// Open a stream for the file we're going to receive into.
	//assert(_path != nil);
	int oldFileSize = 0;
	
	if(nil != _path) {
		oldFileSize = [BqsUtils fileSize: _path];
		BqsLog(@"old file size: %d %@", oldFileSize, _path);
		if(oldFileSize <= 0) {
			// check create path
			NSString *dir = [_path stringByDeletingLastPathComponent];
			[BqsUtils checkCreateDir:dir];
		}
		if(_bResumeDownload) {
			self.fileStream = [NSOutputStream outputStreamToFileAtPath:_path append:YES];
		} else {
			self.fileStream = [NSOutputStream outputStreamToFileAtPath:_path append:NO];
		}
		if(nil == _fileStream) {
			BqsLog(@"Failed to open file stream: %@", _path);
			[self stopReceiveWithError:NSURLErrorCannotOpenFile Msg: _path];
			return;
		}
        
		[_fileStream open];
	} else {
		self.downloadedData = nil;
	}
    
    Env *env = [Env sharedEnv];
    // attach passport
    NSString *sUrl = [BqsUtils fixURLHost:_url];
    
    if(self.bAppendBqsHeaders && _bAppendPassport) {
//        NSString *passport = [UserMgr instance].userInfo.passport;
//        if([passport length] < 1) {
//            passport = @"abc";
//        }
//        sUrl = [BqsUtils setURL:sUrl ParameterName:@"bqsPassport" Value:passport];
    }
    
	// Open a connection for the URL.
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: sUrl] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval: kNetworkTimeout];
	
	if(nil == request) {
		BqsLog(@"Cant create request: %@", _url);
		[self stopReceiveWithError:NSURLErrorBadURL Msg: _url];
		return;
	}
    
    if(self.bIsPost) {
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:self.postBody];
        if(nil != self.postContentType && [self.postContentType length] > 0) {
            [request setValue:self.postContentType forHTTPHeaderField:@"Content-Type"];
        } else {
            [request setValue:kHttpPostContentType_OctetStream forHTTPHeaderField:@"Content-Type"];
        }
    }
	
	if(_bResumeDownload && oldFileSize > 0) {
		_curBytes = oldFileSize;
		[request setValue:[NSString stringWithFormat:@"bytes=%d-", oldFileSize] forHTTPHeaderField:@"Range"];
	} else {
		_curBytes = 0;
	}
	
    if(nil != self.reqHeader && [self.reqHeader count] > 0) {
        NSArray *ks = [self.reqHeader allKeys];
        if(nil != ks && [ks count] > 0) {
            for(NSString *key in ks) {
                if(nil == key || [key length] < 1) continue;
                
                NSString *val = [self.reqHeader objectForKey:key];
                if(nil != val) {
                    [request setValue:val forHTTPHeaderField:key];
                }
            }
        }
    }
    
    // set additional headers
    if(self.bAppendBqsHeaders) {
        [request setValue:env.hdrClientType forHTTPHeaderField:@"X-Bqs-Client"];
        [request setValue:env.sScreenSize forHTTPHeaderField:@"X-Device-Res"];
        [request setValue:env.sScreenScale forHTTPHeaderField:@"X-Device-DensityFactor"];
        [request setValue:env.market forHTTPHeaderField:@"X-Bqs-Market"];
        [request setValue:env.swVersion forHTTPHeaderField:@"X-Bqs-Ver"];
        [request setValue:NSLocalizedStringFromTable(@"sys.language", @"commonlib", nil) forHTTPHeaderField:@"X-Bqs-Lang"];
        [request setValue:env.sDevId forHTTPHeaderField:@"X-Bqs-Dev"];
    }
    if([FTSUserCenter BoolValueForKey:kDftUserLogin]){
        [request setValue:[FTSUserCenter objectValueForKey:kDftUserName] forHTTPHeaderField:@"username"];
        [request setValue:[FTSUserCenter objectValueForKey:kDftUserPassport] forHTTPHeaderField:@"passport"];
    }else{
        [request setValue:env.macUdid forHTTPHeaderField:@"mac"];
    }
    
    
    
    if(nil != env.dicNetAppAppendHeader && [env.dicNetAppAppendHeader count] > 0) {
        NSArray *keys = [env.dicNetAppAppendHeader allKeys];
        for(NSString *key in keys) {
            NSString *val = [env.dicNetAppAppendHeader objectForKey:key];
            if(nil != key && [key length] > 0 &&
               nil != val && [val length] > 0) {
                [request setValue:val forHTTPHeaderField:key];
            }
        }
    }
	
	BqsLog(@"requestURL: %@ with: %@", sUrl, [request allHTTPHeaderFields]);
        
	self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
	
	if(nil == _connection) {
		BqsLog(@"Can't create connection: %@", _url);
		[self stopReceiveWithError:NSURLErrorNetworkConnectionLost Msg: _url];
		return;
	}
}

-(void)cancel {
    [self cancel:NO];
}
-(void)cancel:(BOOL)bCallback {
	BqsLog(@"Cancel: %d, %@, %@, %@", _taskId, _connection, _fileStream, _url);
	if(nil != _connection) {
		[_connection cancel];
		self.connection = nil;
		if(nil != _fileStream) {
			[_fileStream close];
			self.fileStream = nil;
		}
		self.downloadedData = nil;
		
		self.error = [NSError errorWithDomain:@"" code:NSURLErrorCancelled userInfo:nil];
        if(bCallback) {
            [self doCallbackFinish];
        }
	}
    
    _bCanceled = YES;
	
}


- (void)doCallbackFinish {
    if(_bCanceled) {
        BqsLog(@"task already cancelled, ignore doCallbackFinish!!!\n!!!\n!!!\n!!!\n!!!\n!!!\n\n\n\n\n\n\n\n");
        return;
    }

    if(nil != _cbCallback && [_cbCallback respondsToSelector:@selector(downloadTask:DidFinishWithError:)]) {
        [_cbCallback downloadTask: self DidFinishWithError: self.error];
    }
}

- (void)stopReceiveWithError:(NSInteger)errCode Msg:(NSString*)msg
// Shuts down the connection and displays the result (statusString == nil) 
// or the error status (otherwise).
{
    if (_connection != nil) {
        [_connection cancel];
        self.connection = nil;
    }
    if (_fileStream != nil) {
        [_fileStream close];
        self.fileStream = nil;
    }
    
    
    if(0 != errCode) {
        NSDictionary *userInfo = nil;
        if(nil != msg) {
            userInfo = [NSDictionary dictionaryWithObject:msg forKey:kErrMsgKey];
        }
        
        self.error = [NSError errorWithDomain:@"" code: errCode userInfo: userInfo];
    }
    
	[self doCallbackFinish];
}

#pragma mark NSURLConnection delegate

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
// A delegate method called by the NSURLConnection when the request/response 
// exchange is complete.  We look at the response to check that the HTTP 
// status code is 2xx and that the Content-Type is acceptable.  If these checks 
// fail, we give up on the transfer.
{
    if(theConnection != self.connection) {
        BqsLog(@"not my connection");
        return;
    }

    NSHTTPURLResponse * httpResponse;

    assert(theConnection == self.connection);
    
	httpResponse = (NSHTTPURLResponse *) response;
	
	if(![httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
		BqsLog(@"Not a http url response!!! %@", _url);
		return;
	}
	
	int httpStatus = httpResponse.statusCode;
	NSString *contentType = @"";
	NSString *newPassport = @"";
    NSString *xpowerby = @"";

    NSDictionary *hdrs = [httpResponse allHeaderFields];
//    BqsLog(@"hdrs: %@", hdrs);
	for(NSString *hdr in [hdrs allKeys]) {
		if(NSOrderedSame == [@"content-type" caseInsensitiveCompare:hdr]) {
			contentType = [hdrs objectForKey:hdr];
//            BqsLog(@"BugHere!!!!!!!!!!!!!!");
//            break;
		} else if(NSOrderedSame == [@"set-cookie" caseInsensitiveCompare:hdr]) {
            id val = [hdrs objectForKey:hdr];
            NSString *ck = nil;
            if([val isKindOfClass:[NSString class]]) {
                ck = (NSString *)val;
            }
            //BqsLog(@"ck:%@", ck);
            if(nil != ck) {
                NSRange rng = [ck rangeOfString:@"bqsPassport="];
                if(NSNotFound == rng.location) {
                    rng = [ck rangeOfString:@"borqsPassport="];
                }
                if(NSNotFound != rng.location) {
                    int nStart = rng.location + rng.length;
                    int nEnd = [ck length];
                    NSRange rngEnd = [ck rangeOfString:@";" options:NSStringEnumerationByComposedCharacterSequences range:NSMakeRange(nStart, [ck length]-nStart)];
                    
                    if(NSNotFound != rngEnd.location) {
                        nEnd = rngEnd.location;
                    }
                    
                    newPassport = [ck substringWithRange:NSMakeRange(nStart, nEnd-nStart)];
                }
            }
        } else if(NSOrderedSame == [@"x-powered-by" caseInsensitiveCompare:hdr]) {
            xpowerby = [hdrs objectForKey:hdr];
        } else if(NSOrderedSame == [@"Expires" caseInsensitiveCompare:hdr]) {
            self.httpExpires = [hdrs objectForKey:hdr];
        } else if(NSOrderedSame == [@"ETag" caseInsensitiveCompare:hdr]) {
            self.httpETag = [hdrs objectForKey:hdr];
        } else if(NSOrderedSame == [@"Last-Modified" caseInsensitiveCompare:hdr]) {
            self.httpLastModified = [hdrs objectForKey:hdr];
        }
	}
    // check update local passport
    NSString *oldPassport = [UserMgr instance].userInfo.passport;
    if([newPassport length] > 6 && ![newPassport isEqualToString:oldPassport]) {
        [[UserMgr instance] ntfCookieNewPassportReturn:newPassport UserName:self.authUserName];
    }
    
    self.rspHeaders = hdrs;
    
	BqsLog(@"http: %d %@ %@ %@", httpStatus, contentType, xpowerby, self.url);
	self.httpStatus = httpStatus;
	self.httpContentType = contentType;
    if ((httpStatus / 100) != 2) {
		
		if(416 == httpStatus) {
			BqsLog(@"Server return 416, re-request url without Range");
			[_connection cancel];
			self.connection = nil;
			[_fileStream close];
			self.fileStream = nil;
			
			_bResumeDownload = NO;
			
			[self start];
			return;
		}
        
        if(304 == httpStatus) {
            [self stopReceiveWithError:0 Msg:nil];
        } else {
            BqsLog(@"Server return error: %d, %@", httpStatus, _url);
            
            [self stopReceiveWithError:NSURLErrorBadServerResponse Msg:[NSString stringWithFormat:@"HTTP%d", httpStatus]];
		}
		return;
    }
	
	if(_bResumeDownload && 206 != httpStatus) {
		// re open the file without append
		[_fileStream close];
		self.fileStream = nil;
		
		self.fileStream = [NSOutputStream outputStreamToFileAtPath:_path append:NO];
		if(nil == _fileStream) {
			BqsLog(@"Failed to open file stream: %@", _path);
			[self stopReceiveWithError:NSURLErrorCannotOpenFile Msg: _path];
			return;
		}
		[_fileStream open];
		
		_curBytes = 0;
	}
	
	// get response content length
	int content_length = NSURLResponseUnknownLength;
	if(206 == httpStatus) {
		NSString *sRange = [[httpResponse allHeaderFields] objectForKey:@"Content-Range"];
		BqsLog(@"sRange: %@", sRange);
		NSRange pos = [sRange rangeOfString:@"/"];
		if(NSNotFound != pos.location) {
			if(pos.location < [sRange length] - 1) {
				sRange = [sRange substringFromIndex:pos.location + 1];
				
				content_length = [sRange intValue];
				BqsLog(@"206 length: %d", content_length);
			}
		}
	} else {
		content_length = (int)[response expectedContentLength];
	}
	
	if(NSURLResponseUnknownLength != content_length) {
		self.totalBytes = content_length;
	}
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
// A delegate method called by the NSURLConnection as data arrives.  We just 
// write the data to the file.
{
    if(theConnection != self.connection) {
        BqsLog(@"not my connection");
        return;
    }

    NSInteger dataLength;
    const uint8_t * dataBytes;
    NSInteger bytesWritten;
    NSInteger bytesWrittenSoFar;
	
    assert(theConnection == self.connection);
    
    dataLength = [data length];
    dataBytes = [data bytes];
	
	
	if(nil != _fileStream) {
		bytesWrittenSoFar = 0;
		do {
			bytesWritten = [self.fileStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
			//assert(bytesWritten != 0);
			if (bytesWritten <= 0) {
				[self stopReceiveWithError:NSURLErrorCannotWriteToFile Msg:nil];
				return;
			} else {
				bytesWrittenSoFar += bytesWritten;
				_curBytes += bytesWritten;
			}
		} while (bytesWrittenSoFar < dataLength);		
	} else {
		if(nil == _downloadedData) {
			int bufLen = _totalBytes;
			if(bufLen < 1) bufLen = 1024;
			if(bufLen < dataLength) bufLen = dataLength;
			
			_downloadedData = [[NSMutableData alloc] initWithLength:bufLen];
		}
		if([_downloadedData length] < dataLength + _curBytes) {
			[_downloadedData setLength:dataLength + _curBytes];
		}
		
		void* pDownload = ([_downloadedData mutableBytes] + _curBytes);
		memcpy(pDownload, dataBytes, dataLength);
		_curBytes += dataLength;
	}
    	
	if(nil != _cbProgress && [_cbProgress respondsToSelector:@selector(downloadTask:DownloadBytes:OfTotal:)]) {
		[_cbProgress downloadTask:self DownloadBytes:_curBytes OfTotal:_totalBytes];
	}
	if(_totalBytes > 0 && _curBytes >= _totalBytes) {
		[self connectionDidFinishLoading:theConnection];
	}
	//NSBqsLog(@"didReceiveData: %d", dataBytes);
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
// A delegate method called by the NSURLConnection if the connection fails. 
// We shut down the connection and display the failure.  Production quality code 
// would either display or log the actual error.
{
    if(theConnection != self.connection) {
        BqsLog(@"not my connection");
        return;
    }
    

    BqsLog(@"didFailWithError: %@ %@", error, _url);
    
    if(self.nRetryCnt > 0 && !_bCanceled) {
        self.nRetryCnt --;
        if (_connection != nil) {
            [_connection cancel];
            self.connection = nil;
        }
        if (_fileStream != nil) {
            [_fileStream close];
            self.fileStream = nil;
        }

        [self start];
        return;
    }
    
    NSString *msg = [error localizedDescription];
    if(self.bAuthFailed) {
        self.httpStatus = 401;
        msg = NSLocalizedStringFromTable(@"user.login.error.failed", @"commonlib", nil);
    }

    [self stopReceiveWithError:[error code] Msg: msg];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
// A delegate method called by the NSURLConnection when the connection has been 
// done successfully.  We shut down the connection with a nil status, which 
// causes the image to be displayed.
{

    if(theConnection != self.connection) {
        BqsLog(@"not my connection");
        return;
    }
    BqsLog(@"finishOK: %@", _url);
	
	[_connection cancel];
	self.connection = nil;
	if(nil != _fileStream) {
		[_fileStream close];
		self.fileStream = nil;
	}
	if(nil != _downloadedData) {
		[_downloadedData setLength:_curBytes];
	}
	
	
	self.error = nil;
    [self doCallbackFinish];
}


- (BOOL)connection:(NSURLConnection *)conn canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
// A delegate method called by the NSURLConnection when something happens with the 
// connection security-wise.  We defer all of the logic for how to handle this to 
// the ChallengeHandler module (and it's very custom subclasses).
{

    BOOL    result;
    
    if(conn != self.connection || protectionSpace == nil) {
        BqsLog(@"Invalid param: connection: %@, protectionSpace: %@", conn, protectionSpace);
        return NO;
    }
    
//    NSString *curHost = [Env sharedEnv].host;
    if([protectionSpace isProxy]/* || ![curHost isEqualToString:[protectionSpace host]]*/) {
        BqsLog(@"Invalid challenge. proxy: %d, host: %@", [protectionSpace isProxy], [protectionSpace host]);
        return NO;
    }
    
    NSString *method = [protectionSpace authenticationMethod];
    
    if(![NSURLAuthenticationMethodDefault isEqualToString:method] &&
       ![NSURLAuthenticationMethodHTTPBasic isEqualToString:method] && 
       ![NSURLAuthenticationMethodHTTPDigest isEqualToString:method]) {
        result = NO;
    } else {
        result = YES;
    }
    
    BqsLog(@"canAuthenticateAgainstProtectionSpace %@ -> %d", method, result);
    return result;
}

- (void)connection:(NSURLConnection *)conn didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
// A delegate method called by the NSURLConnection when you accept a specific 
// authentication challenge by returning YES from -connection:canAuthenticateAgainstProtectionSpace:. 
// Again, most of the logic has been shuffled off to the ChallengeHandler module; the only 
// policy decision we make here is that, if the challenge handle doesn't get it right in 1 tries, 
// we bail out.
{

    if(conn != self.connection || challenge == nil) {
        BqsLog(@"Invalid param: connection: %@, challenge: %@", conn, challenge);
        [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
        return;
    }
    
    NSLog(@"didReceiveAuthenticationChallenge %@ %zd", [[challenge protectionSpace] authenticationMethod], (ssize_t) [challenge previousFailureCount]);
    
    if ([challenge previousFailureCount] < 1) {
        
        NSURLCredential *credential = nil;
        
        if([self.authUserName length] > 0) {
            credential = [NSURLCredential credentialWithUser:self.authUserName password:self.authPassword persistence:NSURLCredentialPersistenceNone];
        } else {
            BqsUserInfo *usr = [UserMgr instance].userInfo;
            if([usr.logonName length] > 0) {
                NSString *password = usr.password;
                if((nil == password || [password length] < 1) && [usr isTmpUser]) {
                    BqsLog(@"no password saved for tmp user, set password as 8888");
                    password = @"8888";
                }
                BqsLog(@"logonName: %@, password: %@", usr.logonName, password);
                credential = [NSURLCredential credentialWithUser:usr.logonName password:password persistence:NSURLCredentialPersistenceNone];
            }
        }
        
        if(nil != credential) {
            BqsLog(@"continue with: %@ %@", [credential user], [credential password]);
            [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
        } else {
            BqsLog(@"continue without auth!!!");
            [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
        }
    } else {
        BqsLog(@"auth failed cnt >= 1");
        if([self.authUserName length] < 1) {
            NSString *curHost = [Env sharedEnv].host;
            
            NSString *urlHost = [BqsUtils getURLHost:self.url];
            
            if([self.url hasPrefix:@"/"] || [curHost isEqualToString:urlHost]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNtfBqsAuthFailed object:nil];
            }
        }
        self.bAuthFailed = YES;
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}

@end

