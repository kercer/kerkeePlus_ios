//
//  KCSnapshot.h
//  kerdb
//
//  Created by zihong on 16/5/20.
//  Copyright © 2016年 com.kercer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCDB.h"

@class KCDB;

@interface KCSnapshot : NSObject


@property (nonatomic, readonly, assign) KCDB* db;

/**
 Close the snapshot.
 
 @warning The instance cannot be used to perform any query after it has been closed.
 */
- (void) close;

@end
