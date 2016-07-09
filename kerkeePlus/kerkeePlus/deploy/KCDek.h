//
//  KCDek.h
//  kerkeePlus
//
//  Created by zihong on 16/6/17.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCWebApp.h"

#define kDefaultManifestName @"cache.manifest"

@class KCManifestObject;
@interface KCDek : NSObject

- (id)initWithRootPath:(KCFile*)aRootPath;


@property (nonatomic, readonly, copy) NSString* mManifestFileName;
//contain manifest dir path
@property (nonatomic, readonly, strong) KCManifestObject* mManifestObject;
//if net,is a url; if local, is a full path
//it is dir path
@property (nonatomic, readonly, strong) KCURI* mManifestUri;
//dek root path
@property (nonatomic, readonly, strong) KCFile* mRootPath;
//the dek belongs to a webapp
@property (nonatomic, readonly, strong) KCWebApp* mWebApp;
@property (nonatomic, readonly) BOOL mIsFromAssert;


@end
