//
//  UIColor+JP_Helper.h
//  GPUImage
//
//  Created by Mu Xiao on 2019/11/12.
//  Copyright © 2019 Brad Larson. All rights reserved.
//



#import <UIKit/UIKit.h>


@interface UIColor (JP_Helper)

- (NSString *)jp_helper_hexString;
+ (UIColor *)jp_helper_colorWithHexString:(NSString *)hexString;
- (void)jp_helper_getRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha;

@end

