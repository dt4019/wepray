//
//  User.h
//  WePray
//
//  Created by BaoAnh on 6/15/14.
//  Copyright (c) 2014 BaoAnh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, retain) NSString *iD;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *thumbImageUrl;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@end
