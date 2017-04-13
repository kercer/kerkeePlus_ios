//
//  KCDownloader.h
//  kerkeePlus
//
//  Created by zihong on 16/6/27.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KCDownloaderDelegate.h"

@class KCFile;

/**
 When a download fails because of an HTTP error, the HTTP status code is transmitted as an `NSNumber` via the provided `NSError` parameter of the corresponding block or delegate method. Access to `error.userInfo[KCDownloadErrorHTTPStatusKey]`
 */
extern NSString * const KCDownloadErrorHTTPStatusKey;

/**
 KCDownload specific errors
*/
extern NSString * const KCDownloadErrorDomain;

/**
 The possible error codes for a `KCDownloader` operation. When an error block or the corresponding delegate method are called, an `NSError` instance is passed as parameter. If the domain of this `NSError` is KCDownload's, the `code` parameter will be set to one of these values.
 
 */
typedef NS_ENUM(NSUInteger, KCDownloadError)
{
    //`NSURLConnection` was unable to handle the provided request.
    KCDownloadErrorInvalidURL = 0,
    //The connection encountered an HTTP error.
    KCDownloadErrorHTTPError,
    //The device has not enough free disk space to download the file.
    KCDownloadErrorNotEnoughFreeDiskSpace
};


typedef NS_ENUM(NSUInteger, KCDownloadState) {
    //The download is instanciated but has not been started yet.
    KCDownloadStateReady = 0,
    //The download has started the HTTP connection to retrieve the file.
    KCDownloadStateDownloading,
    //The download has been completed successfully.
    KCDownloadStateDone,
    //The download has been cancelled manually.
    KCDownloadStateCancelled,
    //The download failed, probably because of an error. It is possible to access the error in the appropriate delegate method or block property.
    KCDownloadStateFailed
};

@protocol KCDownloaderDelegate;


#pragma mark - KCDownloader

@interface KCDownloader : NSOperation <NSURLConnectionDelegate>

/**
 The delegate property of a `KCDownloader` instance. Can be `nil`.
 */
@property (nonatomic, unsafe_unretained) id<KCDownloaderDelegate> delegate;

/**
 The file path where the file is being downloaded.
 */
@property (nonatomic, copy, readonly) KCFile* filePath;

/**
 The URL of the file to download.
 @warning You should not set this property directly, as it is managed by the initialization method.
 */
@property (nonatomic, copy, readonly) NSURL* downloadURL;

/**
 The NSMutableURLRequest that will be performed by the NSURLConnection. Use this object to pass custom headers to your request if needed.
 */
@property (nonatomic, strong, readonly) NSMutableURLRequest *fileRequest;

@property (nonatomic, assign, readonly) unsigned long long totalLength;

/**
 The current speed of the download in bits/sec. This property updates itself regularly so you can retrieve it on a regular interval to update your UI.
 */
@property (nonatomic, assign, readonly) NSInteger speedRate;

/**
 The estimated number of seconds before the download completes.
 `-1` if the remaining time has not been calculated yet.
 */
@property (nonatomic, assign, readonly, getter = remainingTime) NSInteger remainingTime;

/**
 Current progress of the download.
 */
@property (nonatomic, assign, readonly, getter = progress) float progress;

/**
 Current state of the download.
 */
@property (nonatomic, assign, readonly) KCDownloadState state;


- (instancetype)initWithURL:(NSURL *)aUrl toPath:(KCFile*)aPath delegate:(id<KCDownloaderDelegate>)aDelegate;

- (instancetype)initWithURL:(NSURL *)aUrl toPath:(KCFile*)aPath
              headers:(void (^)(NSURLResponse* aResponse))headersResponseBlock
                   progress:(void (^)(uint64_t aReceivedLength, uint64_t aTotalLength, NSInteger aRemainingTime, float aProgress))aProgressBlock
                      error:(void (^)(NSError* aError))aErrorBlock
                   complete:(void (^)(BOOL aDownloadFinished, KCFile* aFilePath))aCompleteBlock;

/**
 Cancels the download. Remove already downloaded parts of the file from the disk is asked.
 */
- (void)cancelAndRemoveFile:(BOOL)aIsRemove;

/**
 Makes the receiver download dependent of the given download. The receiver download will not execute itself until the given download has finished.
 @param download  The KCDownloader on which to depend.
 */
- (void)addDependentDownload:(KCDownloader *)aDownload;

@end




