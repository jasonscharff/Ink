//
//  SendMoneyStoreController.m
//  Ink
//
//  Created by Jason Scharff on 1/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "SendMoneyStoreController.h"

#import "AFHTTPSessionManager.h"
#import "JNKeyChain.h"


@implementation SendMoneyStoreController

+ (instancetype)sharedSendMoneyStoreController {
  static dispatch_once_t once;
  static SendMoneyStoreController *_sharedInstance;
  dispatch_once(&once, ^{
    _sharedInstance = [[self alloc] init];
  });
  
  return _sharedInstance;
}

-(void)saveMoney : (NSString *)amount {
  if([amount characterAtIndex:0] == '$') {
    amount = [amount substringWithRange:NSMakeRange(1, [amount length]-1)];
  }
  AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
  manager.responseSerializer = [AFJSONResponseSerializer serializer];
  manager.requestSerializer = [AFJSONRequestSerializer serializer];
  [manager.requestSerializer setValue:[JNKeychain loadValueForKey:@"auth_token"] forHTTPHeaderField:@"x-access-token"];
  
  NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
  f.numberStyle = NSNumberFormatterDecimalStyle;
  NSNumber *amountNum = [f numberFromString:amount];
  
  NSDictionary *params = @{@"amount" : amountNum};
  
  [manager POST:@"http://api.getink.co/user/transfer" parameters:params constructingBodyWithBlock:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
      NSLog(@"response object = %@", responseObject);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
      NSLog(@"error = %@", error);
  }];

}

@end
