//
//  GUpgradeDek.h
//  GlobalScanner
//
//  Created by tangjun on 2019/12/9.
//  Copyright © 2019 xiaojian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWebAppPath.h"

NS_ASSUME_NONNULL_BEGIN

@class KCManifestObject;
@interface GUpgradeDek : NSObject

+ (KCManifestObject *)fetchLocalManifestObject:(NSString *)path;

+ (BOOL)dekNeedUpdate:(KCManifestObject *)aManifestObject compare:(KCManifestObject *)bManifestObject;

+ (void)_readFileText:(NSString *)aPath block:(void(^)(NSString *str))aBlock;
@end

NS_ASSUME_NONNULL_END
