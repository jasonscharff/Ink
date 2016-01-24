//
//  NewsfeedStoreController.m
//  Ink
//
//  Created by Jason Scharff on 1/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "NewsfeedStoreController.h"

#import "AFHTTPSessionManager.h"
#import "JNKeychain.h"
#import "NewsfeedItem.h"

@implementation NewsfeedStoreController

+ (instancetype)sharedNewsfeedStoreController {
  static dispatch_once_t once;
  static NewsfeedStoreController *_sharedInstance;
  dispatch_once(&once, ^{
    _sharedInstance = [[self alloc] init];
  });
  
  return _sharedInstance;
}

-(void)getItemsFromServer : (void (^)(NSArray * items))completion {
  AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
  manager.responseSerializer = [AFJSONResponseSerializer serializer];
  manager.requestSerializer = [AFJSONRequestSerializer serializer];
  [manager.requestSerializer setValue:[JNKeychain loadValueForKey:@"auth_token"] forHTTPHeaderField:@"x-access-token"];
  [manager GET:@"http://api.getink.co/user/feed" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    NSLog(@"reponse obj = %@", responseObject);
    [self clearCache];
    [self saveResponseObject:responseObject];
    NSArray *items = [self queryItems];
    completion(items);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    NSLog(@"error = %@", error);
  }];
}

-(void)saveResponseObject : (NSDictionary *)response {
  RLMRealm *realm = [RLMRealm defaultRealm];
  NSArray *items = response[@"feed"];
  [[RLMRealm defaultRealm] beginWriteTransaction];
  for (NSDictionary *item in items) {
    NewsfeedItem *newsfeeditem = [[NewsfeedItem alloc]init];
    [newsfeeditem configureSelfFromResponse:item];
    [realm addObject:newsfeeditem];
  }
  [[RLMRealm defaultRealm] commitWriteTransaction];

}

-(void)clearCache {
    RLMResults *feed = [NewsfeedItem allObjects];
    [[RLMRealm defaultRealm] beginWriteTransaction];
    [[RLMRealm defaultRealm] deleteObjects:feed];
    [[RLMRealm defaultRealm] commitWriteTransaction];
}


-(NSArray *)queryItems {
  NSMutableArray *array = [[NSMutableArray alloc]init];
  RLMResults *results = [[NewsfeedItem allObjects]sortedResultsUsingProperty:@"timestamp" ascending:NO];
  for (NewsfeedItem *item in results) {
    [array addObject:item];
  }
  return array;
}

@end
