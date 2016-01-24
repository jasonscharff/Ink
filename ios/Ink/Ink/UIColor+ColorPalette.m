//
//  UIColor+ColorPalette.m
//  Ink
//
//  Created by Jason Scharff on 1/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "UIColor+ColorPalette.h"

@implementation UIColor(ColorPalette)

+ (UIColor *)inkGreen {
  return [self colorWithRed:46.f   / 255.0f
                      green:204.0f / 255.0f
                       blue:113.0f / 255.0f
                      alpha:1.f];
}

+ (UIColor *)inkRed {
  return [self colorWithRed:239.f   / 255.0f
                      green:72.0f / 255.0f
                       blue:54.0f / 255.0f
                      alpha:1.f];
}

+ (UIColor *)inkPurple {
  return [self colorWithRed:142.f   / 255.0f
                      green:68.0f / 255.0f
                       blue:173.0f / 255.0f
                      alpha:1.f];
}

@end
