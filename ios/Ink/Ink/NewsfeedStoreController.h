//
//  NewsfeedStoreController.h
//  Ink
//
//  Created by Jason Scharff on 1/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsfeedStoreController : NSObject

+ (instancetype)sharedNewsfeedStoreController;
-(void)getItemsFromServer : (void (^)(NSArray * items))completion;

@end
