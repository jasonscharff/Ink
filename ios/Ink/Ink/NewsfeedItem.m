//
//  NewsfeedItem.m
//  Ink
//
//  Created by Jason Scharff on 1/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "NewsfeedItem.h"

@implementation NewsfeedItem


-(void)configureSelfFromResponse : (NSDictionary *)response {
  self.contents = response[@"message"];
  self.isPenalty = [response[@"penalty"]boolValue];
  self.timestamp = [NSDate dateWithTimeIntervalSince1970:[response[@"timestamp"] doubleValue]];
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
