//
//  GWebAppManager.m
//  GlobalScanner
//
//  Created by tangjun on 2019/12/4.
//  Copyright © 2019 xiaojian. All rights reserved.
//

#import "GWebAppManager.h"
#import "KCDeployFlow.h"
#import "KCDek.h"
#import "KCDeployInstall.h"
#import <kerdb/KerDB.h>
#import <kerdb/KCDB.h>
#import <kerdb/KCSnapshot.h>
#import <kerdb/KCIterator.h>
#import "GWebAppPath.h"
#import "GAssetFlow.h"
#import "GWebApp.h"
#import "GUpgradeDek.h"
#import <kerkee/KCTaskQueue.h>
#import <kerkee/KCFetchManifest.h>
#import <kerkee/KCFileManager.h>
#import <kerkee/KCMemoryCache.h>
#import <objc/runtime.h>
static NSString * const _GWebAppJsonDefaultName = @"webApp.json";
static NSString * const _GWebAppDBName = @"WebappsDb";
static GWebAppId const _GDefaultAppId = @"com.gegejia.zebra.webApp";
static GWebAppManager *_GDefaultWebAppManager = nil;

@interface GWebAppManager (Memory)
@property (nonatomic , strong) NSMutableDictionary<NSString * , KCWebApp *> *webApps;
@property (nonatomic , strong) NSMutableDictionary<NSString * , GWebApp *> *tempwebApps;
@property (nonatomic , strong) KCMemoryCache *memoryCache;
- (void)safe_setWebapp:(KCWebApp *)obj key:(id)key;
- (void)safe_setTempWebapp:(GWebApp *)obj key:(id)key;
- (KCWebApp *)safe_getWebapp:(id)key;
- (GWebApp *)safe_getTempWebapp:(id)key;

@end

@implementation GWebAppManager (Memory)

- (KCMemoryCache *)memoryCache
{
    return objc_getAssociatedObject(self, @selector(memoryCache));
}

