//
//  WebService.m
//  Axem
//
//  Created by BaoAnh on 1/20/14.
//  Copyright (c) 2014 BaoAnh. All rights reserved.
//

#import "WebService.h"
#import "AppDelegate.h"

static WebService *_webService;

@implementation WebService
+ (id)sharedInstant{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _webService = [[WebService alloc]init];
    });
    return _webService;
}
- (void)cancelRequest{
    if (operation != nil && operation.isExecuting) {
        [operation cancel];
    }
}
- (void)loadRequest:(NSString *)apiName action:(NSString *)action param:(NSDictionary *)param{
    
    if (operation != nil && operation.isExecuting) {
        [operation cancel];
    }
    NSURL *url = [NSURL URLWithString:API_SERVER_HOST];
    // get parameter
    NSString *keyValue;
    NSString *subUrl = @"?";
    for (NSString *key in param.allKeys) {
        if (key.length > 0) {
            NSString *value = [param objectForKey:key];
            if (subUrl.length == 1) {
                keyValue = [NSString stringWithFormat:@"%@=%@", key, value];
            }else{
                keyValue = [NSString stringWithFormat:@"&%@=%@", key, value];
            }
            subUrl = [subUrl stringByAppendingString:keyValue];
        }
    }
    // encoding parameter
    subUrl = [subUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    httpClient.parameterEncoding = AFJSONParameterEncoding;
    [httpClient setDefaultHeader:@"Accept" value:APPLICATION_JSON];
    
    request = [httpClient requestWithMethod:action path:subUrl parameters:nil];
    
    __weak typeof(self) weakSelf = self;
    
    operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        //            NSLog(@"response = %@", response);
        //            [[Util sharedUtil]hideHUD];
        [weakSelf parseResponse:response withApiName:apiName];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //            NSLog(@"error = %@", error.description);
        //            [[Util sharedUtil]hideHUD];
        [weakSelf apiName:apiName failConnection:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
    }];
    
    [operation start];
}
- (void) apiName:(NSString *)apiName failConnection:(NSString *)message{
    [self.delegate webService:self apiName:apiName requestFailedWithMessage:message];
}
- (void)parseResponse:(NSString *)response withApiName:(NSString *)apiName{
    NSDictionary *json = [response objectFromJSONString];
    
    if ([apiName isEqualToString:GET_CONTACT_WITH_LOCATION]) {
        NSMutableArray *dataSource = [[NSMutableArray alloc]init];
        for (NSDictionary *jsonItem in json) {
//            Video *video = [[Video alloc]initWithJson:jsonItem];
//            if (video != nil) {
//                [dataSource addObject:video];
//            }
        }
        [self.delegate receiveResponse:dataSource withApiName:apiName];
    }
}

- (AppDelegate *)appDelegate{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

@end
