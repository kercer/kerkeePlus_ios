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
#import <KCTaskQueue.h>
#import <KCFetchManifest.h>

#define kDekFileName @"tmp.dek"

@interface KCDeployInstall ()
{
    NSString* m_manifestFileName;
    KCDeploy* m_deploy;
}

@end

@implementation KCDeployInstall


- (instancetype)initWithDeploy:(KCDeploy*)aDeploy
{
    if (self = [super init])
    {
        m_manifestFileName = kDefaultManifestName;
        m_deploy = aDeploy;
    }
    return self;
}

- (void)installWebApp:(KCWebApp*)aWebApp
{
    if (!aWebApp) return;
    
    BACKGROUND_GLOBAL_BEGIN(PRIORITY_DEFAULT)
    
    [KCFetchManifest fetchServerManifests:aWebApp.mManifestURI block:^(KCManifestObject *aManifestObject) {
        if (aManifestObject)
        {
            
        }
    }];
    
    BACKGROUND_GLOBAL_COMMIT
}

@end
