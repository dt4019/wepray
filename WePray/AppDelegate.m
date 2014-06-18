//
//  AppDelegate.m
//  WePray
//
//  Created by BaoAnh on 6/15/14.
//  Copyright (c) 2014 BaoAnh. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    
//    About *about = [[About alloc]initWithNibName:@"About" bundle:nil];
//    UINavigationController *navAbout = [[UINavigationController alloc]initWithRootViewController:about];
    
    Map *map = [[Map alloc]initWithNibName:@"Map" bundle:nil];
    UINavigationController *navMap = [[UINavigationController alloc]initWithRootViewController:map];
    
    Chat *chat = [[Chat alloc]initWithNibName:@"Chat" bundle:nil];
    UINavigationController *navChat = [[UINavigationController alloc]initWithRootViewController:chat];
    
    
    
//    Create and initialize with specific height and position atop the view controller
       _tabBarController = [[AKTabBarController alloc] initWithTabBarHeight:TAB_BAR_HEIGHT position:AKTabBarPositionBottom];
    
//       // set border color
//       [_tabBarController setTabEdgeColor:[[Util sharedUtil]colorWithRed:81.0 green:131.0 blue:172.0 andAlpha:1.0]];
//       // Tab background Image
//       [_tabBarController setBackgroundImageName:@"Background.png"];
//       [_tabBarController setSelectedBackgroundImageName:@"Background.png"];
//       // Text color
//       [_tabBarController setTextColor:[UIColor blackColor]];
//       [_tabBarController setSelectedTextColor:[UIColor blueColor]];
       // Adding the view controllers to manage.
       [_tabBarController setViewControllers:[[NSMutableArray alloc]initWithArray:[NSArray arrayWithObjects:navMap, navChat, nil]]];
    
       self.window.rootViewController = _tabBarController;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
