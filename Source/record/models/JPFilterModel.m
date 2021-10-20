//
//  JPFilterModel.m
//  jper
//
//  Created by FoundaoTEST on 2017/3/24.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#import "JPFilterModel.h"
#import "JPPublicConstant.h"

@implementation JPFilterModel
//+ (NSArray<JPFilterModel *> *)loadAllFilterModel
//{
//    NSMutableArray *dataArr = [NSMutableArray array];
//    
//    for (NSInteger index = 0 ; index < 11; index++) {
//        JPFilterModel *filterModel = [[JPFilterModel alloc] init];
//        NSString *numbers = [NSString stringWithFormat:@"0%ld", (long)(index + 1)];
//        if ((index + 1) >= 10) {
//            numbers = [NSString stringWithFormat:@"%ld", (long)(index + 1)];
//        }
//        if (index > 0) {
//            filterModel.thumbImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@-1", numbers]];
//        }
//        filterModel.filterNumberString = numbers;
//        filterModel.filterType = index;
//        switch (filterModel.filterType) {
//            case JPFilterNomal:
//                filterModel.isSelect = YES;
//                filterModel.filterName = @"ORIGINAL";
//                filterModel.filterCNName = @"原生";
//                break;
//            case JPFilterGreen:
//                filterModel.filterName = @"GREEN";
//                filterModel.filterCNName = @"绿光";
//                break;
//            case JPFilterNeverSeeAgian:
//                filterModel.filterName = @"NERVER SEE AGIAN";
//                filterModel.filterCNName = @"后会无期";
//                break;
//            case JPFilterHotelCalifornia:
//                filterModel.filterName = @"HOTEL CALIFORNIA";
//                filterModel.filterCNName = @"加州旅馆";
//                break;
//            case JPFilterEternalSummer:
//                filterModel.filterName = @"ETERNAL SUMMER";
//                filterModel.filterCNName = @"盛夏光年";
//                break;
//            case JPFilterLoveActually:
//                filterModel.filterName = @"LOVE ACTUALLY";
//                filterModel.filterCNName = @"真爱至上";
//                break;
//            case JPFilterColorOfNight:
//                filterModel.filterName = @"COLOR OF NIGHT";
//                filterModel.filterCNName = @"夜色";
//                break;
//            case JPFilterDyingLight:
//                filterModel.filterName = @"DYING LIGHT";
//                filterModel.filterCNName = @"消逝的光芒";
//                break;
//            case JPFilterGameOfRights:
//                filterModel.filterName = @"GAME OF THRONES";
//                filterModel.filterCNName = @"权利的游戏";
//                break;
//            case JPFilterModernTimes:
//                filterModel.filterName = @"MODERN TIMES";
//                filterModel.filterCNName = @"摩登时代";
//                break;
//            case JPFilterLoveLetter:
//                filterModel.filterName = @"LOVE LETTER";
//                filterModel.filterCNName = @"情书";
//                break;
//            default:
//                break;
//        }
//        [dataArr addObject:filterModel];
//    }
//    
//    return dataArr;
//}

//+ (NSArray<JPFilterModel *> *)loadAllFilterModel
//{
//    NSMutableArray *dataArr = [NSMutableArray array];
//    
//    for (NSInteger index = 0 ; index < 11; index++) {
//        JPFilterModel *filterModel = [[JPFilterModel alloc] init];
//        NSString *numbers = [NSString stringWithFormat:@"0%ld", (long)(index + 1)];
//        if ((index + 1) >= 10) {
//            numbers = [NSString stringWithFormat:@"%ld", (long)(index + 1)];
//        }
//        if (index > 0) {
//            filterModel.thumbImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@-1", numbers]];
//        }
//        filterModel.filterNumberString = numbers;
//        filterModel.filterType = index;
//        switch (filterModel.filterType) {
//            case JPFilterNomal:
//                filterModel.isSelect = YES;
//                filterModel.filterName = @"ORIGINAL";
//                filterModel.filterCNName = @"原生";
//                break;
//            case JPFilterGreen:
//                filterModel.filterName = @"GREEN";
//                filterModel.filterCNName = @"绿光";
//                break;
//            case JPFilterNeverSeeAgian:
//                filterModel.filterName = @"NERVER SEE AGIAN";
//                filterModel.filterCNName = @"后会无期";
//                break;
//            case JPFilterHotelCalifornia:
//                filterModel.filterName = @"HOTEL CALIFORNIA";
//                filterModel.filterCNName = @"加州旅馆";
//                break;
//            case JPFilterEternalSummer:
//                filterModel.filterName = @"ETERNAL SUMMER";
//                filterModel.filterCNName = @"盛夏光年";
//                break;
//            case JPFilterLoveActually:
//                filterModel.filterName = @"LOVE ACTUALLY";
//                filterModel.filterCNName = @"真爱至上";
//                break;
//            case JPFilterColorOfNight:
//                filterModel.filterName = @"COLOR OF NIGHT";
//                filterModel.filterCNName = @"夜色";
//                break;
//            case JPFilterDyingLight:
//                filterModel.filterName = @"DYING LIGHT";
//                filterModel.filterCNName = @"消逝的光芒";
//                break;
//            case JPFilterGameOfRights:
//                filterModel.filterName = @"GAME OF THRONES";
//                filterModel.filterCNName = @"权利的游戏";
//                break;
//            case JPFilterModernTimes:
//                filterModel.filterName = @"MODERN TIMES";
//                filterModel.filterCNName = @"摩登时代";
//                break;
//            case JPFilterLoveLetter:
//                filterModel.filterName = @"LOVE LETTER";
//                filterModel.filterCNName = @"情书";
//                break;
//            default:
//                break;
//        }
//        [dataArr addObject:filterModel];
//    }
//    
//    return dataArr;
//}

- (NSMutableDictionary *)configueDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:_thumbImageName forKey:@"thumbImageName"];
    [dict setObject:@(_filterType) forKey:@"filterType"];
    [dict setObject:_filterNumberString forKey:@"filterNumberString"];
    [dict setObject:_filterCNName forKey:@"filterCNName"];
    return dict;
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }else if ([object isKindOfClass:[self class]])
    {
        JPFilterModel *filterModel = (JPFilterModel *)object;
        return filterModel.filterType == self.filterType;
    }else{
        return NO;
    }
}

- (void)updateInfoWithDict:(NSDictionary *)dict
{
    self.thumbImageName = [dict objectForKey:@"thumbImageName"];
    self.filterType = [[dict objectForKey:@"filterType"] integerValue];
    self.filterNumberString = [dict objectForKey:@"filterNumberString"];
    self.filterCNName = [dict objectForKey:@"filterCNName"];
}


- (UIImage *)thumbImage
{
    return [UIImage imageNamed:_thumbImageName inBundle:JP_Resource_bundle compatibleWithTraitCollection:nil];
}

@end
