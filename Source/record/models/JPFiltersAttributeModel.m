//
//  JPFiltersAttributeModel.m
//  GPUImage
//
//  Created by FoundaoTEST on 2017/6/16.
//  Copyright © 2017年 Brad Larson. All rights reserved.
//

#import "JPFiltersAttributeModel.h"

@implementation JPFiltersAttributeModel

- (instancetype)init
{
    if (self = [super init]) {
        _changedFilter = NO;
        _changeHue = NO;
        _changeSaturation = NO;
        _changeRGB = NO;
        _changeR1G1B1 = NO;
        _filterType = 0;
        _changeSaturationOne = NO;
    }
    return self;
}


- (void)setHueWeightWithOne:(CGFloat)one two:(CGFloat)two three:(CGFloat)three
{
    _hueWeight.one = one;
    _hueWeight.two = two;
    _hueWeight.three = three;
}

+ (instancetype)shareInstanceFilters
{
    static JPFiltersAttributeModel * filterAttributeModel = nil;
    if (filterAttributeModel == nil) {
        filterAttributeModel = [[JPFiltersAttributeModel alloc] init];
    }
    return filterAttributeModel;
}
@end
