//
//  Transaction.h
//  Ink
//
//  Created by Jason Scharff on 1/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <Realm/Realm.h>

@interface Transaction : RLMObject

-(void)configureFromResponse : (NSDictionary *)response;

@property float amount;
@property NSString *merchant;
@property float amountSaved;
@property BOOL lostMoney;
@property NSString *date;
@property NSDate *lastUpdated;

@end


// This protocol enables typed collections. i.e.:
// RLMArray<Transaction>
RLM_ARRAY_TYPE(Transaction)
