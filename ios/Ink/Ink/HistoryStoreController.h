//
//  HistoryStoreController.h
//  Ink
//
//  Created by Jason Scharff on 1/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HistoryStoreController : NSObject

+ (instancetype)sharedHistoryStoreController;
- (void)getLastMonthsHistory : (void (^)(NSArray * results))completion;


@end
