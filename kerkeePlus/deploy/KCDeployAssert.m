//
//  KCDeployAssert.m
//  kerkeePlus
//
//  Created by zihong on 16/6/17.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import "KCDeployAssert.h"
#import "KCDeploy.h"
#import <kerkee/KCFile.h>
#import "KCDek.h"
#import <kerkee/KCFileManager.h>
#import <kerkee/KCTaskQueue.h>


@interface KCDek ()
{
}
- (void)setWebApp:(KCWebApp*)aWebApp;

- (void)setIsFromAssert:(BOOL)aIsFromAssert;

@end


@interface KCDeployAssert ()
{
    NSString* m_assetFileName;
    KCDeploy* m_deploy;
}

@end



@implementation KCDeployAssert
@synthesize mAssetFileName = m_assetFileName;


- (instancetype)initWithDeploy:(KCDeploy*)aDeploy
{
    if (self = [super init])
    {
        m_assetFileName = kDefaultAssetFileName;
        m_deploy = aDeploy;
    }
    return self;
}

- (KCFile*)copyAssetDekFile
{
    KCFile* rootDir =[[KCFile alloc] initWithPath:m_deploy.getRootPath];
    if (![rootDir exists])
        [rootDir mkdirs];
    
    KCFile* tmpDesFile = [[KCFile alloc] initWithFile:rootDir name:m_assetFileName];
    if ([tmpDesFile exists])
    {
        [tmpDesFile remove];
    }
    NSString* bundlePath = [[NSBundle mainBundle] pathForResource:m_assetFileName ofType:nil];
    [KCFileManager copy:bundlePath toPath:tmpDesFile.getPath overwrite:YES];
    return tmpDesFile;
}

- (BOOL)deployFromAssert
{
    KCFile* srcFile = [self copyAssetDekFile];
    KCFile* htmlDir = [[KCFile alloc] initWithPath:[m_deploy getResRootPath]];
    KCDek* dek = [[KCDek alloc] initWithRootPath:htmlDir];
    [dek setIsFromAssert:true];
    BOOL isOK = [m_deploy deploy:srcFile dek:dek];
    
    //if copy zip to document, delete srcFile here
    BACKGROUND_GLOBAL_BEGIN(PRIORITY_DEFAULT)
    [srcFile remove];
    BACKGROUND_GLOBAL_COMMIT
    
    return isOK;
}

- (BOOL)deployFromWebApp:(KCWebApp*)aWebApp
{
    
    KCFile* srcFile = [self copyAssetDekFile];
    KCFile* htmlDir = [[KCFile alloc] initWithPath:[m_deploy getResRootPath]];
    KCDek* dek = [[KCDek alloc] initWithRootPath:htmlDir];
    [dek setWebApp:aWebApp];
    [dek setIsFromAssert:true];
    BOOL isOK = [m_deploy deploy:srcFile dek:dek];
       
    //if copy zip to document, delete srcFile here
    BACKGROUND_GLOBAL_BEGIN(PRIORITY_DEFAULT)
    [srcFile remove];
    BACKGROUND_GLOBAL_COMMIT
       
    return isOK;
}

@end
