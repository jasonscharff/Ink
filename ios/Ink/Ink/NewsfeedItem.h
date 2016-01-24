//
//  NewsfeedItem.h
//  Ink
//
//  Created by Jason Scharff on 1/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <Realm/Realm.h>

@interface NewsfeedItem : RLMObject

-(void)configureSelfFromResponse : (NSDictionary *)response;

@property NSString *contents;
@property BOOL isPenalty;
@property NSDate *timestamp;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<NewsfeedItem>
RLM_ARRAY_TYPE(NewsfeedItem)
