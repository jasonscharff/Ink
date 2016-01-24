//
//  LoginViewController.m
//  Ink
//
//  Created by Jason Scharff on 1/22/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "LoginViewController.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "AppDelegate.h"
#import "LoginStoreController.h"
#import "PlaidLinkViewController.h"

@interface LoginViewController ()<FBSDKLoginButtonDelegate>

@end

@implementation LoginViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  
  UILabel *label = [UILabel new];
  
  NSArray *permissions = @[@"public_profile", @"email", @"user_about_me", @"user_education_history",@"user_likes", @"user_relationships", @"user_relationship_details", @"user_work_history"];
  FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
  loginButton.readPermissions = permissions;
  loginButton.publishPermissions = @[@"publish_actions"];
  loginButton.center = self.view.center;
  loginButton.delegate = self;
  
  [self.view addSubview:loginButton];
}

-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
  if(!error) {
    
    [[LoginStoreController sharedLoginStoreController]sendLoginToken:[FBSDKAccessToken currentAccessToken].tokenString :^(BOOL hasPLToken) {
      if(hasPLToken) {
        [self skipPlaid];
      }
      else {
        [self goPlaid];
      }
    }];
    
  }
  
}

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
  
}


-(void)goPlaid {
  PlaidLinkViewController *vc = [[PlaidLinkViewController alloc]init];
  [self.navigationController pushViewController:vc animated:YES];
}
-(void)skipPlaid {
  AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  [appDelegate createTabBarController];
}


@end
