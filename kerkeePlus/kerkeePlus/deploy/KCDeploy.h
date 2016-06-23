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


@property (nonatomic, assign) id<KCDeployFlow> mDeployFlow;
@end
