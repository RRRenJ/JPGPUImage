//
//  JPStickersFilter.h
//  jper
//
//  Created by FoundaoTEST on 2017/4/11.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#import "GPUImageFilter.h"

@interface JPStickersFilter : GPUImageFilter
@property (nonatomic, assign) CMTime totalDuration;
@property (nonatomic, assign) CGSize videoSize;
- (instancetype)initWithNeedCircular:(BOOL)isCircular;
@property (nonatomic, assign) BOOL needSticker;
- (void)setInputStickersArr:(NSArray *)stickersArr andCurrentTime:(CMTime)time;
- (void)filterStikersShouldBeNone;
@end
