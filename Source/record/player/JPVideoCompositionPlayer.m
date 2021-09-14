//
//  JPVideoCompositionPlayer.m
//  jper
//
//  Created by FoundaoTEST on 2017/4/6.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#import "JPVideoCompositionPlayer.h"
#import "JPFilterGroupHelper.h"
#import "JPStickersFilter.h"
#import "GPUImageMovieWriter.h"
#import "JPVideoUtil.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "JPCircularFilter.h"
@interface JPVideoCompositionPlayer ()


@property (nonatomic, strong) NSMutableArray *packagePatternArray;
@property (nonatomic, assign) BOOL isSticker;
@end

@implementation JPVideoCompositionPlayer


- (instancetype)initWithRecordInfo:(JPVideoRecordInfo *)videoInfo withStickers:(BOOL)sticker withComposition:(BOOL)isComposition
{
    if (self = [super initWithIsComposition:isComposition andRecordInfo:videoInfo]) {
        _videoRecordInfo = videoInfo;
        _isSticker = sticker;
        self.stickersFilter = [[JPStickersFilter alloc] initWithNeedCircular:(videoInfo.aspectRatio == JPVideoAspectRatioCircular)];
        self.stickersFilter.totalDuration = videoInfo.totalVideoDuraion;
        self.stickersFilter.videoSize = videoInfo.videoSize;
        _packagePatternArray = [NSMutableArray array];
        self.generalFilter = [[JPGeneralFilter alloc] init];
        self.generalFilter.filterDelegate = videoInfo.filterDelegate;
        [self addGPUImageFilters:self.generalFilter];
        [self addGPUImageFilters:self.stickersFilter];
        [self removeAllTargets];
        [self addTarget:self.filterGroup];
        [self.filterGroup addTarget:self.gpuImageView];
    }
    return self;
}

- (instancetype)initWithRecordInfo:(JPVideoRecordInfo *)videoInfo withComposition:(BOOL)isComposition
{
    if (self = [self initWithRecordInfo:videoInfo withStickers:NO withComposition:isComposition]) {
   
    }
    return self;
}

- (void)addPackagePattern:(JPPackagePatternAttribute *)pagePattern
{

    if ([_packagePatternArray containsObject:pagePattern]) {
        return;
    }
    [_packagePatternArray addObject:pagePattern];
  
}


- (void)removePackagePattern:(JPPackagePatternAttribute *)pagePattern
{
    if ([_packagePatternArray containsObject:pagePattern]) {
        [_packagePatternArray removeObject:pagePattern];
    }
}


- (void)startToRenderFrameAtTime:(CMTime)currentSampleTime
{
    NSMutableArray *dataArr = nil;
    dataArr = [NSMutableArray array];
    for (JPPackagePatternAttribute *pattern in _packagePatternArray) {
        CMTimeRange timeRange = pattern.timeRange;
        if (CMTimeCompare(currentSampleTime, timeRange.start) > 0 && CMTimeCompare(currentSampleTime, CMTimeAdd(timeRange.start, timeRange.duration)) < 0) {
            [dataArr addObject:pattern];
        }else if (pattern.isGlod == YES)
        {
            [dataArr addObject:pattern];
        }
    }
    BOOL needApearSticker = NO;
    if (_isSticker && (self.isPlaying == YES || self.stopWithSticker == YES) && CMTimeCompare(currentSampleTime, self.recordInfo.totalVideoDuraion) < 0) {
        [self.stickersFilter setInputStickersArr:dataArr andCurrentTime:currentSampleTime];
        needApearSticker = YES;
    }else{
        [self.stickersFilter filterStikersShouldBeNone];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(videoCompositionPlayerPlayAtTime:andAndStickerArr:andNeedApear:)])
        {
            [self.delegate videoCompositionPlayerPlayAtTime:currentSampleTime andAndStickerArr:dataArr andNeedApear:!needApearSticker];
        }
    });
}














@end
