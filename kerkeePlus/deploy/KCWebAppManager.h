//
//  KCWebAppManager.h
//  kerkeePlus
//
//  Created by zihong on 16/6/17.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCWebApp.h"

@protocol KCDeployFlow;

@interface KCWebAppManager : NSObject

- (instancetype)initWithDeployFlow:(id<KCDeployFlow>)aDeployFlow;
- (instancetype)initWithDeployFlow:(id<KCDeployFlow>)aDeployFlow assetFileName:(NSString*)aAssetFileName;

- (void)setManifestFileName:(NSString*)aManifestFileName;

- (void)upgradeWebApps:(NSArray*)aWebApps;
- (void)upgradeWebApp:(KCWebApp*)aWebApp;
- (NSString*)getRootPath;
- (NSString*)getResRootPath;

@end
