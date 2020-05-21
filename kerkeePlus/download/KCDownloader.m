//
//  KCDownloader.h
//  kerkeePlus
//
//  Created by zihong on 16/6/27.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import "KCDownloader.h"
#import <kerkee/KCBaseDefine.h>
#import <kerkee/KCFile.h>

static const double kBufferSize = 1000*1000; // 1 MB
static const NSTimeInterval kDefaultRequestTimeout = 30;
static const NSInteger kNumberOfSamples = 5;

NSString * const KCDownloadErrorDomain = @"com.kercer.download";
NSString * const KCDownloadErrorHTTPStatusKey = @"KCDownloadErrorHTTPStatusKey";

@interface KCDownloader () <NSURLSessionDelegate>
{
    //download
    NSMutableData* m_receivedDataBuffer;
    NSURLSession* m_connection;
    NSFileHandle* m_fileHandle;
    
    KCFile* m_filePath;
    
    // Speed rate and remaining time
    NSTimer* m_speedTimer;
    NSMutableArray* m_samplesOfDownloadedBytes;
    uint64_t m_expectedDataLength;
    uint64_t m_receivedDataLength;
    uint64_t m_previousTotal;
}
// Public
@property (nonatomic, strong, readwrite) NSMutableURLRequest *fileRequest;
@property (nonatomic, copy, readwrite) NSURL *downloadURL;
@property (nonatomic, assign, readwrite) KCDownloadState state;

// Speed rate and remaining time
@property (nonatomic, assign, readwrite) NSInteger speedRate;
@property (nonatomic, assign, readwrite) NSInteger remainingTime;
// Blocks
@property (nonatomic, copy) void (^headersResponseBlock)(NSURLResponse *aResponse);
@property (nonatomic, copy) void (^progressBlock)(uint64_t aReceivedLength, uint64_t aTotalLength, NSInteger aRemainingTime, float progress);
@property (nonatomic, copy) void (^errorBlock)(NSError* aError);
@property (nonatomic, copy) void (^completeBlock)(BOOL aDownloadFinished, KCFile* aFilePath);

@end

@implementation KCDownloader
@dynamic remainingTime;
@synthesize filePath = m_filePath;
@synthesize totalLength = m_expectedDataLength;


#pragma mark - Dealloc


- (void)dealloc
{
    [m_speedTimer invalidate];
    KCDealloc(super);
}


#pragma mark - Init


- (instancetype)initWithURL:(NSURL *)aUrl toPath:(KCFile*)aPath delegate:(id<KCDownloaderDelegate>)aDelegate
{
    self = [super init];
    if (self)
    {
        self.downloadURL = aUrl;
        self.delegate = aDelegate;
        m_filePath = aPath;
        self.state = KCDownloadStateReady;
        self.fileRequest = [NSMutableURLRequest requestWithURL:self.downloadURL
                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                               timeoutInterval:kDefaultRequestTimeout];
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)aUrl
               toPath:(KCFile*)aPath
            headers:(void (^)(NSURLResponse* aResponse))headersResponseBlock
                   progress:(void (^)(uint64_t aReceivedLength, uint64_t aTotalLength, NSInteger aRemainingTime, float aProgress))aProgressBlock
                      error:(void (^)(NSError* aError))aErrorBlock
                   complete:(void (^)(BOOL aDownloadFinished, KCFile*aFilePath))aCompleteBlock
{
    self = [self initWithURL:aUrl toPath:aPath delegate:nil];
    if (self)
    {
        self.headersResponseBlock = headersResponseBlock;
        self.progressBlock = aProgressBlock;
        self.errorBlock = aErrorBlock;
        self.completeBlock = aCompleteBlock;
    }
    return self;
}


#pragma mark - NSOperation Override


- (void)start
{
    if ([self isCancelled])
    {
        return;
    }
    
    // If we can't handle the request, better cancelling the operation right now
    if (![NSURLConnection canHandleRequest:self.fileRequest])
    {
        NSError *error = [NSError errorWithDomain:KCDownloadErrorDomain
                                             code:KCDownloadErrorInvalidURL
                                         userInfo:@{ NSLocalizedDescriptionKey:
                                        [NSString stringWithFormat:@"Invalid URL provided: %@", self.fileRequest.URL] }];

        [self notifyFromCompletionWithError:error filePath:nil];
        return;
    }

    NSFileManager *fm = [NSFileManager defaultManager];

    // Create download directory
    NSError *createDirError = nil;
    if (![fm createDirectoryAtPath:[m_filePath getParent] withIntermediateDirectories:YES attributes:nil error:&createDirError])
    {
        [self notifyFromCompletionWithError:createDirError filePath:nil];
        return;
    }
    
    // Test if file already exists (partly downloaded) to set HTTP `bytes` header or not
    if (![fm fileExistsAtPath:m_filePath.getPath])
    {
        [fm createFileAtPath:m_filePath.getPath contents:nil attributes:nil];
        
//        int fileDescriptor = open([m_filePath.getPath UTF8String], O_CREAT | O_EXCL | O_RDWR, 0666);
//        if (fileDescriptor > 0)
//        {
//            close(fileDescriptor);
//        }

    }
    else
    {
        uint64_t fileSize = [[fm attributesOfItemAtPath:m_filePath.getPath error:nil] fileSize];
        NSString *range = [NSString stringWithFormat:@"bytes=%lld-", fileSize];
        [self.fileRequest setValue:range forHTTPHeaderField:@"Range"];
        // Allow progress to reflect what's already downloaded
        m_receivedDataLength += fileSize;
    }

    // Initialization of everything we'll need to download the file
    m_fileHandle = [NSFileHandle fileHandleForWritingAtPath:m_filePath.getPath];
    m_receivedDataBuffer = [[NSMutableData alloc] init];
    m_samplesOfDownloadedBytes = [[NSMutableArray alloc] init];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    m_connection = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:queue];
    
    if (m_connection && ![self isCancelled])
    {
        [self willChangeValueForKey:@"isExecuting"];
        self.state = KCDownloadStateDownloading;
        [self didChangeValueForKey:@"isExecuting"];
        
        [m_fileHandle seekToEndOfFile];
        
        // Start the download
        NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
        NSURLSessionDataTask *dataTask = [m_connection dataTaskWithRequest:self.fileRequest];
        [dataTask resume];
        

        // Start the speed timer to schedule speed download on a periodic basis
        m_speedTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(updateTransferRate)
                                                         userInfo:nil
                                                          repeats:YES];
        [runLoop addTimer:m_speedTimer forMode:NSRunLoopCommonModes];
        [runLoop run];
    }
}

