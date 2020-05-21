//
//  KCWebApp.m
//  kerkeePlus
//
//  Created by zihong on 16/6/17.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import "KCWebApp.h"
#import <kerkee/KCURI.h>
#import <kerkee/KCFile.h>
#import "KCDek.h"
#import <kerkee/KCBaseDefine.h>
#import <kerkee/KCManifestObject.h>

@interface KCWebApp ()
{
    //If ID = 0, that means the Webapp that contains all of the Webapps, and these all webapps in a file
    int m_ID;
    KCURI* m_manifestURI; //webapp's root manifest url
    KCFile* m_rootPath;
    KCDek* m_dekSelf;
    id m_tag;
}

@end


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

@implementation KCWebApp
@synthesize mID = m_ID, mManifestURI = m_manifestURI, mRootPath = m_rootPath, mTag = m_tag;

- (id)initWithID:(int)aID rootPath:(KCFile*)aRootPath manifestUri:(KCURI*)aManifestUri
{
    if (self = [super init])
    {
        m_ID = aID;
        m_rootPath = aRootPath;
        KCRetain(m_rootPath);
        m_manifestURI = aManifestUri;
        KCRetain(m_manifestURI);
        
        m_dekSelf = [[KCDek alloc] initWithRootPath:aRootPath];
        [m_dekSelf setManifestUri:aManifestUri];
        [m_dekSelf setWebApp:self];
        if (aManifestUri && aManifestUri.components.path)
        {
            [m_dekSelf setManifestFileName:[aManifestUri getLastPathSegment]];
        }
        
    }
    return self;
}

- (void)dealloc
{
    m_ID = 0;
    KCRelease(m_manifestURI);
    m_manifestURI = nil;
    KCRelease(m_rootPath);
    m_rootPath = nil;
    KCRelease(m_dekSelf);
    m_dekSelf = nil;
    KCRelease(m_tag);
    m_tag = nil;
}

+ (KCWebApp*)webApp:(NSData*)aData
{
    return [[[KCWebApp alloc] init] toObject:aData];
}

- (NSString*)getVersion
{
    NSString* version = nil;
    if (m_dekSelf)
    {
        KCManifestObject* manifestObject = [m_dekSelf loadLocalManifest];
        if (manifestObject) version = manifestObject.mVersion;
    }
    return version;
}

+ (KCWebApp*)webAppWithData:(NSData*)aBytes
{
    KCWebApp* webapp = [[KCWebApp alloc] init];
    return [webapp toObject:aBytes];
}

- (NSString*)description
{
    NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[self toDic] options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    return json;
}

- (NSDictionary*)toDic
{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSNumber numberWithInteger:m_ID] forKey:@"id"];
    NSString* manifestUrl = m_manifestURI ? m_manifestURI.description : @"";
    
    [dic setObject:(manifestUrl?manifestUrl:@"") forKey:@"manifestUrl"];
    [dic setObject:(m_rootPath ? m_rootPath.getAbsolutePath :@"") forKey:@"rootPath"];
    [dic setObject:(m_tag?m_tag:@"") forKey:@"mTag"];

    return dic;
}

- (NSData*)toBytes
{
//    return [KCArchiver archive:self];
    return [NSJSONSerialization dataWithJSONObject:[self toDic] options:0 error:nil];
}

- (id)toObject:(NSData*)aData
{
//    return [KCArchiver unarchive:aData];
    NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:aData options:NSJSONReadingAllowFragments error:nil];
    NSInteger nID = [[dic objectForKey:@"id"] integerValue];
    NSString* manifestUrl = [dic objectForKey:@"manifestUrl"];
    NSString* rootPath = [dic objectForKey:@"rootPath"];
    id mTag = [dic objectForKey:@"mTag"];

    KCURI* manifestURI = [[KCURI alloc] initWithString:manifestUrl];
    KCFile* rootPathFile = [[KCFile alloc] initWithPath:rootPath];
    
    m_ID =(int)nID;
    m_manifestURI = manifestURI;
    m_rootPath = rootPathFile;
    m_tag = mTag;
    return self;
    
}



@end
