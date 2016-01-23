//
//  BalanceStoreController.h
//  Ink
//
//  Created by Jason Scharff on 1/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BalanceStoreController : NSObject

+ (instancetype)sharedBalanceStoreController;
-(void)amountOfMoneySaved : (void (^)(CGFloat value))completion;
-(void)amountOfMoneyAvailable : (void (^)(CGFloat value))completion;
-(void)refreshData : (void (^)(NSArray * results))completion;

@end
