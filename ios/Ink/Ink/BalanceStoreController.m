//
//  BalanceStoreController.m
//  Ink
//
//  Created by Jason Scharff on 1/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "BalanceStoreController.h"

#import "AFHTTPSessionManager.h"
#import "Balance.h"
#import "JNKeychain.h"

static int thresholdLengthToRefreshInSeconds = 60 * 60;

@implementation BalanceStoreController

+ (instancetype)sharedBalanceStoreController {
  static dispatch_once_t once;
  static BalanceStoreController *_sharedInstance;
  dispatch_once(&once, ^{
    _sharedInstance = [[self alloc] init];
  });
  
  return _sharedInstance;
}

-(void)amountOfMoneyAvailable : (void (^)(CGFloat value))completion {
  [self getValueFromDataBaseWithKey:kINKChecking :^(CGFloat value) {
    completion(value);
  }];
}

-(void)amountOfMoneySaved : (void (^)(CGFloat value))completion {
  [self getValueFromDataBaseWithKey:kINKSavings :^(CGFloat value) {
    completion(value);
  }];
}

-(void)getValueFromDataBaseWithKey : (NSString *)key : (void (^)(CGFloat value))completion{
  RLMResults<Balance *> *balances = [Balance objectsWithPredicate:[NSPredicate predicateWithFormat:@"displayString == %@", key]];
  if(balances.count > 0) {
    Balance *b = balances[0];
    if([[NSDate date]timeIntervalSinceDate:b.updatedOn] < thresholdLengthToRefreshInSeconds) {
      completion(b.value);
    }
  }
  [self getDataFromServer:^{
    RLMResults<Balance *> *balances = [Balance objectsWithPredicate:[NSPredicate predicateWithFormat:@"displayString == %@", key]];
    if(balances.count > 0) {
      Balance *b = balances[0];
      completion(b.value);
    }
    else {
      completion(-1);
    }
  }];
}


-(void)refreshData : (void (^)(NSArray * results))completion {
  
  RLMResults <Balance *> *balanceCheckings = [Balance objectsWithPredicate:[NSPredicate predicateWithFormat:@"displayString == %@", kINKSavings]];
  RLMResults<Balance *> *balanceSavings = [Balance objectsWithPredicate:[NSPredicate predicateWithFormat:@"displayString == %@", kINKSavings]];
  if((balanceSavings.count > 0 && balanceCheckings.count > 0) &&
     ([((Balance *)balanceSavings[0]).updatedOn timeIntervalSinceDate:[NSDate date]] >  thresholdLengthToRefreshInSeconds) &&
     [((Balance *)balanceCheckings[0]).updatedOn timeIntervalSinceDate:[NSDate date]] >  thresholdLengthToRefreshInSeconds) {
    Balance *checking = balanceCheckings[0];
    Balance *savings = balanceSavings[0];
    NSNumber *sum = @(checking.value + savings.value);
    NSNumber *checkingNum = @(checking.value);
    NSNumber *savingsNum = @(savings.value);
    NSArray *array = @[sum, checkingNum, savingsNum];
    completion(array);
  }
  //NOTE: This is redudant. Making it less though would require an additional paramter
  //(which we could wrap for the main thing), but at the end of the day we would still need
  //an additional method so I just allowed for reduncancy. It's a hackathon after all.
  else {
    [self getDataFromServer:^{
      RLMResults<Balance *> *balanceSavings = [Balance objectsWithPredicate:[NSPredicate predicateWithFormat:@"displayString == %@", kINKSavings]];
      RLMResults <Balance *> *balanceCheckings = [Balance objectsWithPredicate:[NSPredicate predicateWithFormat:@"displayString == %@", kINKChecking]];
      if(balanceSavings.count > 0 && balanceCheckings.count > 0) {
        Balance *checking = balanceCheckings[0];
        Balance *savings = balanceSavings[0];
        NSNumber *sum = @(checking.value + savings.value);
        NSNumber *checkingNum = @(checking.value);
        NSNumber *savingsNum = @(savings.value);
        NSArray *array = @[sum, checkingNum, savingsNum];
        completion(array);
      }
      else {
        completion(@[]);
      }
    }];
  }
  
}

-(void)getDataFromServer : (void (^)())completion {
  AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
  manager.responseSerializer = [AFJSONResponseSerializer serializer];
  manager.requestSerializer = [AFJSONRequestSerializer serializer];
  [manager.requestSerializer setValue:[JNKeychain loadValueForKey:@"auth_token"] forHTTPHeaderField:@"x-access-token"];
  [manager GET:@"http://api.getink.co/user/accounts" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    Balance *checking = [[Balance alloc]init];
    checking.displayString = kINKChecking;
    checking.value = ((NSNumber *)responseObject[@"accounts"][@"checking"][@"balance"]).floatValue;
    checking.updatedOn = [NSDate date];
    Balance *savings = [[Balance alloc]init];
    savings.displayString = kINKSavings;
    savings.value = ((NSNumber *)responseObject[@"accounts"][@"savings"][@"balance"]).floatValue;
    savings.updatedOn = [NSDate date];
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
      [realm addObject:checking];
      [realm addObject:savings];
      completion();
    }];
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    NSLog(@"error = %@", error);
    completion();
  }];
}

@end