- (void)setMemoryCache:(KCMemoryCache *)memoryCache
{
    objc_setAssociatedObject(self, @selector(memoryCache), memoryCache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setWebApps:(NSMutableDictionary<NSString *,KCWebApp *> *)webApps
{
    objc_setAssociatedObject(self, @selector(webApps), webApps, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary<NSString *,KCWebApp *> *)webApps
{
    return objc_getAssociatedObject(self, @selector(webApps));
}

- (NSMutableDictionary<NSString *,GWebApp *> *)tempwebApps
{
    return objc_getAssociatedObject(self, @selector(tempwebApps));
}

- (void)setTempwebApps:(NSMutableDictionary<NSString *,GWebApp *> *)tempwebApps
{
    objc_setAssociatedObject(self, @selector(tempwebApps), tempwebApps, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)safe_setWebapp:(KCWebApp *)obj key:(id)key
{
    if (!obj || !key)
    {
        return;
    }
    [self.webApps setObject:obj forKey:key];
}

- (void)safe_setTempWebapp:(GWebApp *)obj key:(id)key
{
    if (!obj || !key)
    {
        return;
    }
    [self.tempwebApps setObject:obj forKey:key];
}

- (KCWebApp *)safe_getWebapp:(id)key
{
    if (!key)
    {
        return nil;
    }
    return [self.webApps objectForKey:key];
}

- (GWebApp *)safe_getTempWebapp:(id)key
{
    if (!key)
    {
        return nil;
    }
    return [self.tempwebApps objectForKey:key];
}

@end


@interface GWebAppManager ()<KCDeployFlow>
{
    KCDeploy* _deploy;
    GWebAppPath *_webAppPath;
    KCDeployInstall* _deployInstall;
    KCDB* _db;
    GAssetFlow *_assetFlow;
}
@property (nonatomic, weak, readwrite) id<GWebAppDataSource> dataSource;
@property (nonatomic, weak, readwrite) id<GDeployFlow> delegate;

@end



@implementation GWebAppManager


+ (void)setDefaultManager:(GWebAppManager *)webappManager
{
    _GDefaultWebAppManager = webappManager;
}

+ (instancetype)defaultManager
{
    return _GDefaultWebAppManager;
}

- (instancetype)initWithDeployFlow:(id<GDeployFlow>)aDeployFlow dataSource:(id<GWebAppDataSource>)dataSource
{
    if (self = [super init])
    {
        self.webApps = [[NSMutableDictionary alloc] init];
        self.tempwebApps = [[NSMutableDictionary alloc] init];

        self.delegate = aDeployFlow;
        self.dataSource = dataSource;
        [self setup:aDeployFlow];
    }
    return self;
}

- (void)setup:(id<GDeployFlow>)aDeployFlow
{
    @synchronized (self)
    {
        if (!self.memoryCache) {
            self.memoryCache = [[KCMemoryCache alloc] init];
            self.memoryCache.maxCount = 1;
        }
        if (!_deploy) _deploy = [[KCDeploy alloc] initWithDeployFlow:self];
        if (!_deployInstall) _deployInstall = [[KCDeployInstall alloc] initWithDeploy:_deploy];
        _db = [KerDB openWithDBName:_GWebAppDBName];
        if (_db)[self loadWebAppsFromDB];
        if (!_assetFlow) _assetFlow = [[GAssetFlow alloc] init];
        [self deploy];
        [self upgrade];
    }
}

- (void)_loadWebappsCfg:(NSString *)path block:(void (^)(NSArray<GWebAppJson *> *webAppJsons,NSDictionary *jsonObject)) aBlock
{
    [GUpgradeDek _readFileText:path block:^(NSString *str) {
        if (str && str.length>0)
        {
           NSMutableArray *mJsonModels = [NSMutableArray array];
           NSDictionary* jsonObject = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
           NSArray* jsonWebapps = [jsonObject objectForKey:@"webapps"];
           NSUInteger length = jsonWebapps ? jsonWebapps.count : 0;
           for (int i = 0; i < length; ++i)
           {
               NSDictionary* jsonWebapp = [jsonWebapps objectAtIndex:i];
               GWebAppJson *jsonModel = [[GWebAppJson alloc] initWithDictionary:jsonWebapp];
               KCFile* fileRoot = nil;
               if (jsonModel.root && jsonModel.root.length > 0)
               {
                   fileRoot = [[KCFile alloc] initWithPath:[GWebAppPath documentPath] name:jsonModel.root];
                   fileRoot = [[KCFile alloc] initWithFile:fileRoot name:jsonModel.identify];
               }
               else
               {
                   fileRoot =  [[KCFile alloc] initWithPath:[GWebAppPath documentPath] name:jsonModel.identify];
               }
               jsonModel.root = fileRoot.getAbsolutePath;
               [mJsonModels addObject:jsonModel];
            }
            if (aBlock)
            {
                aBlock(mJsonModels,jsonObject);
            }
        }
        else
        {
            !aBlock?:aBlock(nil,nil);
        }
    }];
}

- (void)setManifestFileName:(NSString*)aManifestFileName
{
    if (_deployInstall)
        _deployInstall.mManifestFileName = aManifestFileName;
}

- (void)deploy
{
    __weak typeof(self) weakSelf = self;
    [weakSelf _loadWebappsCfg:[weakSelf getAssetJsonResourcPath] block:^(NSArray<GWebAppJson *> *webAppJsons,NSDictionary *jsonObject) {
        for (GWebAppJson *jsonModel in webAppJsons) {
            KCFile* fileRoot = [[KCFile alloc] initWithPath:jsonModel.root];
            NSString* manifestUrl = jsonModel.manifestUrl;
            KCURI* manifestUri = nil;
            if (manifestUrl && manifestUrl.length > 0)
                manifestUri = [KCURI parse:manifestUrl];
            GWebApp* webapp = [[GWebApp alloc] initWithID:jsonModel.identify rootPath:fileRoot manifestUri:manifestUri];
            NSString *assetName = [GWebAppPath getAssetDekResourceName:jsonModel.identify];
            [weakSelf addTempWebApp:webapp];
            if (_assetFlow)
                [_assetFlow deploy:assetName deployflow:weakSelf webApp:webapp];
        }
    }];
}


- (void)_upgrade:(GWebAppJson *)jsonModel deployFlow:(GDeployFlowBlock)flow
{
    if (jsonModel.manifestUrl.length == 0)
    {
        return;
    }
    __weak typeof(self) weakSelf = self;
    BACKGROUND_BEGIN
    KCURI *manifestUri = nil;
    manifestUri = [KCURI parse:jsonModel.manifestUrl];
    [KCFetchManifest fetchOneServerManifest:manifestUri block:^(KCManifestObject *aManifestObject) {
        KCManifestObject *bManifestObject = [GUpgradeDek fetchLocalManifestObject:jsonModel.root];
        BOOL dekNeedUpdate = [GUpgradeDek dekNeedUpdate:aManifestObject compare:bManifestObject];
        if (dekNeedUpdate)
        {
            KCFile* fileRoot = [[KCFile alloc] initWithPath:jsonModel.root];
            GWebApp* webApp = [[GWebApp alloc] initWithID:jsonModel.identify rootPath:fileRoot manifestUri:manifestUri];
            [weakSelf upgradeWebApp:webApp];
            webApp.flow = flow;
            if (webApp.flow)
            {
                __weak GWebApp *weakWebApp = webApp;
                webApp.flow(weakWebApp, GDeployFlowStart);
            }
        }
    }];
    BACKGROUND_COMMIT
}

- (void)upgrade
{
    __weak typeof(self) weakSelf = self;
    [weakSelf _loadWebappsCfg:[weakSelf getRemoteJsonResourcePath] block:^(NSArray<GWebAppJson *> *webAppJsons,NSDictionary *jsonObject) {
        for (GWebAppJson *jsonModel in webAppJsons) {
            KCURI *manifestUri = nil;
            manifestUri = [KCURI parse:jsonModel.manifestUrl];
            [weakSelf _upgrade:jsonModel deployFlow:nil];
        }
    }];
}

- (void)upgradeWebApp:(GWebAppId)identify deployFlow:(GDeployFlowBlock)flow
{
    if (identify.length == 0)
    {
        return;
    }
    __weak typeof(self) weakSelf = self;
    __block GWebAppJson *jsonModel = nil;
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    [weakSelf _loadWebappsCfg:[weakSelf getRemoteJsonResourcePath] block:^(NSArray<GWebAppJson *> *webAppJsons,NSDictionary *jsonObject) {
        for (int i = 0 ; i < webAppJsons.count ; i++) {
            GWebAppJson *mJsonModel = webAppJsons[i];
            if ([mJsonModel.identify isEqualToString:identify])
            {
                jsonModel = mJsonModel;
                break;
            }
        }
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [weakSelf _upgrade:jsonModel deployFlow:flow];
    });
}


- (KCFile*)decodeFile:(KCFile *)aSrcFile dek:(KCDek *)aDek
{
    KCWebApp *kcWebApp = aDek.mWebApp;
    GWebApp* webapp = [self.tempwebApps objectForKey:kcWebApp.mTag];
    if (!webapp)
    {
        webapp = [[GWebApp alloc] initWithID:kcWebApp.mTag rootPath:kcWebApp.mRootPath manifestUri:kcWebApp.mManifestURI];
    }
    if (webapp.flow)
    {
        __weak GWebApp *weakWebApp = webapp;
        webapp.flow(weakWebApp, GDeployFlowLoading);
    }
    //you can do something here
    NSString *desFileName = [NSString stringWithFormat:@"%@.zip",[GWebAppPath getAssetDekResourceName:aDek.mWebApp.mTag]];
    NSString *srcPath = [aSrcFile getPath];
    NSString *desPath = [NSString stringWithFormat:@"%@/%@",[aSrcFile getParent],desFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:desPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:desPath error:nil];
    }
    BOOL isDecrypt = NO;
    if ([self.delegate respondsToSelector:@selector(decryptFile:desPath:)])
    {
        isDecrypt = [self.delegate decryptFile:srcPath desPath:desPath];
    }
    KCFile *file = nil;
    if (isDecrypt)
    {
        file = [[KCFile alloc] initWithPath:desPath];
    }
    return file;
}


- (void)onDeployError:(KCDeployError *)aError dek:(KCDek *)aDek
{
    KCWebApp *kcWebApp = aDek.mWebApp;
    GWebApp* webapp = [self.tempwebApps objectForKey:kcWebApp.mTag];
    if (!webapp)
    {
        webapp = [[GWebApp alloc] initWithID:kcWebApp.mTag rootPath:kcWebApp.mRootPath manifestUri:kcWebApp.mManifestURI];
    }
    __weak typeof(self) weakSelf = self;
    
    FOREGROUND_BEGIN
    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onDeployError:dek:)])
    {
        [weakSelf.delegate onDeployError:aError dek:aDek];
    }
    if (webapp.flow)
    {
        __weak GWebApp *weakWebApp = webapp;
        webapp.flow(weakWebApp, GDeployFlowError);
    }
    FOREGROUND_COMMIT
}

