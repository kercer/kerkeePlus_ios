//
//  GWebApp.m
//  GlobalScanner
//
//  Created by tangjun on 2019/12/6.
//  Copyright © 2019 xiaojian. All rights reserved.
//

#import "GWebApp.h"

@interface GWebApp ()
{
    KCWebApp *__webApp;
    GWebAppPath *__webAppPath;
}
@property (nonatomic, readwrite, copy) NSString *mID;
@end

@implementation GWebApp

- (id)initWithID:(GWebAppId)aID rootPath:(KCFile *)aRootPath manifestUri:(KCURI *)aManifestUri
{
    self = [super init];
    if (self)
    {
        __webApp = [[KCWebApp alloc] initWithID:0 rootPath:aRootPath manifestUri:aManifestUri];
        __webApp.mTag = aID;
        self.mID = aID;
        __webAppPath = [[GWebAppPath alloc] init];
        [__webAppPath setRootPath:aRootPath.getParent];
    }
    return self;
}

- (GWebAppPath *)getWebAppPath
{
    return __webAppPath;
}

- (KCWebApp *)mWebApp
{
    return __webApp;
}

- (KCURI *)mManifestURI
{
    return __webApp.mManifestURI;
}

- (KCFile *)mRootPath
{
    return __webApp.mRootPath;
}

- (id)mTag
{
    return __webApp.mTag;
}

- (void)setMTag:(id)mTag
{
    __webApp.mTag = mTag;
}

- (NSString *)getVersion
{
    return [__webApp getVersion];
}

+ (KCWebApp *)webApp:(NSData *)aData
{
    return [KCWebApp webApp:aData];
}
@end

@interface GWebAppJson ()
@property (nonatomic , strong ,readwrite) GWebAppId identify;
@property (nonatomic , strong ,readwrite) GWebAppId dependency;
@property (nonatomic , strong ,readwrite) GWebAppManifestUrl manifestUrl;
@end

@implementation GWebAppJson

- (instancetype)initWithDictionary:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        self.identify = data[@"id"];
        self.dependency = data[@"dependency"];
        self.root = data[@"root"];
        self.manifestUrl = data[@"manifestUrl"];
    }
    return self;
}

@end
