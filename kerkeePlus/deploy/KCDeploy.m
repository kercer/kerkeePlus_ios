//
//  KCDeploy.m
//  kerkeePlus
//
//  Created by zihong on 16/6/17.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import "KCDeploy.h"
#import <kerkee/KCWebPath.h>
#import <kerkee/KCBaseDefine.h>
#import <kerkee/KCFile.h>
#import "KCDek.h"
#import <kerzip/KCZip.h>
#import "KCDeployError.h"
#import "KCDeployFlowDefault.h"


@interface KCDeploy ()
{
    KCWebPath* m_webPath;
    id<KCDeployFlow> m_deployFlow;
}

@end

@implementation KCDeploy
@synthesize mDeployFlow = m_deployFlow;

- (id)init
{
    if (self = [super init])
    {
        m_webPath = [[KCWebPath alloc] init];
    }
    return self;
}

- (id)initWithDeployFlow:(id<KCDeployFlow>)aDeployFlow
{
    if (self = [self init])
    {
        if (aDeployFlow)
            m_deployFlow = aDeployFlow;
        else
            m_deployFlow = [[KCDeployFlowDefault alloc] init];
    }
    return self;
}
- (void)dealloc
{
    KCRelease(m_webPath);
    m_webPath = nil;
    m_deployFlow = nil;
}

- (NSString*)getRootPath
{
    return [m_webPath getRootPath];
}

- (NSString*)getResRootPath
{
    return [m_webPath getResRootPath];
}

- (BOOL)deploy:(KCFile*)aSrcFile dek:(KCDek*)aDek
{
    if ([aSrcFile exists])
    {
        KCFile* tmpZipFile = nil;
        if (m_deployFlow && [m_deployFlow respondsToSelector:@selector(decodeFile:dek:)])
        {
            tmpZipFile = [m_deployFlow decodeFile:aSrcFile dek:aDek];
        }
        
        if (tmpZipFile && [tmpZipFile exists])
        {
            KCFile* dirDek = aDek.mRootPath;
            [dirDek remove];
            [dirDek mkdirs];
            BOOL isSuccess = [KCZip unzip:tmpZipFile.getPath to:dirDek.getPath];
            [tmpZipFile remove];
            if (!isSuccess)
            {
                [dirDek remove];
                if (m_deployFlow && [m_deployFlow respondsToSelector:@selector(onDeployError:dek:)])
                    [m_deployFlow onDeployError:[[KCDeployError alloc] init] dek:aDek];
                return false;
            }
            
            if (m_deployFlow && [m_deployFlow respondsToSelector:@selector(onComplete:)])
            {
               [m_deployFlow onComplete:aDek];
            }
            
            return true;
        }
        if (m_deployFlow && [m_deployFlow respondsToSelector:@selector(onDeployError:dek:)])
            [m_deployFlow onDeployError:[[KCDeployError alloc] init] dek:aDek];
    }
    else
    {
        if (m_deployFlow && [m_deployFlow respondsToSelector:@selector(onDeployError:dek:)])
            [m_deployFlow onDeployError:[[KCDeployError alloc] init] dek:aDek];
    }
    
    return false;
}


- (void)notifyDeployError:(KCDeployError*)aError dek:(KCDek*)aDek
{
    if (m_deployFlow && [m_deployFlow respondsToSelector:@selector(onDeployError:dek:)])
        [m_deployFlow onDeployError:aError dek:aDek];
}


- (BOOL)checkHtmlDir
{
    KCFile* file = [[KCFile alloc] initWithPath:[self getRootPath] name:@"/html"];
    return [file exists];
}

@end
