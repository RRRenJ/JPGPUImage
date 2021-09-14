//
//  JPFiltersAttributeModel.h
//  GPUImage
//
//  Created by FoundaoTEST on 2017/6/16.
//  Copyright © 2017年 Brad Larson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPFilterModel.h"
#import "GPUImageFilter.h"
#import "GPUImagePicture.h"
@interface JPFiltersAttributeModel : NSObject

@property (nonatomic, strong) GPUImagePicture *rgbPicture;
@property (nonatomic, strong) GPUImagePicture *r_g_bPicture;
@property (nonatomic, assign) BOOL changedFilter;
@property (nonatomic, assign) BOOL changeHue;
@property (nonatomic, assign) BOOL changeRGB;
@property (nonatomic, assign) BOOL changeR1G1B1;
@property (nonatomic, assign) BOOL changeSaturation;
@property (nonatomic, assign) BOOL changeSaturationOne;

@property (nonatomic, assign) CGFloat saturation;
@property (nonatomic, assign) GPUVector3 hueWeight;
@property (nonatomic, assign) NSInteger filterType;
- (void)setHueWeightWithOne:(CGFloat)one two:(CGFloat)two three:(CGFloat)three;
+ (instancetype)shareInstanceFilters;


@end

