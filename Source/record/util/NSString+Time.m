//
//  NSString+Time.m
//  jper
//
//  Created by FoundaoTEST on 2017/3/29.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#import "NSString+Time.h"

@implementation NSString (Time)
+ (NSString *)stringWithTimeInterval:(NSInteger)timeInterval
{
    NSInteger minute = timeInterval / 60;
    NSInteger second = timeInterval % 60;
    NSString *minuteStr;
    NSString *secondStr;
    if (minute < 10) {
        minuteStr = [NSString stringWithFormat:@"0%ld",(long)minute];
    }else{
        minuteStr = [NSString stringWithFormat:@"%ld",(long)minute];
    }
    if (second < 10) {
        secondStr = [NSString stringWithFormat:@"0%ld",(long)second];
    }else{
        secondStr = [NSString stringWithFormat:@"%ld",(long)second];
    }
    return [NSString stringWithFormat:@"%@:%@",minuteStr, secondStr];
}

@end
