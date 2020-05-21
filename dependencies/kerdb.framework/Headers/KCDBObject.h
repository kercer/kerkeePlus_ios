//
//  KCDBObject.h
//  kerdb
//
//  Created by zihong on 16/5/20.
//  Copyright © 2016年 com.kercer. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KCDBObject <NSObject>
- (NSData*)toBytes;
- (id)toObject:(NSData*)aData;
@end

//@interface KCDBObject : NSObject
//
//@end
