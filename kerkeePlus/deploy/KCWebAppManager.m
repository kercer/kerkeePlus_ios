//
//  KCWebAppManager.m
//  kerkeePlus
//
//  Created by zihong on 16/6/17.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import "KCWebAppManager.h"
#import "KCDeploy.h"
#import "KCDeployAssert.h"
#import "KCDeployInstall.h"
#import <kerdb/KerDB.h>
#import <kerdb/KCDB.h>
#import <kerdb/KCSnapshot.h>
#import <kerdb/KCIterator.h>
#import <kerkee/KCFileManager.h>
#import <kerkee/KCTaskQueue.h>
#import <kerkee/KCBaseDefine.h>
#import <kerkee/KCMainBundle.h>
#import <kerkee/KCFile.h>
#import "KCWebApp.h"


#define kDBName @"WebappsDB"
@interface KCWebAppManager ()
{
    KCDeploy* m_deploy;
    KCDeployAssert* m_deployAssert;
    KCDeployInstall* m_deployInstall;
    NSMutableDictionary* m_webApps;
    KCDB* m_db;
}

@end

@implementation KCWebAppManager

- (instancetype)init
{
    if (self = [super init])
    {
        m_webApps = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (instancetype)initWithDeployFlow:(id<KCDeployFlow>)aDeployFlow
{
    return [self initWithDeployFlow:aDeployFlow assetFileName:kDefaultAssetFileName];
}
- (instancetype)initWithDeployFlow:(id<KCDeployFlow>)aDeployFlow assetFileName:(NSString*)aAssetFileName
{
    if (self = [super init])
    {
        m_webApps = [[NSMutableDictionary alloc] init];
        [self setup:aAssetFileName deployflow:aDeployFlow];
    }
    return self;
}


- (void)dealloc
{
    KCRelease(m_webApps);
    m_webApps = nil;
    KCRelease(m_deploy);
    m_deploy = nil;
    KCRelease(m_deployInstall);
    m_deployInstall = nil;
    KCRelease(m_deployAssert);
    m_deployAssert = nil;
    if (m_db && [m_db isOpened])
    {
        [m_db close];
    }
    KCRelease(m_db);
    m_db = nil;
}


- (void)setup:(NSString*)aAssetFileName deployflow:(id<KCDeployFlow>)aDeployFlow
{
    @synchronized (self)
    {
        if (!m_deploy) m_deploy = [[KCDeploy alloc] initWithDeployFlow:aDeployFlow];
        if (!m_deployAssert)
        {
            m_deployAssert = [[KCDeployAssert alloc] initWithDeploy:m_deploy];
            m_deployAssert.mAssetFileName = aAssetFileName;
        }
        if (!m_deployInstall) m_deployInstall = [[KCDeployInstall alloc] initWithDeploy:m_deploy];
        
        m_db = [KerDB openWithDBName:kDBName];
        if (m_db)
        {
            [self loadWebAppsFromDB];
        }
        
        //upgrade from Assert if app is first lauch after version changed and local has not html dir
        //don't compare RequiredVersion
        if ([KCMainBundle isFirstLaunchAfterVersionChanged] || ![m_deploy checkHtmlDir])
        {
            [m_deployAssert deployFromAssert];
            [self loadWebappsCfg];
        }
    }
}

- (NSString*)readFileText:(KCFile*)aPath
{
    return [KCFileManager readFileAsString:aPath.getAbsolutePath];
}

- (void)loadWebappsCfg
{
    KCFile* webappsJsonPath = [[KCFile alloc] initWithPath:[m_deploy getResRootPath] name:@"/webapps.json"];
    NSString* str = [self readFileText:webappsJsonPath];
    
    if (str && str.length>0)
    {
        NSDictionary* jsonObject = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        NSArray* jsonWebapps = [jsonObject objectForKey:@"webapps"];
        NSUInteger length = jsonWebapps ? jsonWebapps.count : 0;
        for (int i = 0; i < length; ++i)
        {
            NSDictionary* jsonWebapp = [jsonWebapps objectAtIndex:i];
            NSNumber* nID = [jsonWebapp objectForKey:@"id"];
            NSString* root = [jsonWebapp objectForKey:@"root"];
            NSString* manifestUrl = [jsonWebapp objectForKey:@"manifestUrl"];
            if (!nID || nID.intValue == 0)continue;
            
            KCFile* fileRoot = [[KCFile alloc] initWithPath:m_deploy.getResRootPath];
            if (root && root.length > 0)
            {
                NSString* rootPath = [root stringByReplacingOccurrencesOfString:@"./" withString:@""];
                fileRoot = [[KCFile alloc] initWithFile:fileRoot name:rootPath];
            }
            KCURI* manifestUri = nil;
            if (manifestUrl && manifestUrl.length > 0)
            {
                manifestUri = [KCURI parse:manifestUrl];
            }
            
            KCWebApp* webapp = [[KCWebApp alloc] initWithID:nID.intValue rootPath:fileRoot manifestUri:manifestUri];
            [self addWebApp:webapp];
        }
    }
}

- (void)loadWebAppsFromDB
{
    KCSnapshot* snapshot = [m_db createDBSnapshot];
    KCIterator* iterator = [m_db iteratorDB];
    for ([iterator seekToFirst]; [iterator isValid]; [iterator next])
    {
        KCBytes bytes = [iterator getValue];
        if (bytes.data && bytes.length > 0)
        {
            NSData* dataValue = NSDataFromBytes(bytes);
            KCWebApp* webApp =  [KCWebApp webApp:dataValue];
            [m_webApps setObject:webApp forKey:[NSString stringWithFormat:@"%d", webApp.mID]];
        }
    }
    [iterator close];
    [snapshot close];
}

- (void)updateToDB:(KCWebApp*)aWebApp
{
    if (m_db)
        [m_db putDBObject:aWebApp key:[NSString stringWithFormat:@"%d", aWebApp.mID]];
}
- (void)updateToDBAsyn:(KCWebApp*)aWebApp
{
    BACKGROUND_BEGIN
    [self updateToDB:aWebApp];
    BACKGROUND_COMMIT
}


- (void)addWebApps:(NSArray*)aWebApps
{
    NSUInteger count = aWebApps ? aWebApps.count : 0;
    for (int i = 0; i < count; ++i)
    {
        KCWebApp* webapp = [aWebApps objectAtIndex:i];
        [self addWebApp:webapp];
    }
}

- (BOOL)addWebApp:(KCWebApp*)aWebApp
{
    @synchronized (self)
    {
        if (!aWebApp) return false;
        [m_webApps setObject:aWebApp forKey:[NSString stringWithFormat:@"%d", aWebApp.mID]];
        [self updateToDBAsyn:aWebApp];
        return true;
    }
}

- (void)setManifestFileName:(NSString*)aManifestFileName
{
    if (m_deployInstall)
        m_deployInstall.mManifestFileName = aManifestFileName;
}

- (void)upgradeWebApps:(NSArray*)aWebApps
{
    [m_deployInstall installWebApps:aWebApps];
}

- (void)upgradeWebApp:(KCWebApp*)aWebApp
{
    [m_deployInstall installWebApp:aWebApp];
}

- (NSString*)getRootPath
{
    return [m_deploy getRootPath];
}
- (NSString*)getResRootPath
{
    return [m_deploy getResRootPath];
}

@end
