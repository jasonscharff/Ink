//
//  AppDelegate.m
//  Ink
//
//  Created by Jason Scharff on 1/22/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "AppDelegate.h"

#import "BalanceViewController.h"
#import "HistoryViewController.h"
#import "LoginStoreController.h"
#import "LoginViewController.h"
#import "SendMoneyViewController.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface AppDelegate ()

@property (nonatomic, strong) UINavigationController *navigationController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
  self.navigationController = [[UINavigationController alloc]init];
  self.navigationController.navigationBar.translucent = NO;
  if([[LoginStoreController sharedLoginStoreController]isLoggedIn]) {
    [self createTabBarController];
  }
  else {
    [self.navigationController pushViewController:[[LoginViewController alloc]init] animated:NO];
  }
  self.window.rootViewController = self.navigationController;
  [self.window makeKeyAndVisible];
  
  // Override point for customization after application launch.
  return YES;
}

-(void)createTabBarController {
  UITabBarController *tabBarController = [[UITabBarController alloc]init];
  tabBarController.tabBar.translucent = NO;
  UIViewController *vc1 = [[BalanceViewController alloc]init];
  UITabBarItem *item1 = [[UITabBarItem alloc]initWithTitle:@"" image:nil selectedImage:nil];
  UIViewController *vc2 = [[HistoryViewController alloc]init];
  UIViewController *vc3 = [[SendMoneyViewController alloc]init];
  tabBarController.viewControllers = @[vc1, vc2, vc3];
  vc1.tabBarItem = item1;
  [self.navigationController setViewControllers:@[tabBarController]];
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
  
  BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                openURL:url
                                                      sourceApplication:sourceApplication
                                                             annotation:annotation];
  
  return handled;
}

@end
