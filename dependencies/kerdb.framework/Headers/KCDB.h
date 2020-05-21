//
//  KCDB.h
//  kerdb
//
//  Created by zihong on 16/5/20.
//  Copyright © 2016年 com.kercer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCSnapshot.h"
#import "KCDBObject.h"
#import "KCWriteBatch.h"
#import "KCIterator.h"

@class KCSnapshot,KCWriteBatch;

/**
 you can get bytes from NSString or NSData,use `BytesFromNSString` or `BytesFromNSData`
 */
typedef struct KCBytes
{
    const char * data;
    NSUInteger   length;
} KCBytes;
//typedef struct KCBytes KCBytes;

#ifdef __cplusplus
extern "C" {
#endif
    
    NSString* NSStringFromBytes(KCBytes aBytes);
    NSData*   NSDataFromBytes  (KCBytes aBytes);
    KCBytes   BytesFromNSString(NSString* aString);
    KCBytes   BytesFromNSData  (NSData* aData);
    
#ifdef __cplusplus
}
#endif

typedef struct
{
    bool createIfMissing ;
    bool createIntermediateDirectories;
    bool errorIfExists   ;
    bool paranoidCheck   ;
    bool compression     ;
    int  filterPolicy    ;
    size_t cacheSize     ;
    size_t blockSize     ;   //Default: 4K
    size_t writeBufferSize;  //Default: 4MB
} KCDBOptions;

@protocol KCDB <NSObject>

#pragma mark - DB MANAGEMENT

/**
 Open database
 */
- (BOOL)open;

/**
 Checks if database is open.
 */
- (BOOL)isOpened;

/**
 Closes database.
 */
- (void)close;

/**
 Destroys database
 */
- (void)destroy;

/**
 Return an KCSnapshot instance for this database
 
 KCSnapshot are a way to "freeze" the state of the database. Write operation applied to the database after the
 snapshot was taken do not affect the snapshot. Most *read* methods available in the KCDB class are also
 available in the KCSnapshot class.
 */
- (KCSnapshot*)createDBSnapshot;

#pragma mark - CREATE

/**
 Puts the the byte array data for the key which the type is KCBytes
 */
- (void)putBytes:(KCBytes)aValue keyBytes:(KCBytes)aKey sync:(BOOL)aSync;

/**
 Puts the the byte array data for the key which the type is NSData
 */
- (void)put:(NSData*)aValue keyData:(NSData*)aKey;

/**
 Puts the byte array data for the key.
 */
- (void)put:(NSData*)aValue key:(NSString*)aKey;

/**
 Puts the string value for the key.
 */
- (void)putString:(NSString*)aValue key:(NSString*)aKey;

/**
 Puts the KCDBObject for the key.
 */
- (void)putDBObject:(id<KCDBObject>)aValue key:(NSString*)aKey;

/**
 Puts the primitive integer for the key.
 */
- (void)putInt:(int)aValue key:(NSString*)aKey;

/**
 Puts the primitive short for the key.
 */
- (void)putShort:(short)aValue key:(NSString*)aKey;

/**
 Puts the primitive boolean for the key.
 */
- (void)putBoolean:(bool)aValue key:(NSString*)aKey;

/**
 Puts the primitive double for the key.
 */
- (void)putDouble:(double)aValue key:(NSString*)aKey;

/**
 Puts the primitive float for the key.
 */
- (void)putFloat:(float)aValue key:(NSString*)aKey;

/**
 Puts the primitive long for the key.
 */
- (void)putLong:(long)aValue key:(NSString*)aKey;

#pragma mark - REMOVE
/**
 Deletes value for the key.
 */
- (void)removeWithKeyData:(NSData*)aKey;
- (void)removeWithKeyData:(NSData*)aKey sync:(BOOL)aSync;

/**
 Deletes value for the key.
 */
- (void)remove:(NSString*)aKey;
- (void)remove:(NSString*)aKey sync:(BOOL)aSync;

#pragma mark - WRITE

/**
 Return an retained KCWritebatch instance for this database
 */
- (KCWriteBatch *)createWritebatch;

/**
 Apply the operations from a writebatch into the current database
 */
- (void)write:(KCWriteBatch*)aWriteBatch;
- (void)write:(KCWriteBatch*)aWriteBatch sync:(BOOL)aSync;

#pragma mark - RETRIEVE
/**
 get bytes with key bytes and snapshot
 */
- (NSData*)getWithKeyData:(NSData*)aKey snapshot:(KCSnapshot*)aSnapshot;

/**
 get bytes with snapshot
 */
- (NSData*)get:(NSString*)aKey snapshot:(KCSnapshot*)aSnapshot;

/**
 get bytes with key bytes
 */
- (NSData*)getWithKeyData:(NSData*)aKey;

/**
 get bytes with key bytes
 */
- (NSData*)get:(NSString*)aKey;

/**
 get string
 */
- (NSString*)getString:(NSString*)aKey;

/**
 get short
 */
- (short)getShort:(NSString*)aKey;

/**
 get int
 */
- (int)getInt:(NSString*)aKey;

/**
 get boolean
 */
- (BOOL)getBoolean:(NSString*)aKey;

/**
 get double
 */
- (double)getDouble:(NSString*)aKey;

/**
 get float
 */
- (float)getFloat:(NSString*)aKey;

/**
 get long
 */
- (long)getLong:(NSString*)aKey;

#pragma mark - KEYS OPERATIONS
- (BOOL)exists:(NSString*)aKey;

