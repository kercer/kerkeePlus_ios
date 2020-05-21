//
//  kerdb.h
//  kerdb
//
//  Created by zihong on 16/5/20.
//  Copyright © 2016年 com.kercer. All rights reserved.
//

#ifndef kerdb_h
#define kerdb_h

#import <UIKit/UIKit.h>

#import "KCDB.h"



@interface KerDB : NSObject


#pragma mark open db
/**
 Return the Database with the given path, if it doesn't exist create it
 */
+ (KCDB*)openWithPath:(NSString *)aDBPath;
/**
 Return the Database with the given path and options
 */
+ (KCDB*)openWithPath:(NSString *)aDBPath options:(KCDBOptions)aOptions;

/**
 Return the Database with the given name, if it doesn't exist create it
 */
+ (KCDB*)openWithDBName:(NSString *)aDBName;
/**
 Return the Database with the given name
 */
+ (KCDB*)openWithDBName:(NSString *)aDBName options:(KCDBOptions)aOptions;

/**
 Return the Database with the default name, if it doesn't exist create it
 */
+ (KCDB*)openDefaultDB;
/**
 Return the Database with the default name and the given options
 */
+ (KCDB*)openDefaultDBWithOptions:(KCDBOptions)aOptions;

/**
 * If a DB cannot be opened, you may attempt to call this method to resurrect as much of the contents of the
 * database as possible. Some data may be lost, so be careful when calling this function on a database that contains
 * important information.
 */
+ (BOOL)repairDBWithPath:(NSString *)aDBPath;


@end


#endif /* kerdb_h */
