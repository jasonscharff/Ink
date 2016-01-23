//
//  LoginStoreController.m
//  Ink
//
//  Created by Jason Scharff on 1/22/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "LoginStoreController.h"

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
  return YES;
}

@end