- (NSArray*)findKeys:(NSString*)aPrefix;
- (NSArray*)findKeys:(NSString*)aPrefix offset:(int)aOffset;
- (NSArray*)findKeys:(NSString*)aPrefix offset:(int)aOffset limit:(int)aLimit;

- (int)countKeys:(NSString*)aPrefix;

- (NSArray*)findKeysBetween:(NSString*)aStartPrefix endPrefix:(NSString*)aEndPrefix;
- (NSArray*)findKeysBetween:(NSString*)aStartPrefix endPrefix:(NSString*)aEndPrefix offset:(int)aOffset;
- (NSArray*)findKeysBetween:(NSString*)aStartPrefix endPrefix:(NSString*)aEndPrefix offset:(int)aOffset limit:(int)aLimit;

- (int)countKeysBetween:(NSString*)aStartPrefix endPrefix:(NSString*)aEndPrefix;

#pragma mark - ITERATORS
- (KCIterator*)iteratorDB;
- (KCIterator*)iteratorWithSnapshot:(KCSnapshot*)aSnapshot;
- (KCIterator*)iteratorWithSnapshot:(KCSnapshot*)aSnapshot fillCache:(BOOL)aFillCache;

- (KCBytes)getPropertyBytes:(KCBytes)aKey;

/**
 * If a DB cannot be opened, you may attempt to call this method to resurrect as much of the contents of the
 * database as possible. Some data may be lost, so be careful when calling this function on a database that contains
 * important information.
 */
- (BOOL)repairDB;

@end

@interface KCDB : NSObject <KCDB>

/**
 The path of the database on disk
 */
@property (nonatomic, retain) NSString *path;

/**
 A boolean value indicating whether write operations should be synchronous (flush to disk before returning).
 */
@property (nonatomic) BOOL sync;

/**
 A boolean value indicating whether read operations should try to use the configured cache (defaults to true).
 */
@property (nonatomic) BOOL fillCache;


# pragma mark -
/**
 A class method that returns a KCDBOptions struct, which can be modified to finetune leveldb
 */
+ (KCDBOptions) makeDefaultOptions;


/**
 Initialize a db with default options
 */
- (id) initWithPath:(NSString *)aDBPath;

/**
 Initialize a db with a options
 */
- (id) initWithPath:(NSString *)aDBPath options:(KCDBOptions)aOptions;


#pragma mark - Write batches

/**
 Create new writebatch, apply the operations in block from a writebatch into the current database
 */
- (void) performWritebatch:(void (^)(KCWriteBatch *wb))block;

#pragma mark DELETE
/**
 Remove all objects prefixed with a given value (`NSString` or `NSData`)
 
 @param prefix The key prefix used to remove all matching keys (of type `NSString` or `NSData`)
 */
- (void)removeAllWithPrefix:(id)aPrefix;

/**
 exists with snapshot
 */
- (BOOL)exists:(NSString*)aKey snapshot:(KCSnapshot*)aSnapshot;
- (BOOL)existsKeyData:(NSData*)aKey snapshot:(KCSnapshot*)aSnapshot;



#pragma mark - Enumeration
typedef void     (^KCDBKeyBlock)(KCBytes * key, BOOL *stop);
typedef void     (^KCDBKeyValueBlock)(KCBytes * key, id value, BOOL *stop);

typedef id       (^KCDBValueGetterBlock)(void);
typedef void     (^KCDBLazyKeyValueBlock)(KCBytes * key, KCDBValueGetterBlock lazyValue, BOOL *stop);

/**
 Enumerate over the keys in the database, in order.
 */
- (void) enumerateKeysBackward:(BOOL)aBackward
                 startingAtKey:(id)aKey
           filteredByPredicate:(NSPredicate *)aPredicate
                     andPrefix:(id)aPrefix
                  withSnapshot:(KCSnapshot *)aSnapshot
                    usingBlock:(KCDBKeyBlock)aBlock;



/**
 Enumerate over the keys in the database, in direct or backward order, with some options to control the keys iterated over
 
 @param backward A boolean value indicating whether the enumeration happens in direct or backward order
 @param key (optional) The key at which to start iteration. If the key isn't present in the database, the enumeration starts at the key immediately greater than the provided one. The key can be a `NSData` or `NSString`
 @param predicate A `NSPredicate` instance tested against the values. The iteration block will only be called for keys associated to values matching the predicate. If `nil`, this is ignored.
 @param prefix A `NSString` or `NSData` prefix used to filter the keys. If provided, only the keys prefixed with this value will be iterated over.
 @param block The enumeration block used when iterating over all the keys. It takes three arguments: the first is a pointer to a `KCBytes` struct. You can convert this to a `NSString` or `NSData` instance, using `NSDataFromBytes(LevelDBKey *key)` and `NSStringFromBytes(KCBytes *key)` respectively. The second argument is the value associated with the key. The third arguments to the block is a `BOOL *` that can be used to stop enumeration at any time (e.g. `*stop = TRUE;`).
 */
- (void) enumerateKeysAndObjectsBackward:(BOOL)aBackward
                                  lazily:(BOOL)aLazily
                           startingAtKey:(id)aKey
                     filteredByPredicate:(NSPredicate *)aPredicate
                               andPrefix:(id)aPrefix
                            withSnapshot:(KCSnapshot *)aSnapshot
                              usingBlock:(id)aBlock;

#pragma mark -
/**
 * If a DB cannot be opened, you may attempt to call this method to resurrect as much of the contents of the
 * database as possible. Some data may be lost, so be careful when calling this function on a database that contains
 * important information.
 */
+ (BOOL)repairDBWithPath:(NSString *)aDBPath;

@end



