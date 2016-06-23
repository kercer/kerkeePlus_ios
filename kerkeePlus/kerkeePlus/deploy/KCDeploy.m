//
//  KCDeploy.m
//  kerkeePlus
//
//  Created by zihong on 16/6/17.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import "KCDeploy.h"
#import <KCWebPath.h>
#import <KCBaseDefine.h>
#import <KCFile.h>
#import "KCDek.h"
#import <kerzip/KCZip.h>


@interface KCDeploy ()
{
    KCWebPath* m_webPath;
    __unsafe_unretained id<KCDeployFlow> m_deployFlow;
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
    
    return false;
}

@end
