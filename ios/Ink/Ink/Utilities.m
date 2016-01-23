//
//  Utilities.m
//  Ink
//
//  Created by Jason Scharff on 1/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+ (NSString *)roundedDollarStringFromNumbers : (CGFloat)number {
  
  static dispatch_once_t once;
  static NSNumberFormatter *_sharedInstance;
  dispatch_once(&once, ^{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.maximumFractionDigits = 2;
    formatter.roundingMode = NSNumberFormatterRoundUp;
    _sharedInstance = formatter;
  });

  NSString *numberString = [_sharedInstance stringFromNumber:@(number)];
  
  return [NSString stringWithFormat:@"$%@", numberString];
}

@end
