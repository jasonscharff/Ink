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
#import "AutolayoutHelper.h"
#import "LoginStoreController.h"
#import "PlaidLinkViewController.h"
#import "UIFontDescriptor+AvenirNext.h"

@interface LoginViewController ()<FBSDKLoginButtonDelegate>

@end

@implementation LoginViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  
  UILabel *mainLabel = [UILabel new];
  mainLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:22];
  mainLabel.textAlignment = NSTextAlignmentCenter;
  mainLabel.text = @"Login";
  UILabel *captionLabel = [UILabel new];
  captionLabel.numberOfLines = 0;
  captionLabel.textAlignment = NSTextAlignmentCenter;
  captionLabel.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleBody]size:0];
  captionLabel.text = @"Ink uses Facebook for authentication. In order to use Ink, you must use Facebook.";
  
  
  NSArray *permissions = @[@"public_profile", @"email", @"user_about_me", @"user_education_history",@"user_likes", @"user_relationships", @"user_relationship_details", @"user_work_history"];
  FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
  loginButton.readPermissions = permissions;
  loginButton.publishPermissions = @[@"publish_actions"];
  loginButton.delegate = self;
  
  [AutolayoutHelper configureView:self.view subViews:VarBindings(mainLabel, captionLabel, loginButton) constraints:@[@"H:|-[mainLabel]-|", @"H:|-[captionLabel]-|", @"V:|-25-[mainLabel]-[captionLabel]-36-[loginButton]", @"X:loginButton.centerX == superview.centerX"]];
  
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
