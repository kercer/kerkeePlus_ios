//
//  KCDownloadEngine.h
//  kerkeePlus
//
//  Created by zihong on 16/6/27.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KCDownloader;
@class KCFile;
@protocol KCDownloaderDelegate;


@interface KCDownloadEngine : NSObject

+ (instancetype)defaultDownloadEngine;
- (KCDownloader*)startDownloadWithURL:(NSURL*)aUrl;
- (KCDownloader*)startDownloadWithURL:(NSURL*)aUrl toPath:(KCFile*)aToPath;
- (KCDownloader*)startDownloadWithURL:(NSURL*)aUrl toPath:(KCFile*)aToPath delegate:(id<KCDownloaderDelegate>)aDelegate;
- (KCDownloader*)startDownloadWithURL:(NSURL*)aUrl
                            toPath:(KCFile*)aToPath
                         headers:(void (^)(NSURLResponse* aResponse))aHeadersResponseBlock
                              progress:(void (^)(uint64_t aReceivedLength, uint64_t aTotalLength, NSInteger aRemainingTime, float aProgress))aProgressBlock
                                     error:(void (^)(NSError *aError))aErrorBlock
                                  complete:(void (^)(BOOL aIsComplete, KCFile* aFilePath))aCompleteBlock;

- (void)startDownload:(KCDownloader*)aDownload;

- (void)setQueueName:(NSString*)aName;

/**
 Specifies the default download path. (which is `/tmp` by default)
 The path can be non existant, if so, it will be created.
*/
- (BOOL)setDefaultDownloadPath:(KCFile*)aDirPath error:(NSError *__autoreleasing *)aError;

/**
 Set the maximum number of concurrent downloads allowed. If more downloads are passed to the `KCDownloadEngine` singleton, they will wait for an older one to end before starting.
*/
- (void)setMaxConcurrentDownloads:(NSInteger)aMax;

/**
 Cancels all downloads. Remove already downloaded parts of the files from the disk is asked.
*/
- (void)cancelAllDownloadsIsRemoveFiles:(BOOL)aIsRemove;

#pragma mark - property
@property (nonatomic, copy) KCFile* defaultDownloadDir;

/**
 The number of downloads currently in the queue
 */
@property (nonatomic, assign) NSUInteger downloadCount;

/**
 The number of downloads currently being executed by the queue (currently downloading data).
 */
@property (nonatomic, assign) NSUInteger currentDownloadsCount;

@end
