//
//  KCDeployError.m
//  kerkeePlus
//
//  Created by zihong on 16/6/21.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import "KCDeployError.h"

@implementation KCDeployError

-(id)init
{
    if (self = [super initWithDomain:@"deploy" code:-1 userInfo:[NSDictionary dictionaryWithObject:@"deploy error"                                                                      forKey:NSLocalizedDescriptionKey]])
    {
    }
    return self;
}
@end
