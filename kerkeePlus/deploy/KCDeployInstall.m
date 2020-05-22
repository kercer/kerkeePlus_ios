//
//  KCDeployInstall.m
//  kerkeePlus
//
//  Created by zihong on 16/6/17.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import "KCDeployInstall.h"
#import "KCDek.h"
#import "KCWebApp.h"
#import <kerkee/KCTaskQueue.h>
#import <kerkee/KCFetchManifest.h>
#import <kerkee/KCMainBundle.h>
#import "KCUtilVersion.h"
#import <kerkee/KCBaseDefine.h>
#import <kerkee/KCString.h>
#import "KCDownloadEngine.h"
#import <kerkee/KCURI.h>
#import <kerkee/KCFile.h>

#define kDekFileName @"tmp.dek"


@interface KCDek ()
{
}
- (void)setManifestFileName:(NSString*)aFileName;
- (void)setManifestObject:(KCManifestObject*)aManifestObject;
- (void)setManifestUri:(KCURI*)aUri;
- (void)setRootPath:(KCFile*)aRootPath;
- (void)setWebApp:(KCWebApp*)aWebApp;
- (void)setIsFromAssert:(BOOL)aIsFromAssert;
- (KCManifestObject*)loadLocalManifest;

@end


@interface KCDeployInstall ()
{
    NSString* m_manifestFileName;
    KCDeploy* m_deploy;
}

@end

@implementation KCDeployInstall
@synthesize mManifestFileName = m_manifestFileName;


- (instancetype)initWithDeploy:(KCDeploy*)aDeploy
{
    if (self = [super init])
    {
        m_manifestFileName = kDefaultManifestName;
        m_deploy = aDeploy;
    }
    return self;
}

- (void)installWebApps:(NSArray*)aWebApps
{
    NSUInteger count = aWebApps.count;
    for (int i = 0; i<count; ++i)
    {
        KCWebApp* webapp = [aWebApps objectAtIndex:i];
        [self installWebApp:webapp];
    }
}

- (void)installWebApp:(KCWebApp*)aWebApp
{
    if (!aWebApp) return;
    
    BACKGROUND_GLOBAL_BEGIN(PRIORITY_DEFAULT)
    
    [KCFetchManifest fetchServerManifests:aWebApp.mManifestURI block:^(KCManifestObject *aManifestObject) {
        if (aManifestObject)
        {
            KCURI* urlManifest = [aManifestObject manifestURI];
            KCManifestObject* serverManifestObject = aManifestObject;
            NSString* relativeDir =[serverManifestObject.mRelativePath kc_substring:0 end:[serverManifestObject.mRelativePath kc_lastIndexOfChar:KCFile.separatorChar]];
            KCFile* rootPath = [[KCFile alloc] initWithPath:[NSString stringWithFormat:@"%@%c%@",aWebApp.mRootPath, KCFile.separatorChar, relativeDir]];
            KCDek* dek = [[KCDek alloc] initWithRootPath:rootPath];
            [dek setManifestObject:serverManifestObject];
            [dek setManifestUri:urlManifest];
            [dek setWebApp:aWebApp];
            [dek setManifestFileName:m_manifestFileName];
            [self downloadDEK:dek];
            
        }
    }];
    
    BACKGROUND_GLOBAL_COMMIT
}


- (void)downloadDEK:(KCDek*)aDek
{
    if ([self canInstall:aDek])
    {
        NSString* downloadDir = aDek.mRootPath.getAbsolutePath;
        int IndexOfChar = [downloadDir kc_lastIndexOfChar:KCFile.separatorChar];
        downloadDir = [downloadDir kc_substring:0 end:IndexOfChar];
        KCFile* dekFile = [[KCFile alloc] initWithPath:[NSString stringWithFormat:@"%@%@%@", downloadDir, KCFile.separator, kDekFileName]];
        KCAutorelease(dekFile);
        
        if (dekFile.exists)
            [dekFile remove];
        
        NSURL* url = [NSURL URLWithString:aDek.mManifestObject.mDownloadUrl];
        
        [KCDownloadEngine.defaultDownloadEngine startDownloadWithURL:url toPath:dekFile
        headers:^(NSURLResponse *aResponse)
        {
        }
        progress:^(uint64_t aReceivedLength, uint64_t aTotalLength, NSInteger aRemainingTime, float aProgress)
        {
        }
        error:^(NSError *aError)
        {
            if (m_deploy.mDeployFlow && [m_deploy.mDeployFlow respondsToSelector:@selector(onDeployError:dek:)])
                [m_deploy.mDeployFlow onDeployError:(KCDeployError*)aError dek:aDek];
        }
        complete:^(BOOL aIsComplete, KCFile *aFilePath)
        {
            //if succes deploy
            [m_deploy deploy:dekFile dek:aDek];
        }];
    }
}

- (BOOL)canInstall:(KCDek*)aDek
{
    BOOL canInstall = true;
    NSString* curLocalDekVersion = nil;
    KCManifestObject* manifestObject = [aDek loadLocalManifest];
    if (manifestObject)
        curLocalDekVersion = manifestObject.mVersion;
    if (curLocalDekVersion && curLocalDekVersion.length > 0)
    {
        NSString* curAppVersion = [KCMainBundle getVersionName];
        int dekCompare = [KCUtilVersion compareVersion:curLocalDekVersion version2:aDek.mManifestObject.mVersion];
        int apkCompare = [KCUtilVersion compareVersion:curAppVersion  version2:aDek.mManifestObject.mRequiredVersion];
        if (dekCompare < 0 && apkCompare >= 0)
        {
            KCLog(@"remote dek need update");
            canInstall = true;
        }
        else
        {
            KCLog("remote dek do not need update");
            canInstall = false;
        }
    }
    
    return canInstall;
}

- (void)setManifestFileName:(NSString*)aManifestFileName
{
    m_manifestFileName = aManifestFileName;
}

@end
