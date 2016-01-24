//
//  SendMoneyStoreController.h
//  Ink
//
//  Created by Jason Scharff on 1/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SendMoneyStoreController : NSObject

+ (instancetype)sharedSendMoneyStoreController;
- (void)saveMoney : (NSString *)amount;

@end
