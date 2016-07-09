//
//  KCDeployTest.m
//  kerkeePlusExample
//
//  Created by zihong on 16/7/9.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import "KCDeployTest.h"
#import "kerkeePlus/KCWebAppManager.h"


@interface KCDeployTest ()
{
    KCWebAppManager* m_webAppMgr;
}

@end



@implementation KCDeployTest

/**
 * POST:
 * {
 * "platform": "android",//platform
 * "buildCode": "5",
 * "list": [//dek list of your local
 * {
 * "id": 0,//dek ID
 * "version": "1.0.2"//dek version
 * }
 * ],
 * "versionName": "2.0.3",//app version
 * "channelId": "umeng"//channel
 * }
 *
 * Response:
 * success:
 * {
 * "_token": "UjdEVNiHLsF1UAtmWaLjxCqmh3QeDj8lVBmiDWSQ",
 * "list": [//dek list of can upgrade
 * {
 * "manifestUrl": "http://mob.jz-test.doumi.com/dek/cache.manifest",//dek manifest
 * "ID": 0//dek ID
 * }
 * ],
 * "code": 200//ok
 * }
 *
 * error
 * {
 * "_token": "rYbiz6goLUBTQ9WH7UFOy38LUk37Q0efgMpLaBln",
 * "name": "params error",
 * "message": "list parse error",//list args error
 * "code": "-500"
 * }
 */
- (void)check
{
    
}


- (void)setup
{
    m_webAppMgr = [[KCWebAppManager alloc] initWithDeployFlow:self assetFileName:@"html.zip"];
}


#pragma mark - deploy flow
- (KCFile*)decodeFile:(KCFile*)aSrcFile dek:(KCDek*)aDek
{
    //you can do something here
    return aSrcFile;
}
- (void)onComplete:(KCDek*)aDek
{
    
}
- (void)onDeployError:(KCDeployError*)aError dek:(KCDek*)aDek
{
    
}



@end
