//
//  KCDeployFlowDefault.m
//  kerkeePlus
//
//  Created by zihong on 16/6/17.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import "KCDeployFlowDefault.h"
#import <kerkee/KCFile.h>

@implementation KCDeployFlowDefault

- (KCFile*)decodeFile:(KCFile*)aSrcFile dek:(KCDek*)aDek
{
//    KCFile* dirPath = [aSrcFile getParentFile];
    return aSrcFile;
}
- (void)onComplete:(KCDek*)aDek
{
    
}
- (void)onDeployError:(KCDeployError*)aError dek:(KCDek*)aDek
{
    
}

@end
