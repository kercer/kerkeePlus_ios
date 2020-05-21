//
//  KCDownloadEngine.m
//  kerkeePlus
//
//  Created by zihong on 16/6/27.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import "KCDownloadEngine.h"
#import "KCDownloader.h"
#import <kerkee/KCFile.h>
#import <kerkee/KCBaseDefine.h>

@interface KCDownloadEngine ()
{
    KCFile* m_defaultDownloadDir;
}
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@end

@implementation KCDownloadEngine
@synthesize defaultDownloadDir = m_defaultDownloadDir;
@dynamic downloadCount;
@dynamic currentDownloadsCount;


#pragma mark - Init


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.operationQueue = [[NSOperationQueue alloc] init];
        m_defaultDownloadDir = [[KCFile alloc] initWithPath:[NSString stringWithString:NSTemporaryDirectory()]];
    }
    return self;
}


- (void)dealloc
{
    KCRelease(m_defaultDownloadDir);
    m_defaultDownloadDir = nil;
    KCDealloc(super);
}

+ (instancetype)defaultDownloadEngine
{
    static dispatch_once_t onceToken;
    static id sharedManager = nil;
    dispatch_once(&onceToken, ^{
        sharedManager = [[[self class] alloc] init];
        [sharedManager setQueueName:@"KCDownloadEngine_DefaultDownloadEngine_Queue"];
    });
    return sharedManager;
}


#pragma mark - KCDownloader Management

- (KCDownloader*)startDownloadWithURL:(NSURL*)aUrl
{
    return [self startDownloadWithURL:aUrl toPath:nil];
}
- (KCDownloader*)startDownloadWithURL:(NSURL*)aUrl toPath:(KCFile*)aToPath
{
    return [self startDownloadWithURL:aUrl toPath:aToPath delegate:nil];
}

- (KCDownloader*)startDownloadWithURL:(NSURL*)aUrl toPath:(KCFile*)aToPath delegate:(id<KCDownloaderDelegate>)aDelegate
{
    NSString* downloadPath = aToPath ? aToPath.getAbsolutePath : [m_defaultDownloadDir.getAbsolutePath stringByAppendingPathComponent:[[NSURL URLWithString:[aUrl absoluteString]] lastPathComponent]];

    KCDownloader* downloader = [[KCDownloader alloc] initWithURL:aUrl
                                                            toPath:[[KCFile alloc] initWithPath:downloadPath]
                                                                delegate:aDelegate];
    [self.operationQueue addOperation:downloader];

    return downloader;
}

- (KCDownloader*)startDownloadWithURL:(NSURL *)aUrl
                            toPath:(KCFile*)aToPath
                       headers:(void (^)(NSURLResponse* aResponse))aHeadersResponseBlock
                              progress:(void (^)(uint64_t aReceivedLength, uint64_t aTotalLength, NSInteger aRemainingTime, float aProgress))aProgressBlock
                                 error:(void (^)(NSError *aError))aErrorBlock
                              complete:(void (^)(BOOL aIsComplete, KCFile* aFilePath))aCompleteBlock
{
    NSString *downloadPath = aToPath ? aToPath.getAbsolutePath : [m_defaultDownloadDir.getAbsolutePath stringByAppendingPathComponent:[[NSURL URLWithString:[aUrl absoluteString]] lastPathComponent]];

    KCDownloader *downloader = [[KCDownloader alloc] initWithURL:aUrl
                                                            toPath:[[KCFile alloc] initWithPath:downloadPath]
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

- (BOOL)setDefaultDownloadPath:(KCFile*)aDirPath error:(NSError *__autoreleasing *)aError
{
    if (aDirPath && aDirPath.mkdirs)
    {
        m_defaultDownloadDir = aDirPath;
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
