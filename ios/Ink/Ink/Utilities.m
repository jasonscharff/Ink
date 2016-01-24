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
    formatter.minimumFractionDigits = 2;
    formatter.roundingMode = NSNumberFormatterRoundUp;
    _sharedInstance = formatter;
  });

  NSString *numberString = [_sharedInstance stringFromNumber:@(number)];
  
  return [NSString stringWithFormat:@"$%@", numberString];
}

+ (NSString *)formatDateFromPlaid:(NSString *)original {
  static dispatch_once_t once;
  static NSDictionary *numberToMonths;
  dispatch_once(&once, ^{
    NSDictionary *dictionary = @{@"01":@"January", @"02" : @"February", @"03" : @"March", @"04" : @"April", @"05" : @"May", @"06" : @"June", @"07" : @"July", @"08" : @"August", @"09" : @"September", @"10" : @"October", @"11" : @"November", @"12" : @"December"};
    numberToMonths = dictionary;
  });
  
  NSString *year = [original substringWithRange:NSMakeRange(0, 4)];
  NSString *month = [original substringWithRange:NSMakeRange(5, 2)];
  NSString *day = [original substringWithRange:NSMakeRange(8, 2)];
  
  NSString *composite = [NSString stringWithFormat:@"%@ %@, %@", numberToMonths[month], day, year];
  
  return composite;
}


+ (NSString *)shortDateAsStringFromDate: (NSDate *)date {
  static dispatch_once_t once;
  static NSDateFormatter *_sharedInstance;
  dispatch_once(&once, ^{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM/dd/yy"];
    _sharedInstance = dateFormatter;
  });
  
  NSTimeInterval timeSinceDate = [[NSDate date] timeIntervalSinceDate:date];
  if(timeSinceDate < 24.0 * 60.0 * 60.0)
  {
    NSUInteger hoursSinceDate = (NSUInteger)(timeSinceDate / (60.0 * 60.0));
  
    if(hoursSinceDate == 0) {
      NSUInteger minutesSinceDate = (NSUInteger)(timeSinceDate / 60.0);
      if(minutesSinceDate == 1) {
        return @"1 minute ago";
      }
      else if (minutesSinceDate == 0) {
        NSUInteger secondsSinceDate = timeSinceDate;
        if(secondsSinceDate == 1) {
          return @"1 second ago";
        }
        else {
          return [NSString stringWithFormat:@"%i seconds ago", secondsSinceDate];
        }
      }
      return [NSString stringWithFormat:@"%i minutes ago", minutesSinceDate];
    }
    else if (hoursSinceDate == 1) {
      return @"1 hour ago";
    }
    else {
      return [NSString stringWithFormat:@"%d hours ago", hoursSinceDate];
    }
  }
  else {
   return [_sharedInstance stringFromDate:date];
  }
}

@end
