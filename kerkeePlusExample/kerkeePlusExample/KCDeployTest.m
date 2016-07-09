//
//  KCDeployTest.m
//  kerkeePlusExample
//
//  Created by zihong on 16/7/9.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import "KCDeployTest.h"
#import <kerkeePlus/KCWebAppManager.h>
#import <kerkeePlus/KCWebApp.h>
#import <kerkee.h>

@interface KCDeployTest ()
{
    KCWebAppManager* m_webAppMgr;
}

@end



@implementation KCDeployTest

/**
 * POST:
 * {
 * "platform": "android",//platform
 * "buildCode": "5",
 * "list": [//dek list of your local
 * {
 * "id": 0,//dek ID
 * "version": "1.0.2"//dek version
 * }
 * ],
 * "versionName": "2.0.3",//app version
 * "channelId": "umeng"//channel
 * }
 *
 * Response:
 * success:
 * {
 * "_token": "UjdEVNiHLsF1UAtmWaLjxCqmh3QeDj8lVBmiDWSQ",
 * "list": [//dek list of can upgrade
 * {
 * "manifestUrl": "http://mob.jz-test.doumi.com/dek/cache.manifest",//dek manifest
 * "ID": 0//dek ID
 * }
 * ],
 * "code": 200//ok
 * }
 *
 * error
 * {
 * "_token": "rYbiz6goLUBTQ9WH7UFOy38LUk37Q0efgMpLaBln",
 * "name": "params error",
 * "message": "list parse error",//list args error
 * "code": "-500"
 * }
 */
- (void)check
{
    NSMutableDictionary* postData = [[NSMutableDictionary alloc] init];
    [postData setObject:@"2.2.1" forKey:@"versionName"];
    [postData setObject:@"11" forKey:@"buildCode"];
    [postData setObject:@"ios" forKey:@"platform"];
    [postData setObject:@"umeng" forKey:@"channelId"];
    
    NSMutableArray* webappList = [[NSMutableArray alloc] init];
    [webappList addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:0], @"id", @"1.0.1", @"version", nil]];
    [postData setObject:webappList forKey:@"list"];

    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:postData options:0 error:nil];
    
    KCLog(@"%@", [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    
//    [self.class postData:[NSURL URLWithString:@"post url"] data:(NSData*)jsonData finishedBlock:^(NSData *data)
//    {
//        NSString *strData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        if (strData)
//        {
//        }
//    }];
    
   //This a Demo to get check config, Because I write configuration on my server, so i use GET HTTP Method to fetch this data, you can use pos in your project
    [self.class fetchData:[NSURL URLWithString:@"http://www.linzihong.com/test/update/update"] finishedBlock:^(NSData *data)
     {
         NSString *strData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         if (strData)
         {
             NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:[strData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
             NSArray* webappList = [dic objectForKey:@"list"];
             NSDictionary* jsWebapp = [webappList objectAtIndex:0];
             
             KCURI* manifestURI = [KCURI URIWithString:[jsWebapp objectForKey:@"manifestUrl"]];
             int nID = [[jsWebapp objectForKey:@"ID"] intValue];
             //if nID is 0, the webapp path is ResRootPath, if you has sub web app you can use not 0, and the webapp path is not ResRootPath
             KCFile* fileRootPath = [[KCFile alloc] initWithPath:m_webAppMgr.getResRootPath];
             
             KCWebApp* webApp = [[KCWebApp alloc] initWithID:nID rootPath:fileRootPath manifestUri:manifestURI];
             if (m_webAppMgr)
             {
                 [m_webAppMgr upgradeWebApp:webApp];
             }
             
         }
     }];
    
    
}


+ (NSURLSession *)session
{
    static NSURLSession *session;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    });
    
    return session;
}

+(void)fetchData:(NSURL*)aUrl finishedBlock:(void(^)(NSData *data))block
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl];
    
    NSURLSession *session = [self session];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          if (!error && block)
                                          {
                                              block(data);
                                          }
                                      }];
    [dataTask resume];
}

+(void)postData:(NSURL*)aUrl data:(NSData*)aData finishedBlock:(void(^)(NSData *data))block
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl];
    request.HTTPMethod = @"POST";
    request.HTTPBody = aData;
    
    NSURLSession *session = [self session];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          if (!error && block)
                                          {
                                              block(data);
                                          }
                                      }];
    [dataTask resume];
}


- (void)setup
{
    m_webAppMgr = [[KCWebAppManager alloc] initWithDeployFlow:self assetFileName:@"html.zip"];
}


#pragma mark - deploy flow
- (KCFile*)decodeFile:(KCFile*)aSrcFile dek:(KCDek*)aDek
{
    //you can do something here
    return aSrcFile;
}
- (void)onComplete:(KCDek*)aDek
{
    
}
- (void)onDeployError:(KCDeployError*)aError dek:(KCDek*)aDek
{
    
}



@end
