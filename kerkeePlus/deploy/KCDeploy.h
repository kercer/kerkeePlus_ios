//
//  KCDeploy.h
//  kerkeePlus
//
//  Created by zihong on 16/6/17.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCDeployFlow.h"

@interface KCDeploy : NSObject

- (id)initWithDeployFlow:(id<KCDeployFlow>)aDeployFlow;
- (NSString*)getRootPath;
- (NSString*)getResRootPath;
- (void)setResRootPath:(NSString *)resRootPath;
- (void)setRootPath:(NSString *)rootPath;
- (BOOL)deploy:(KCFile*)aSrcFile dek:(KCDek*)aDek;

- (BOOL)checkHtmlDir;

@property (nonatomic, strong) id<KCDeployFlow> mDeployFlow;
@end
