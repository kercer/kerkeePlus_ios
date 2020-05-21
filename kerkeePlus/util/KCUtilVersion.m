//
//  KCUtilVersion.m
//  kerkeePlus
//
//  Created by zihong on 16/7/6.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import "KCUtilVersion.h"

@implementation KCUtilVersion

+ (int)compareVersion:(NSString*)a version2:(NSString*)b
{
    int res = 0;
    
    NSArray* aNumber = [a componentsSeparatedByString:@"."];
    NSArray* bNumber = [b componentsSeparatedByString:@"."];
    NSUInteger maxIndex = aNumber.count > bNumber.count ? aNumber.count :bNumber.count;
    
        for (int i = 0; i < maxIndex; i++)
        {
            int aVersionPart = i < aNumber.count ? [aNumber[i] intValue] : 0;
            int bVersionPart = i < bNumber.count ? [bNumber[i] intValue] : 0;
            
            if (aVersionPart < bVersionPart)
            {
                res = -1;
                break;
            }
            else if (aVersionPart > bVersionPart)
            {
                res = 1;
                break;
            }
        }
    return res;
}

@end

