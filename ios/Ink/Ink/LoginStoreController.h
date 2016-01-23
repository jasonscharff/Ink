//
//  LoginStoreController.h
//  Ink
//
//  Created by Jason Scharff on 1/22/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginStoreController : NSObject

+ (instancetype)sharedLoginStoreController;
-(BOOL)isLoggedIn;

@end