- (void)onComplete:(KCDek*)aDek
{
    KCWebApp *kcWebApp = aDek.mWebApp;
    GWebApp* webapp = [self.tempwebApps objectForKey:kcWebApp.mTag];
    if (!webapp)
    {
        webapp = [[GWebApp alloc] initWithID:kcWebApp.mTag rootPath:kcWebApp.mRootPath manifestUri:kcWebApp.mManifestURI];
    }
    [self addWebApp:webapp];
    
    __weak typeof(self) weakSelf = self;

    FOREGROUND_BEGIN
    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onComplete:)])
    {
        [weakSelf.delegate onComplete:aDek];
    }
    if (webapp.flow)
    {
        __weak GWebApp *weakWebApp = webapp;
        webapp.flow(weakWebApp, GDeployFlowFinish);
    }
    FOREGROUND_COMMIT
}

///资产目录下webapp.json文件路径
- (NSString *)getAssetJsonResourcPath
{
    NSString *assetResourcePath = [GWebAppPath getAssetResourcPath:_GWebAppJsonDefaultName ofType:nil];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(assetNameOfJsonInWebApp:)])
    {
        assetResourcePath = [GWebAppPath getAssetResourcPath:[self.dataSource assetNameOfJsonInWebApp:self] ofType:nil];
    }
    return assetResourcePath;
}

