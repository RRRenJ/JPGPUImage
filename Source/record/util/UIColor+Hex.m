//
//  UIColor+Hex.m
//  GPUImage
//
//  Created by FoundaoTEST on 2017/9/13.
//  Copyright © 2017年 Brad Larson. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)
+ (UIColor *)colorWithNumber:(long)number
{
    return [self colorWithRed:(CGFloat)((number & 0xFF0000) >> 16) / 255.0 green:(CGFloat)((number & 0xFF00) >> 8) / 255.0 blue:(CGFloat)((number & 0xFF)) / 255.0 alpha:1.0];
}
@end
