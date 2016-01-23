//
//  HistoryStoreController.m
//  Ink
//
//  Created by Jason Scharff on 1/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "HistoryStoreController.h"

#import "AFHTTPSessionManager.h"
#import "JNKeychain.h"
#import "Transaction.h"

@implementation HistoryStoreController

+ (instancetype)sharedHistoryStoreController {
  static dispatch_once_t once;
  static HistoryStoreController *_sharedInstance;
  dispatch_once(&once, ^{
    _sharedInstance = [[self alloc] init];
  });
  
  return _sharedInstance;
}

-(void)getLastMonthsHistory : (void (^)(NSArray * results))completion {
  AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
  manager.responseSerializer = [AFJSONResponseSerializer serializer];
  manager.requestSerializer = [AFJSONRequestSerializer serializer];
  [manager.requestSerializer setValue:[JNKeychain loadValueForKey:@"auth_token"] forHTTPHeaderField:@"x-access-token"];
  [manager GET:@"http://api.getink.co/user/transactions" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    [self saveResponseObject:responseObject];
    completion([self queryAllObjects]);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    NSLog(@"error = %@", error);
    completion(@[]);
  }];
  
}

-(void)saveResponseObject : (NSArray *)responseObject {
  RLMRealm *realm = [RLMRealm defaultRealm];
  if(responseObject.count > 0) {
    [self wipeRealm];
  }
  [[RLMRealm defaultRealm] beginWriteTransaction];
  NSLog(@"response object = %@", responseObject);
  for (NSDictionary *object in responseObject) {
    Transaction *transaction = [[Transaction alloc]init];
    [transaction configureFromResponse:object];
    [realm addObject:transaction];
  }
  [[RLMRealm defaultRealm] commitWriteTransaction];
}

-(void)wipeRealm {
  RLMResults *transactions = [Transaction allObjects];
  [[RLMRealm defaultRealm] beginWriteTransaction];
  [[RLMRealm defaultRealm] deleteObjects:transactions];
  [[RLMRealm defaultRealm] commitWriteTransaction];
}

-(NSArray *)queryAllObjects {
  NSMutableArray *array = [[NSMutableArray alloc]init];
  RLMResults *results = [Transaction allObjects];
  for (Transaction *t in results) {
    [array addObject:t];
  }
  return array;
}


@end