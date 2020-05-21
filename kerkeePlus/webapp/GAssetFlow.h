//
//  GAssetFlow.h
//  GlobalScanner
//
//  Created by tangjun on 2019/12/6.
//  Copyright © 2019 xiaojian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWebApp.h"
NS_ASSUME_NONNULL_BEGIN
@protocol KCDeployFlow;
@interface GAssetFlow : NSObject

- (void)deploy:(NSString*)aAssetFileName deployflow:(id<KCDeployFlow>)aDeployFlow webApp:(GWebApp *)webApp;

@end

NS_ASSUME_NONNULL_END