- (BOOL)isExecuting
{
    return self.state == KCDownloadStateDownloading;
}

- (BOOL)isCancelled
{
    return self.state == KCDownloadStateCancelled;
}

- (BOOL)isFinished
{
    return self.state == KCDownloadStateCancelled || self.state == KCDownloadStateDone || self.state == KCDownloadStateFailed;
}


- (void)clearReceivedDataBuffer
{
    if (m_receivedDataBuffer)
    {
        [m_receivedDataBuffer resetBytesInRange:NSMakeRange(0, [m_receivedDataBuffer length])];
        [m_receivedDataBuffer setLength:0];
    }
}


#pragma mark delegate

#pragma mark -- NSURLSessionDelegate
/* The last message a session delegate receives.  A session will only become
 * invalid because of a systemic error or when it has been
 * explicitly invalidated, in which case the error parameter will be nil.
 */
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error
{
    KCLog(@"didBecomeInvalidWithError");
}


#pragma mark -- NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
//    KCLog(@"%@", response);
    
    // If anything was previousy downloaded, add it to the total expected length for the progress property
    m_expectedDataLength = m_receivedDataLength + [response expectedContentLength];
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSError *error;
    NSInteger statusCode = httpResponse.statusCode;
    if (statusCode >= 400)
    {
        error = [NSError errorWithDomain:KCDownloadErrorDomain
                                    code:KCDownloadErrorHTTPError
                                userInfo:@{ NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Erroneous HTTP status code %ld (%@)",
                                                                       (long) httpResponse.statusCode,
                                                                       [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]],
                                            KCDownloadErrorHTTPStatusKey: @(httpResponse.statusCode) }];
    }
    
    long long expected = @(m_expectedDataLength).longLongValue;
    if ([KCDownloader freeDiskSpace].longLongValue < expected && expected != -1)
    {
        error = [NSError errorWithDomain:KCDownloadErrorDomain
                                    code:KCDownloadErrorNotEnoughFreeDiskSpace
                                userInfo:@{ NSLocalizedDescriptionKey:@"Not enough free disk space" }];
    }
    
    if (!error)
    {
        
        [self clearReceivedDataBuffer];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.headersResponseBlock)
            {
                self.headersResponseBlock(response);
            }
            if ([self.delegate respondsToSelector:@selector(onDownload:didReceiveHeaders:)])
            {
                [self.delegate onDownload:self didReceiveHeaders:response];
            }
        });
    }
    else
    {
        [self notifyFromCompletionWithError:error filePath:m_filePath];
    }
    
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
  
         [m_receivedDataBuffer appendData:data];
          m_receivedDataLength += [data length];
            
        //    KCLog(@"%@ | %.2f%% - Received: %ld - Total: %ld",
        //          m_filePath.getPath,
        //          (float) m_receivedDataLength / m_expectedDataLength * 100,
        //          (long) m_receivedDataLength, (long) m_expectedDataLength);
            
            if (m_receivedDataBuffer.length > kBufferSize && [self isExecuting])
            {
                @try
                {
                      [m_fileHandle writeData:m_receivedDataBuffer];
                      [self clearReceivedDataBuffer];
                }
                @catch (NSException *exception)
                {
                        
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.progressBlock)
                {
                    self.progressBlock(m_receivedDataLength, m_expectedDataLength, self.remainingTime, self.progress);
                }
                if ([self.delegate respondsToSelector:@selector(onDownload:didReceiveData:totalLength:progress:)])
                {
                    [self.delegate onDownload:self
                               didReceiveData:m_receivedDataLength
                                  totalLength:m_expectedDataLength
                                     progress:self.progress];
                }
            });
   
}

