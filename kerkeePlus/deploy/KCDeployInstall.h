//
//  KCDeployInstall.h
//  kerkeePlus
//
//  Created by zihong on 16/6/17.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCDeploy.h"

@class KCWebApp;

@interface KCDeployInstall : NSObject

- (instancetype)initWithDeploy:(KCDeploy*)aDeploy;
- (void)installWebApps:(NSArray*)aWebApps;
- (void)installWebApp:(KCWebApp*)aWebApp;

//the default manifest file name if "cache.manifest"
@property(nonatomic, strong, setter = setManifestFileName:) NSString* mManifestFileName;

@end
