//
//  Transaction.m
//  Ink
//
//  Created by Jason Scharff on 1/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "Transaction.h"

@implementation Transaction

-(void)configureFromResponse : (NSDictionary *) response{
  self.merchant = response[@"name"];
  self.date = response[@"date"];
  if(((NSNumber *)response[@"amount"]).floatValue < 0) {
    self.lostMoney = NO;
    self.amount = ((NSNumber *)response[@"amount"]).floatValue * -1;
  }
  else {
    self.lostMoney = YES;
    self.amount = ((NSNumber *)response[@"amount"]).floatValue;
  }
  self.amountSaved = ((NSNumber *)response[@"amount_saved"]).floatValue;
  
  self.lastUpdated = [NSDate date];
  
}

// Specify default values for properties

//+ (NSDictionary *)defaultPropertyValues
//{
//    return @{};
//}

// Specify properties to ignore (Realm won't persist these)

//+ (NSArray *)ignoredProperties
//{
//    return @[];
//}

@end
