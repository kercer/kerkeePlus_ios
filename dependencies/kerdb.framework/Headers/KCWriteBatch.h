//
//  KCWriteBatch.h
//  kerdb
//
//  Created by zihong on 16/5/20.
//  Copyright © 2016年 com.kercer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCDB.h"

//struct KCBytes;
typedef struct KCBytes KCBytes;

@interface KCWriteBatch : NSObject

@property (nonatomic, assign) id db;

/**
 Remove a key (and its associated value) from the database
 
 @param key The key to remove from the database
 */
- (void)removeWithData:(NSData*)aKey;
- (void)remove:(NSString*)aKey;

/**
 Set the value associated with a key in the database
 
 @param value The value to put in the database
 @param key The key at which the value can be found
 */
- (void)put:(KCBytes)aValue key:(KCBytes)aKey;

- (void)clear;

/**
 Write the write batch to the underlying database
 */
- (void)write;

@end
