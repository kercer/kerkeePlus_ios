//
//  KCDownloaderDelegate.h
//  kerkeePlus
//
//  Created by zihong on 16/6/27.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KCDownloader;
@class KCFile;

#pragma mark - KCDownloader Delegate

@protocol KCDownloaderDelegate <NSObject>
@optional

/**
 Fetch Headers
 */
- (void)onDownload:(KCDownloader *)aDownloader didReceiveHeaders:(NSURLResponse *)aResponse;

/**
 Called on each response from the server while the download is occurring.
 */
- (void)onDownload:(KCDownloader *)aDownloader  didReceiveData:(uint64_t)aReceivedLength totalLength:(uint64_t)aTotalLength
        progress:(float)aProgress;

/**
 Called when an error occur during the download. If this method is called, the `KCDownloader` will be automatically cancelled just after, without deleting the the already downloaded parts of the file. This is done by calling `cancelDownloadAndRemoveFile:`
 */
- (void)onDownload:(KCDownloader *)aDownloader didError:(NSError *)error;

/**
 Called when the download is finished or when the operation has been cancelled. The `KCDownloader` operation will be removed from `KCDownloadManager` just after this method is called.
 */
- (void)onDownload:(KCDownloader *)aDownloader didComplete:(BOOL)aIsComplete path:(KCFile*)aFilePath;

@end
