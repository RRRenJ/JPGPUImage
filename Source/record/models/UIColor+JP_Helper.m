//
//  UIColor+JP_Helper.m
//  GPUImage
//
//  Created by Mu Xiao on 2019/11/12.
//  Copyright © 2019 Brad Larson. All rights reserved.
//

#import "UIColor+JP_Helper.h"



@implementation UIColor (JP_Helper)

- (NSString *)jp_helper_hexString
{
    CGFloat red, green, blue, alpha;
    
    [self jp_helper_getRed:&red green:&green blue:&blue alpha:&alpha];
    red = roundf(red * 255.f);
    green = roundf(green * 255.f);
    blue = roundf(blue * 255.f);
    alpha = roundf(alpha * 255.f);
    
    uint hex = ((uint)alpha << 24) | ((uint)red << 16) | ((uint)green << 8) | ((uint)blue);
    
    return [NSString stringWithFormat:@"#%08x", hex];
}


- (void)jp_helper_getRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha
{
    #if SD_UIKIT
        if (![self getRed:&red green:&green blue:&blue alpha:&alpha]) {
            [self getWhite:&red alpha:&alpha];
            green = red;
            blue = red;
        }
    #else
        @try {
            [self getRed:red green:green blue:blue alpha:alpha];
        }
        @catch (NSException *exception) {
            [self getWhite:red alpha:alpha];
            *green = *red;
            *blue = *red;
        }
    #endif
}

+ (CGFloat)jp_helper_colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

+ (UIColor *)jp_helper_colorWithHexString:(NSString *)hexString
{
    if (hexString.length <= 0) return nil;
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self jp_helper_colorComponentFrom: colorString start: 0 length: 1];
            green = [self jp_helper_colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self jp_helper_colorComponentFrom: colorString start: 2 length: 1];
            break;
        case 4: // #ARGB
            alpha = [self jp_helper_colorComponentFrom: colorString start: 0 length: 1];
            red   = [self jp_helper_colorComponentFrom: colorString start: 1 length: 1];
            green = [self jp_helper_colorComponentFrom: colorString start: 2 length: 1];
            blue  = [self jp_helper_colorComponentFrom: colorString start: 3 length: 1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self jp_helper_colorComponentFrom: colorString start: 0 length: 2];
            green = [self jp_helper_colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self jp_helper_colorComponentFrom: colorString start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            alpha = [self jp_helper_colorComponentFrom: colorString start: 0 length: 2];
            red   = [self jp_helper_colorComponentFrom: colorString start: 2 length: 2];
            green = [self jp_helper_colorComponentFrom: colorString start: 4 length: 2];
            blue  = [self jp_helper_colorComponentFrom: colorString start: 6 length: 2];
            break;
        default: {
            NSAssert(NO, @"Color value %@ is invalid. It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString);
            return nil;
        }
            break;
    }
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];

    
}

@end
