//
//  GWebApp.h
//  GlobalScanner
//
//  Created by tangjun on 2019/12/6.
//  Copyright © 2019 xiaojian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCWebApp.h"
#import "GWebAppPath.h"
NS_ASSUME_NONNULL_BEGIN

typedef NSString * GWebAppId;
typedef NSString * GWebAppRootPath;
typedef NSString * GWebAppManifestUrl;

typedef NS_ENUM(NSUInteger, GDeployFlowProgress) {
    GDeployFlowStart = 0,       // 开始
    GDeployFlowLoading = 1,        // 进行中
    GDeployFlowFinish = 2,         // 完成
    GDeployFlowError = 3        // 错误
};
@class GWebApp;

typedef void(^GDeployFlowBlock)(GWebApp *webApp,GDeployFlowProgress progress);

@interface GWebApp : NSObject

@property (nonatomic, readonly, copy) GWebAppId mID;
@property (nonatomic, readonly, strong) KCURI* mManifestURI;
@property (nonatomic, readonly, strong) KCFile* mRootPath;
@property (nonatomic, readonly, strong) KCWebApp *mWebApp;
@property (nonatomic , copy) GDeployFlowBlock flow;
@property (nonatomic, strong)id mTag;

- (id)initWithID:(GWebAppId)aID rootPath:(KCFile*)aRootPath manifestUri:(KCURI*)aManifestUri;
- (GWebAppPath *)getWebAppPath;
- (NSString *)getVersion;
+ (KCWebApp *)webApp:(NSData*)aData;
@end

@interface GWebAppJson : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)data;

@property (nonatomic , strong ,readonly) GWebAppId identify;
@property (nonatomic , strong ,readonly) GWebAppId dependency;
@property (nonatomic , strong ,readwrite) GWebAppRootPath root;
@property (nonatomic , strong ,readonly) GWebAppManifestUrl manifestUrl;
@end

NS_ASSUME_NONNULL_END
