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
#import "NewsfeedViewController.h"
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
  
  [self.navigationController.navigationBar setTitleTextAttributes:
   @{NSForegroundColorAttributeName:[UIColor blackColor],
     NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-Regular" size:21]}];
  
  
  self.navigationController.navigationItem.title = @"Ink";
  
  if([[LoginStoreController sharedLoginStoreController]isLoggedIn]) {
    [self createTabBarController];
  }
  else {
    [self.navigationController pushViewController:[[LoginViewController alloc]init] animated:NO];
  }
  self.window.rootViewController = self.navigationController;
  [self.window makeKeyAndVisible];
  
  // Override point for customization after application launch.
  
  
  
  UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
  UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes  categories:nil];
  [application registerUserNotificationSettings:settings];
  [application registerForRemoteNotifications];
  
  return YES;
}

-(void)createTabBarController {
  UITabBarController *tabBarController = [[UITabBarController alloc]init];
  tabBarController.tabBar.translucent = NO;
  
  UIImage *balance = [UIImage imageNamed:@"balance"];
  UIImage *history = [UIImage imageNamed:@"history"];
  UIImage *timeline = [UIImage imageNamed:@"timeline"];
  UIImage *save = [UIImage imageNamed:@"save_money"];
  
  UITabBarItem *item1 = [[UITabBarItem alloc]initWithTitle:@"Balance" image:balance selectedImage:balance];
  UITabBarItem *item2 = [[UITabBarItem alloc]initWithTitle:@"Purchases" image:history selectedImage:history];
  UITabBarItem *item3 = [[UITabBarItem alloc]initWithTitle:@"Announcements" image:timeline selectedImage:timeline];
  UITabBarItem *item4 = [[UITabBarItem alloc]initWithTitle:@"Save" image:save selectedImage:save];
  
  UIViewController *vc1 = [[BalanceViewController alloc]init];
  vc1.tabBarItem = item1;
  UIViewController *vc2 = [[HistoryViewController alloc]init];
  vc2.tabBarItem = item2;
  UIViewController *vc3 = [[NewsfeedViewController alloc]init];
  vc3.tabBarItem = item3;
  UIViewController *vc4 = [[SendMoneyViewController alloc]init];
  vc4.tabBarItem = item4;
  tabBarController.viewControllers = @[vc1, vc2, vc3, vc4];
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

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
     NSString *devToken = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""]
                            stringByReplacingOccurrencesOfString:@">" withString:@""]
                            stringByReplacingOccurrencesOfString: @" " withString: @""];
  
    [[NSUserDefaults standardUserDefaults]setObject:devToken forKey:@"push_token"];
}

@end
