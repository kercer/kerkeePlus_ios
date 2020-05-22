//
//  KCDeployAssert.h
//  kerkeePlus
//
//  Created by zihong on 16/6/17.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCDeploy.h"


#define kDefaultAssetFileName @"main.dek"
@interface KCDeployAssert : NSObject

//default asset file name is "main.dek";
@property (nonatomic, copy) NSString* mAssetFileName;

- (instancetype)initWithDeploy:(KCDeploy*)aDeploy;
- (BOOL)deployFromAssert;

@end
