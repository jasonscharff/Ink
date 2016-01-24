//
//  LoginStoreController.m
//  Ink
//
//  Created by Jason Scharff on 1/22/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "LoginStoreController.h"

#import "AFHTTPSessionManager.h"
#import "JNKeychain.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@implementation LoginStoreController

+ (instancetype)sharedLoginStoreController {
  static dispatch_once_t once;
  static LoginStoreController *_sharedInstance;
  dispatch_once(&once, ^{
    _sharedInstance = [[self alloc] init];
  });
  
  return _sharedInstance;
}

-(BOOL)isLoggedIn {
  if([FBSDKAccessToken currentAccessToken].tokenString && [JNKeychain loadValueForKey:@"auth_token"]) {
    return YES;
  }
  else {
    return NO;
  }
}

-(void)sendLoginToken:(NSString *)token : (void (^)(BOOL hasPLToken))completion  {
  AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
  NSString *pushToken = [[NSUserDefaults standardUserDefaults]objectForKey:@"push_token"];
  NSDictionary *dictionary;
  if(pushToken) {
    dictionary = @{@"fbToken" : token, @"apns_token" : pushToken};
  }
  else {
    dictionary = @{@"fbToken" : token};
  }
  
  [manager POST:@"http://api.getink.co/user/login" parameters:dictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    NSLog(@"response object = %@", responseObject);
    [JNKeychain saveValue:responseObject[@"auth_token"] forKey:@"auth_token"];
    if(((NSNumber *)responseObject[@"hasPLToken"]).floatValue > 0) {
      completion(YES);
    }
    else {
      completion(NO);
    }
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    NSLog(@"An error has occured. %@", error);
    completion(NO);
  }];
}

-(void)sendPlaidToken: (NSString *)token {
  AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
  manager.responseSerializer = [AFJSONResponseSerializer serializer];
  manager.requestSerializer = [AFJSONRequestSerializer serializer];
  [manager.requestSerializer setValue:[JNKeychain loadValueForKey:@"auth_token"] forHTTPHeaderField:@"x-access-token"];
  NSDictionary *dictionary = @{@"PLToken" : token};
  [manager POST:@"http://api.getink.co/user/link" parameters:dictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    NSLog(@"success = %@", responseObject);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    NSLog(@"error = %@", error);
  }];
}

@end