///远程webapp.json路径获取
- (NSString *)getRemoteJsonResourcePath
{
    NSString *ossResourcePath = [GWebAppPath getDefaultOssResourcePath];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(serverPathOfJsonInWebApp:)])
    {
        ossResourcePath = [self.dataSource serverPathOfJsonInWebApp:self];
    }
    return ossResourcePath;
}

///数据库读取已经部署的webapp数据
- (void)loadWebAppsFromDB
{
    KCSnapshot* snapshot = [_db createDBSnapshot];
    KCIterator* iterator = [_db iteratorDB];
    for ([iterator seekToFirst]; [iterator isValid]; [iterator next])
    {
        KCBytes bytes = [iterator getValue];
        if (bytes.data && bytes.length > 0)
        {
            NSData* dataValue = NSDataFromBytes(bytes);
            KCWebApp* kcWebApp =  [KCWebApp webApp:dataValue];
            kcWebApp = [self _synchronizedWebAppRootPath:kcWebApp];
            GWebApp* webapp = [[GWebApp alloc] initWithID:kcWebApp.mTag rootPath:kcWebApp.mRootPath manifestUri:kcWebApp.mManifestURI];
            [self safe_setWebapp:kcWebApp key:kcWebApp.mTag];
            [self safe_setTempWebapp:webapp key:webapp.mID];
        }
    }
    [iterator close];
    [snapshot close];
}

