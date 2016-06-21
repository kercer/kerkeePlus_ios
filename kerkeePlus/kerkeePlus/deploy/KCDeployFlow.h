//
//  KCDeployFlow.h
//  kerkeePlus
//
//  Created by zihong on 16/6/17.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KCFile.h>
#import "KCDek.h"
#import "KCDeployError.h"


@protocol KCDeployFlow <NSObject>

- (KCFile*) decodeFile:(KCFile*)aSrcFile dek:(KCDek*)aDek;
- (void)onComplete:(KCDek*)aDek;
- (void)onDeployError:(KCDeployError*)aError dek:(KCDek*)aDek;

@end
