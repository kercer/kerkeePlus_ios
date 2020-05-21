//
//  KCDek.m
//  kerkeePlus
//
//  Created by zihong on 16/6/17.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import "KCDek.h"
#import <kerkee/KCFetchManifest.h>
#import <kerkee/KCBaseDefine.h>
#import <kerkee/KCFile.h>
#import <kerkee/KCManifestObject.h>


@interface KCDek ()
{
    NSString* m_manifestFileName;
    //contain manifest dir path
    KCManifestObject* m_manifestObject;
    //if net,is a url; if local, is a full path
    //it is dir path
    KCURI* m_manifestUri;
    //dek root path
    KCFile* m_rootPath;
    //the dek belongs to a webapp
    KCWebApp* m_webApp;
    BOOL m_isFromAssert;
}

@end

@implementation KCDek
@synthesize mManifestFileName = m_manifestFileName, mManifestObject = m_manifestObject, mManifestUri = m_manifestUri;
@synthesize mRootPath = m_rootPath, mWebApp = m_webApp, mIsFromAssert = m_isFromAssert;

- (id)init
{
    return [self initWithRootPath:nil];
}

- (id)initWithRootPath:(KCFile*)aRootPath
{
    if (self = [super init])
    {
        m_manifestFileName = kDefaultManifestName;
        m_isFromAssert = false;
        m_rootPath = aRootPath;
    }
    return self;
}

- (KCManifestObject*)loadLocalManifest
{
    NSString* deployManifest = [NSString stringWithFormat:@"%@/%@", m_rootPath.getAbsolutePath, m_manifestFileName];
    KCURI* uri = [[KCURI alloc] initWithString:deployManifest];
    KCAutorelease(uri);
    KCManifestObject* manifestObject = [KCFetchManifest fetchOneLocalManifest:uri];
    return manifestObject;
}

- (void)setManifestFileName:(NSString*)aFileName
{
    m_manifestFileName = aFileName;
}

- (void)setManifestObject:(KCManifestObject*)aManifestObject
{
    m_manifestObject = aManifestObject;
}

- (KCManifestObject*)getManifestObject
{
    return m_manifestObject;
}

- (void)setManifestUri:(KCURI*)aUri
{
    m_manifestUri = aUri;
}
- (KCURI*)getManifestUri
{
    return m_manifestUri;
}

- (void)setRootPath:(KCFile*)aRootPath
{
    m_rootPath = aRootPath;
}
- (KCFile*)getRootPath
{
    return m_rootPath;
}

- (void)setWebApp:(KCWebApp*)aWebApp
{
    m_webApp = aWebApp;
}
- (KCWebApp*)getWebApp
{
    return m_webApp;
}

- (void)setIsFromAssert:(BOOL)aIsFromAssert
{
    m_isFromAssert = aIsFromAssert;
}
- (BOOL)isFromAssert
{
    return m_isFromAssert;
}



@end
