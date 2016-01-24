//
//  Utilities.h
//  Ink
//
//  Created by Jason Scharff on 1/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;

@interface Utilities : NSObject

+ (NSString *)roundedDollarStringFromNumbers : (CGFloat)number;
+ (NSString *)formatDateFromPlaid : (NSString *)original;
+ (NSString *)shortDateAsStringFromDate: (NSDate *)date;
@end
