//
//  GWebAppPath.h
//  GlobalScanner
//
//  Created by tangjun on 2019/12/5.
//  Copyright © 2019 xiaojian. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface GWebAppPath : NSObject

- (void)setRootPath:(NSString*)aPath;
- (NSString *)getRootPath;
- (NSString*)getResRootPath:(NSString *)hold;
+ (NSString *)getDefaultOssResourcePath;
+ (NSString *)getAssetResourcPath:(NSString *)name ofType:(NSString *)type;
+ (NSString *)getAssetDekResourceName:(NSString *)identify;
+ (NSString *)documentPath;
@end
