//
//  GAssetFlow.m
//  GlobalScanner
//
//  Created by tangjun on 2019/12/6.
//  Copyright © 2019 xiaojian. All rights reserved.
//

#import "GAssetFlow.h"
#import "GWebAppPath.h"
#import <kerkeePlus/KCDeploy.h>
#import <kerkeePlus/KCDeployAssert.h>
#import <kerkee/KCMainBundle.h>
@interface GAssetFlow ()
{
    KCDeploy* m_deploy;
    KCDeployAssert* m_deployAssert;
    GWebAppPath *_webAppPath;
    GWebApp *_webApp;
}
@end

@implementation GAssetFlow

- (void)deploy:(NSString*)aAssetFileName deployflow:(id<KCDeployFlow>)aDeployFlow webApp:(GWebApp *)webApp
{
    @synchronized (self)
    {
        if (!m_deploy) m_deploy = [[KCDeploy alloc] initWithDeployFlow:aDeployFlow];
        if (!m_deployAssert)
        {
            m_deployAssert = [[KCDeployAssert alloc] initWithDeploy:m_deploy];
        }
        [m_deploy setRootPath:webApp.mRootPath.getParent];
        [m_deploy setResRootPath:webApp.mRootPath.getAbsolutePath];
        m_deployAssert.mAssetFileName = [aAssetFileName stringByAppendingString:@".dek"];
        if ([KCMainBundle isFirstLaunchAfterVersionChanged] || ![self checkHtmlDir])
        {
            [m_deployAssert deployFromWebApp:webApp.mWebApp];
        }
    }
}

- (BOOL)checkHtmlDir
{
    BOOL isChecked = NO;
    KCFile* file = [[KCFile alloc] initWithPath:[m_deploy getResRootPath]];
    NSFileManager *mgr = [NSFileManager defaultManager];
    if([file exists]){
        isChecked = [mgr subpathsAtPath:[m_deploy getResRootPath]] >0 ? YES : NO;
    }
    return isChecked;
}

- (GWebAppPath *)getWebAppPath
{
    if (!_webAppPath)
    {
        _webAppPath = [[GWebAppPath alloc] init];
    }
    return _webAppPath;
}
@end
