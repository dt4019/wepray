//
//  WebService.h
//  Axem
//
//  Created by BaoAnh on 1/20/14.
//  Copyright (c) 2014 BaoAnh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "JSONKit.h"

@class WebService;

@class AppDelegate;

#define INSERT_LOCATION                 @"insertlocation.php"
#define GET_CONTACT_WITH_LOCATION       @"getcontactwithlocation.php"

@protocol WebServiceDelegate <NSObject>

@optional
// delegate if request successed
- (void)receiveResponse:(id)response withApiName:(NSString *)apiName;
// delegate if request failed
- (void)webService:(WebService *)webserVice apiName:(NSString *)apiName requestFailedWithMessage:(NSString *)message;

@end

@interface WebService : NSObject{
    AFHTTPClient *httpClient;
    NSMutableURLRequest *request;
    AFHTTPRequestOperation *operation;
}

@property (nonatomic, retain)id <WebServiceDelegate> delegate;

+ (id)sharedInstant;
- (void)loadRequest:(NSString *)apiName action:(NSString *)action param:(NSDictionary *)param;
- (void)cancelRequest;

@end
