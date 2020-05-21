//
//  KCIterator.h
//  kerdb
//
//  Created by zihong on 16/5/20.
//  Copyright © 2016年 com.kercer. All rights reserved.
//

#import <Foundation/Foundation.h>

//struct KCBytes;
typedef struct KCBytes KCBytes;

@interface KCIterator : NSObject

- (void)seekToFirst;
- (void)seekToLast;
- (void)seek:(KCBytes)aBytes;
- (BOOL)isValid;
- (void)next;
- (void)prev;
- (KCBytes)getKey;
- (KCBytes)getValue;
- (void)close;

@end
