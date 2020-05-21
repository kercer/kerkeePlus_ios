//
//  GWebAppManager.h
//  GlobalScanner
//
//  Created by tangjun on 2019/12/4.
//  Copyright © 2019 xiaojian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <kerkeePlus/KCWebAppManager.h>
#import <kerkeePlus/KCDeploy.h>
#import "GWebApp.h"

@class GWebAppManager;

@protocol GWebAppDataSource <NSObject>
@optional
//资产目录下的webApp.json名称
- (NSString *)assetNameOfJsonInWebApp:(GWebAppManager *)webApp;
//远程webApp.json的路径
- (NSString *)serverPathOfJsonInWebApp:(GWebAppManager *)webApp;

@end

@protocol GDeployFlow <NSObject>
- (void)onComplete:(KCDek *)aDek;
- (void)onDeployError:(KCDeployError*)aError dek:(KCDek *)aDek;
@required

//解密
- (BOOL)decryptFile:(NSString *)aSrcPath desPath:(NSString *)aDesPath;

@end

@interface GWebAppManager : NSObject

@property (nonatomic, weak, readonly) id<GWebAppDataSource> dataSource;
@property (nonatomic, weak, readonly) id<GDeployFlow> delegate;
+ (instancetype)defaultManager;
+ (void)setDefaultManager:(GWebAppManager *)webappManager;
- (instancetype)initWithDeployFlow:(id<GDeployFlow>)aDeployFlow dataSource:(id<GWebAppDataSource>)dataSource;
- (void)deploy;
- (void)upgrade;
- (void)upgradeWebApp:(GWebAppId)identify deployFlow:(GDeployFlowBlock)flow;
- (void)setManifestFileName:(NSString*)aManifestFileName;
- (NSString *)getResourcePath:(GWebAppId)appId;
- (GWebAppId)getDefaultAppId;
- (NSString *)getHtmlString:(GWebAppId)appId path:(NSString *)path;

@end


