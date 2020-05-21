//
//  GWebAppPath.m
//  GlobalScanner
//
//  Created by tangjun on 2019/12/5.
//  Copyright © 2019 xiaojian. All rights reserved.
//

#import "GWebAppPath.h"
#import <kerkee/KCFile.h>
#import <kerkee/KCString.h>
#define _GWebApp_Server_DefaultRootPath @"https://ggj-front.oss-cn-hangzhou.aliyuncs.com/dek/webApp.json"

@interface GWebAppPath ()
{
    NSString *m_rootPath;
}
@end

@implementation GWebAppPath
- (id)init
{
    if(self = [super init])
    {
        m_rootPath = [[self.class documentPath] stringByAppendingPathComponent:@"html"];
    }
    return self;
}

+ (NSString *)documentPath
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)lastObject];
    return documentPath;
}

//@ aPath is webview root path,if path if null, use default root path
- (void)setRootPath:(NSString*)aPath
{
    m_rootPath = aPath;
}


- (NSString*)getRootPath
{
    return m_rootPath;
}

+ (NSString *)getDefaultOssResourcePath
{
    return _GWebApp_Server_DefaultRootPath;
}

+ (NSString *)getAssetResourcPath:(NSString *)name ofType:(NSString *)type
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *resourcePath = [mainBundle pathForResource:name ofType:type];
    return resourcePath;
}

+ (NSString *)getAssetDekResourceName:(NSString *)identify
{
    return [identify kc_replaceAll:@"." with:@"_"];
}

- (NSString*)getResRootPath:(NSString *)hold
{
    KCFile* file = [[KCFile alloc] initWithPath:[self getRootPath] name:hold];
    return file.getAbsolutePath;
}

@end
