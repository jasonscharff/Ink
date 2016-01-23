//
//  Balance.h
//  Ink
//
//  Created by Jason Scharff on 1/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <Realm/Realm.h>

static NSString *kINKChecking = @"checking";
static NSString *kINKSavings = @"savings";

@interface Balance : RLMObject

@property float value;
@property NSString *displayString;
@property NSDate *updatedOn;

@end

RLM_ARRAY_TYPE(Balance)
