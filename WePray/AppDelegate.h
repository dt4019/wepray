//
//  AppDelegate.h
//  WePray
//
//  Created by BaoAnh on 6/15/14.
//  Copyright (c) 2014 BaoAnh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "About.h"
#import "Map.h"
#import "Chat.h"
#import "AKTabBarController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) AKTabBarController *tabBarController;

@end
