//
//  JPFilterGroupHelper.h
//  jper
//
//  Created by FoundaoTEST on 2017/3/27.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPFilterModel.h"
#import "JPVideoRecordInfo.h"
#import "JPStickersFilter.h"
#import "JPCopyrightFilter.h"
#import "JPCircularFilter.h"
#import "GPUImageFilterGroup.h"
#import "JPGeneralFilter.h"
@interface JPFilterGroupHelper : NSObject
- (instancetype)initWithCameraSize:(CGSize)size;
@property (nonatomic, readonly) CGSize cropSize;
@property (nonatomic, assign) BOOL isCrop;
- (GPUImageFilterGroup *)
switchToNewFilterType:(BOOL)hasFilter
withSessionPreset:(JPVideoAspectRatio)sessionPreset
andFilterDelegate:(id<JPGeneralFilterDelegate>)filterDelegate;
- (void)destruction;
- (GPUImageFilterGroup *)
switchToNewFilterTypewithSessionPreset:(JPVideoAspectRatio)sessionPreset
withStickersFilters:(NSArray *)stickersFilter
withCopyrightFilter:(JPCopyrightFilter *)copyrightFilter
andCircularFilter:(JPCircularFilter *)circularFilter
andFilterDelegate:(id<JPGeneralFilterDelegate>)filterDelegate;
- (void)switchFilterTypeWithFilterManager:(id<JPGeneralFilterDelegate>)filterDelegate;
- (void)addGPUImageFilters:(GPUImageOutput<GPUImageInput> *)filter;
@property (nonatomic, assign) CMTime videoDuration;
@end
