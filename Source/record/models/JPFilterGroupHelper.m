//
//  JPFilterGroupHelper.m
//  jper
//
//  Created by FoundaoTEST on 2017/3/27.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#import "JPFilterGroupHelper.h"
#import "JPRiseFilter.h"
#import "JPHudsonFilter.h"
#import "JPInkwellFilter.h"
#import "JPWaldenFilter.h"
#import "JPAncientFilter.h"
#import "JPLarkFilter.h"
#import "GPUImageCropFilter.h"
#import "GPUImagePicture.h"
#import "JPTranstionsDefault.h"
#import "JPPublicConstant.h"
@interface JPFilterGroupHelper ()
@property (nonatomic, strong) GPUImageFilterGroup *filterGroup;
@property (nonatomic, strong) GPUImageCropFilter *cropFilter;
@property (nonatomic, strong) NSMutableArray *filters;
@property (nonatomic, assign) CGSize cameraSize;
@property (nonatomic) JPVideoAspectRatio aspectRatio;

@property (nonatomic, strong) GPUImageFilter *filter;
@property (nonatomic, strong) GPUImagePicture *sourcePicture1;
@property (nonatomic, strong) GPUImagePicture *sourcePicture2;
@property (nonatomic, strong) GPUImagePicture *sourcePicture3;
@property (nonatomic, strong) GPUImagePicture *sourcePicture4;
@property (nonatomic, strong) GPUImagePicture *sourcePicture5;

@end

@implementation JPFilterGroupHelper

- (instancetype)initWithCameraSize:(CGSize)size
{
    if (self = [self init]) {
        _cameraSize = size;
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        _filters = [NSMutableArray array];
        _isCrop = YES;
    }
    return self;
}

- (GPUImageFilterGroup *)switchToNewFilterTypewithSessionPreset:(JPVideoAspectRatio)sessionPreset withStickersFilters:(NSArray *)stickersFilter withCopyrightFilter:(JPCopyrightFilter *)copyrightFilter andCircularFilter:(JPCircularFilter *)circularFilter andFilterDelegate:(id<JPGeneralFilterDelegate>)filterDelegate{
    @synchronized (self) {
        [self destruction];
        _filterGroup = [[GPUImageFilterGroup alloc] init];
        _filter = nil;
        [self generalImageFilter];
        [self switchFilterTypeWithFilterManager:filterDelegate];
        if (_filter){
            [self addGPUImageFilters:_filter];
            _filter.isAddVideoEnd = YES;
            _filter.videoTotalDuration = _videoDuration;
        }
        for (JPStickersFilter *filter in stickersFilter) {
            [self addGPUImageFilters:filter];
        }
        if (circularFilter != nil) {
            [self addGPUImageFilters:circularFilter];
        }
        if (copyrightFilter != nil) {
            [self addGPUImageFilters:copyrightFilter];
        }
        return _filterGroup;
        
    }
    
}

- (void)switchFilterTypeWithFilterManager:(id<JPGeneralFilterDelegate>)filterDelegate
{
     [(JPGeneralFilter *)_filter setFilterDelegate:filterDelegate];
}

- (void )generalImageFilter
{
    _filter = [[JPGeneralFilter alloc] init];
}

- (void)setVideoDuration:(CMTime)videoDuration
{
    _videoDuration = videoDuration;
    _filter.isAddVideoEnd = YES;
    _filter.videoTotalDuration = _videoDuration;
}

- (GPUImageFilterGroup *)switchToNewFilterType:(BOOL)hasFilter withSessionPreset:(JPVideoAspectRatio)sessionPreset
andFilterDelegate:(id<JPGeneralFilterDelegate>)filterDelegate
{
    @synchronized (self) {
        [self destruction];
        _filterGroup = [[GPUImageFilterGroup alloc] init];
        if (sessionPreset != JPVideoAspectRatioNomal && _isCrop == YES) {
            _cropFilter = [[GPUImageCropFilter alloc] init];
            _aspectRatio = sessionPreset;
            _cropFilter.cropRegion = [self getLocalVideoCropSizeWithOriginSize:self.cameraSize];
            [self addGPUImageFilters:_cropFilter];
        }
        _filter = nil;
        if (hasFilter) {
            [self generalImageFilter];
            [self switchFilterTypeWithFilterManager:filterDelegate];
        }
        if (_filter){
            [self addGPUImageFilters:_filter];
        }
        return _filterGroup;
        
    }
}
- (CGSize)cropSize
{
    return _cropFilter.cropRegion.size;
}
- (CGRect)getLocalVideoCropSizeWithOriginSize:(CGSize)originSize
{
    CGRect videoCropRect = CGRectZero;
    CGFloat ratio = 16.0 / 9.0f;
    CGFloat width = 1.0;
    CGFloat height = 1.0;
    if (_aspectRatio == JPVideoAspectRatio9X16) {
        ratio = 9.0 / 16.0f;
    }else if (_aspectRatio == JPVideoAspectRatio1X1 || _aspectRatio == JPVideoAspectRatioCircular){
        ratio = 1.0 / 1.0f;
    }else if (_aspectRatio == JPVideoAspectRatio4X3)
    {
        ratio = 4.0 / 3.0;
    }
    if (originSize.width / originSize.height <= ratio) {
        height = (originSize.width / ratio) / originSize.height;
    }else{
        width = (originSize.height * ratio) / originSize.width;
    }
    videoCropRect = CGRectMake((1.0 - width) / 2.0, (1.0 - height) / 2.0, width, height);
    return videoCropRect;
}


- (void)addGPUImageFilters:(GPUImageOutput<GPUImageInput> *)filter
{
    [_filterGroup addFilter:filter];
    [_filters addObject:filter];
    GPUImageOutput<GPUImageInput> *newTerminalFilter = filter;
    NSInteger count = _filterGroup.filterCount;
    if (count == 1)
    {
        _filterGroup.initialFilters = @[newTerminalFilter];
        _filterGroup.terminalFilter = newTerminalFilter;
        
    } else
    {
        GPUImageOutput<GPUImageInput> *terminalFilter    = _filterGroup.terminalFilter;
        NSArray *initialFilters                          = _filterGroup.initialFilters;
        [terminalFilter addTarget:newTerminalFilter];
        _filterGroup.initialFilters = @[initialFilters[0]];
        _filterGroup.terminalFilter = newTerminalFilter;
    }
}

- (void)destruction
{
    [_filter removeAllTargets];
    [_filterGroup removeAllTargets];
    NSArray *filtersArr = _filters.copy;
    for (JPUIImageFilter *filter in filtersArr) {
        [filter removeAllTargets];
    }
    [_filters removeAllObjects];
    [_sourcePicture1 removeAllTargets];
    [_sourcePicture2 removeAllTargets];
    [_sourcePicture3 removeAllTargets];
    [_sourcePicture4 removeAllTargets];
    [_sourcePicture5 removeAllTargets];
  
}

- (void)dealloc
{
    
}
@end