#pragma mark -- NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error
{
    if (error == nil)
    {
        if ([self isExecuting])
        {
            @try
            {
                [m_fileHandle writeData:m_receivedDataBuffer];
            }
            @catch (NSException *exception)
            {
                
            }
            [self clearReceivedDataBuffer];
            
            [self notifyFromCompletionWithError:nil filePath:m_filePath];
        }
        
    }
    else
    {
        [self notifyFromCompletionWithError:error filePath:m_filePath];
    }
}

#pragma mark - Public Methods

- (void)cancelAndRemoveFile:(BOOL)aIsRemove
{
    // Cancel the connection before deleting the file
    if (m_connection)
    {
        [m_connection invalidateAndCancel];
        m_connection = nil;
    }
    
    if (aIsRemove)
    {
        NSError *error;
        if (![self removeFileWithError:&error])
        {
            [self notifyFromCompletionWithError:error filePath:nil];
            return;
        }
    }
    
    [self cancel];
}

- (void)addDependentDownload:(KCDownloader *)aDownload
{
    [self addDependency:aDownload];
}


#pragma mark - Internal Methods


- (void)finishOperationWithState:(KCDownloadState)state
{    
    // Cancel the connection in case cancel was called directly
    if (m_connection)
    {
        [m_connection invalidateAndCancel];
        m_connection = nil;
    }
    [m_speedTimer invalidate];
    [m_fileHandle closeFile];
    
    // Let's finish the operation once and for all
    if ([self isExecuting])
    {
        [self willChangeValueForKey:@"isFinished"];
        [self willChangeValueForKey:@"isExecuting"];
        self.state = state;
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];
    }
    else
    {
        [self willChangeValueForKey:@"isExecuting"];
        self.state = state;
        [self didChangeValueForKey:@"isExecuting"];
    }
}

- (void)cancel
{
    [self willChangeValueForKey:@"isCancelled"];
    [self finishOperationWithState:KCDownloadStateCancelled];
    [self didChangeValueForKey:@"isCancelled"];
}

- (void)notifyFromCompletionWithError:(NSError *)error filePath:(KCFile*)aFilePath
{
    BOOL success = error == nil;
    
    // Notify from error if any
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.errorBlock)
            {
                self.errorBlock(error);
            }
            if ([self.delegate respondsToSelector:@selector(onDownload:didError:)])
            {
                [self.delegate onDownload:self didError:error];
            }
        });
    }

    // Notify from completion if the operation
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.completeBlock)
        {
            self.completeBlock(success, aFilePath);
        }
        if ([self.delegate respondsToSelector:@selector(onDownload:didComplete:path:)])
        {
            [self.delegate onDownload:self didComplete:success path:aFilePath];
        }
    });
    
    // Finish the operation
    KCDownloadState finalState = success ? KCDownloadStateDone : KCDownloadStateFailed;
    [self finishOperationWithState:finalState];
}

- (void)updateTransferRate
{
    if (m_samplesOfDownloadedBytes.count > kNumberOfSamples)
    {
        [m_samplesOfDownloadedBytes removeObjectAtIndex:0];
    }

    // Add the sample
    [m_samplesOfDownloadedBytes addObject:[NSNumber numberWithUnsignedLongLong:m_receivedDataLength - m_previousTotal]];
    m_previousTotal = m_receivedDataLength;
    // Compute the speed rate on the average of the last seconds samples
    self.speedRate = [[m_samplesOfDownloadedBytes valueForKeyPath:@"@avg.longValue"] longValue];
    
//    NSLog(@"speedRate:%d", self.speedRate);
}

- (BOOL)removeFileWithError:(NSError *__autoreleasing *)error
{
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:m_filePath.getPath])
    {
        return [fm removeItemAtPath:m_filePath.getPath error:error];
    }
    
    return YES;
}

+ (NSNumber *)freeDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemFreeSize];
}


#pragma mark - Custom Getters

- (NSInteger)remainingTime
{
    return self.speedRate > 0 ? ((NSInteger) (m_expectedDataLength - m_receivedDataLength) / self.speedRate) : -1;
}

- (float)progress
{
    return (m_expectedDataLength == 0) ? 0 : (float)m_receivedDataLength / (float) m_expectedDataLength;
}

@end
