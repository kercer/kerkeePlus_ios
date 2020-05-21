//
//  GUpgradeDek.m
//  GlobalScanner
//
//  Created by tangjun on 2019/12/9.
//  Copyright © 2019 xiaojian. All rights reserved.
//

#import "GUpgradeDek.h"
#import <kerkee/KCManifestObject.h>
#import <kerkee/KCMainBundle.h>
#import <kerkee/KCFile.h>
#import <kerkee/KCFetchManifest.h>
#import <kerkee/KCFileManager.h>
@implementation GUpgradeDek

/**
 * 当前版本与remote版本比较
 */
+ (BOOL)dekNeedUpdate:(KCManifestObject *)aManifestObject compare:(KCManifestObject *)bManifestObject
{
    NSString *appVersion= [KCMainBundle getVersionName];
    if (!aManifestObject.mVersion || !aManifestObject.mRequiredVersion)
    {
        return NO;
    }
    if(!bManifestObject.mVersion)
    {
        return YES;
    }
    int dekCompare = compare_version_manifest(aManifestObject.mVersion, bManifestObject.mVersion);
    int appCompare= compare_version_manifest(appVersion ,aManifestObject.mRequiredVersion);
    if (dekCompare > 0 && appCompare >= 0)
    {
        return YES;
        //当前iOS版本大于5.0.1
    }
    
    return NO;
}

/**
 * 比较版本号
 *
 * @param version1 第一个版本号
 * @param version2 第二个版本号
 *
 * @return 如果版本号相等，返回 0,
 *         如果第一个版本号低于第二个，返回 -1，否则返回 1.
 */
int compare_version_manifest(NSString *version1, NSString *version2)
{
    // 获取各个版本号对应版本信息
    NSMutableArray *verArr1 = [NSMutableArray arrayWithArray:[version1 componentsSeparatedByString:@"."]];
    NSMutableArray *verArr2 = [NSMutableArray arrayWithArray:[version2 componentsSeparatedByString:@"."]];
    
    // 补全版本信息为相同位数
    while (verArr1.count < verArr2.count) {
        [verArr1 addObject:@"0"];
    }
    while (verArr2.count < verArr1.count) {
        [verArr2 addObject:@"0"];
    }
    
    // 遍历每一个版本信息中的位数
    // 记录比较结果值
    int result = 0;
    for (int i = 0; i < verArr1.count; i++) {
        NSInteger versionNumber1 = [verArr1[i] integerValue];
        NSInteger versionNumber2 = [verArr2[i] integerValue];
        if (versionNumber1 < versionNumber2) {
            result = -1;
            break;
        }
        else if (versionNumber2 < versionNumber1){
            result = 1;
            break;
        }
    }
    return result;
}

#pragma mark 获取本地ManifestObject
+ (KCManifestObject *)fetchLocalManifestObject:(NSString *)path
{
    KCManifestObject *bManifestObject = nil;
    if (path)
    {
        path = [NSString stringWithFormat:@"%@/%@",path,@"cache.manifest"];
        bManifestObject = [KCFetchManifest fetchOneLocalManifest:[KCURI parse:path]];
    }
    return bManifestObject;
}

+ (NSURLSession *)session
{
    static NSURLSession *session;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    });
    
    return session;
}

+ (void)fetchData:(NSURL *)aUrl finishedBlock:(void(^)(NSData *data))block
{
    NSURLRequest *request = [NSURLRequest requestWithURL:aUrl];
    NSURLSession *session = [self session];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          if (!error && block)
                                          {
                                              block(data);
                                          }
                                          else if(block){
                                              block(nil);
                                          }
                                      }];
    [dataTask resume];
}

+ (void)_readFileText:(NSString *)aPath block:(void(^)(NSString *str))aBlock
{
    if ([aPath hasPrefix:@"http"])
    {
        [self fetchData:[NSURL URLWithString:aPath] finishedBlock:^(NSData *data) {
            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (aBlock)
            {
                aBlock(dataString);
            }
        }];
    }
    else
    {
        KCFile* webappsJsonPath = [[KCFile alloc] initWithPath:aPath];
        if (aBlock)
        {
            NSString *content = [KCFileManager readFileAsString:webappsJsonPath.getAbsolutePath];
            aBlock(content);
        }
    }
}

@end