///沙盒根目录操作系统会自动变化，同步一下根目录
- (KCWebApp *)_synchronizedWebAppRootPath:(KCWebApp *)webApp
{
    KCWebApp *kcWebApp = webApp;
    if (![kcWebApp.mRootPath.getAbsolutePath containsString:[GWebAppPath documentPath]])
    {
        KCFile* fileRoot = [[KCFile alloc] initWithPath:[GWebAppPath documentPath]];
        NSRange range = [kcWebApp.mRootPath.getAbsolutePath rangeOfString:[fileRoot getAbsolutePath].lastPathComponent];
        int index = range.location + range.length;
        if (range.location != NSNotFound && kcWebApp.mRootPath.getAbsolutePath.length > index)
        {
            NSString *relativePath = [kcWebApp.mRootPath.getAbsolutePath substringFromIndex:index];
            fileRoot = [[KCFile alloc] initWithFile:fileRoot name:relativePath];
            kcWebApp.mRootPath = fileRoot;
            [self updateToDB:kcWebApp];
        }
    }
    return kcWebApp;
}

- (GWebAppId)getDefaultAppId
{
    return _GDefaultAppId;
}

- (NSString *)getResourcePath:(GWebAppId)appId
{
    KCWebApp *webApp = [self safe_getWebapp:appId];
    return webApp.mRootPath.getAbsolutePath;
}

- (NSString *)getHtmlString:(GWebAppId)appId path:(NSString *)path
{
    NSString *cacheKey = [NSString stringWithFormat:@"%@_%@",appId,path];
    NSString *htmlString = [self.memoryCache getCache:cacheKey];
    if (htmlString.length == 0)
    {
        NSString *resPath = [self getResourcePath:appId];
        if ([path containsString:resPath])
        {
            resPath = path;
        }
        else
        {
            KCURI *uri = [KCURI parse:path];
            resPath = [resPath stringByAppendingPathComponent:uri.components.path];
        }
        KCFile* htmlFilePath = [[KCFile alloc] initWithPath:resPath];
        htmlString = [KCFileManager readFileAsString:htmlFilePath.getAbsolutePath];
        if (htmlString) [self.memoryCache setCache:cacheKey Value:htmlString];
    }
    return htmlString;
}


- (void)addWebApp:(GWebApp *)webapp
{
    @synchronized (self)
    {
        if (!webapp) return;
        [self safe_setWebapp:webapp.mWebApp key:webapp.mID];
        [self updateToDBAsyn:webapp];
    }
}

- (void)addTempWebApp:(GWebApp *)webapp
{
    @synchronized (self)
    {
        if (!webapp) return;
        [self safe_setTempWebapp:webapp key:webapp.mID];
    }
}

- (void)updateToDB:(KCWebApp *)aWebApp
{
    if (_db)
        [_db putDBObject:aWebApp key:aWebApp.mTag];
}


- (void)updateToDBAsyn:(GWebApp *)aWebApp
{
    BACKGROUND_BEGIN
    [self updateToDB:aWebApp.mWebApp];
    [self loadWebAppsFromDB];
    BACKGROUND_COMMIT
}

- (void)upgradeWebApps:(NSArray<GWebApp *> *)aWebApps
{
   for (GWebApp *webApp in aWebApps) {
        [self upgradeWebApp:webApp];
    }
}

- (void)upgradeWebApp:(GWebApp*)aWebApp
{
    if (_deployInstall)
    {
        [self addTempWebApp:aWebApp];
        [_deployInstall installWebApp:aWebApp.mWebApp];
        [self.memoryCache flushMemory];
    }
}

- (void)dealloc
{
    self.webApps = nil;
    self.tempwebApps = nil;
    self.memoryCache = nil;
    _deploy = nil;
    _deployInstall = nil;
    if (_db && [_db isOpened])
    {
        [_db close];
    }
    _db = nil;
}

@end



