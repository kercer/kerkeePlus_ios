//
//  KCDownloadEngine.m
//  kerkeePlus
//
//  Created by zihong on 16/6/27.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import "KCDownloadEngine.h"
#import "KCDownloader.h"

@interface KCDownloadEngine ()
{
    NSString* m_defaultDownloadDirPath;
}
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@end

@implementation KCDownloadEngine
@synthesize defaultDownloadDirPath = m_defaultDownloadDirPath;
@dynamic downloadCount;
@dynamic currentDownloadsCount;


#pragma mark - Init


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.defaultDownloadDirPath = [NSString stringWithString:NSTemporaryDirectory()];
    }
    return self;
}

+ (instancetype)defaultDownloadEngine
{
    static dispatch_once_t onceToken;
    static id sharedManager = nil;
    dispatch_once(&onceToken, ^{
        sharedManager = [[[self class] alloc] init];
        [sharedManager setQueueName:@"KCDownloadManager_SharedInstance_Queue"];
    });
    return sharedManager;
}


#pragma mark - KCDownloader Management


- (KCDownloader *)startDownloadWithURL:(NSURL *)aUrl toPath:(NSString *)aToPath delegate:(id<KCDownloaderDelegate>)aDelegate
{
    NSString *downloadPath = aToPath ? aToPath : [self.defaultDownloadDirPath stringByAppendingPathComponent:[[NSURL URLWithString:[aUrl absoluteString]] lastPathComponent]];

    KCDownloader *downloader = [[KCDownloader alloc] initWithURL:aUrl
                                                            toPath:downloadPath
                                                                delegate:aDelegate];
    [self.operationQueue addOperation:downloader];

    return downloader;
}

- (KCDownloader *)startDownloadWithURL:(NSURL *)aUrl
                            toPath:(NSString*)aToPath
                       headers:(void (^)(NSURLResponse* aResponse))aHeadersResponseBlock
                              progress:(void (^)(uint64_t aReceivedLength, uint64_t aTotalLength, NSInteger aRemainingTime, float aProgress))aProgressBlock
                                 error:(void (^)(NSError *aError))aErrorBlock
                              complete:(void (^)(BOOL aIsComplete, NSString *aFilePath))aCompleteBlock
{
    NSString *downloadPath = aToPath ? aToPath : [self.defaultDownloadDirPath stringByAppendingPathComponent:[[NSURL URLWithString:[aUrl absoluteString]] lastPathComponent]];

    KCDownloader *downloader = [[KCDownloader alloc] initWithURL:aUrl
                                                            toPath:downloadPath
                                                           headers:aHeadersResponseBlock
                                                                progress:aProgressBlock
                                                                   error:aErrorBlock
                                                                complete:aCompleteBlock];
    [self.operationQueue addOperation:downloader];

    return downloader;
}

- (void)startDownload:(KCDownloader*)aDownload
{
    [self.operationQueue addOperation:aDownload];
}

- (void)cancelAllDownloadsIsRemoveFiles:(BOOL)aIsRemove
{
    for (KCDownloader *blob in [self.operationQueue operations])
    {
        [blob cancelAndRemoveFile:aIsRemove];
    }
}


#pragma mark - Custom Setters


- (void)setQueueName:(NSString*)aName
{
    [self.operationQueue setName:aName];
}

- (BOOL)setDefaultDownloadPath:(NSString *)aDirPath error:(NSError *__autoreleasing *)aError
{
    if ([[NSFileManager defaultManager] createDirectoryAtPath:aDirPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:aError])
    {
        m_defaultDownloadDirPath = aDirPath;
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)setMaxConcurrentDownloads:(NSInteger)aMax
{
    [self.operationQueue setMaxConcurrentOperationCount:aMax];
}


#pragma mark - Custom Getters


- (NSUInteger)downloadCount
{
    return [self.operationQueue operationCount];
}

- (NSUInteger)currentDownloadsCount
{
    NSUInteger count = 0;
    for (KCDownloader *blob in [self.operationQueue operations])
    {
        if (blob.state == KCDownloadStateDownloading)
        {
            count++;
        }
    }

    return count;
}

@end
