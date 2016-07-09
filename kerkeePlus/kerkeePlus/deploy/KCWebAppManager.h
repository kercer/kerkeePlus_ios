//
//  KCWebAppManager.h
//  kerkeePlus
//
//  Created by zihong on 16/6/17.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCDeployFlow.h"

@interface KCWebAppManager : NSObject

- (instancetype)initWithDeployFlow:(id<KCDeployFlow>)aDeployFlow;
- (instancetype)initWithDeployFlow:(id<KCDeployFlow>)aDeployFlow assetFileName:(NSString*)aAssetFileName;

- (void)setManifestFileName:(NSString*)aManifestFileName;

@end
