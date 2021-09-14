//
//  JPTemplateCompositionPlayer.m
//  GPUImage
//
//  Created by FoundaoTEST on 2017/9/13.
//  Copyright © 2017年 Brad Larson. All rights reserved.
//

#import "JPTemplateCompositionPlayer.h"
#import "JPTemplateFilter.h"
@interface JPTemplateCompositionPlayer ()


@property (nonatomic, strong) JPTemplateFilter *templateFilter;

@end


@implementation JPTemplateCompositionPlayer






- (instancetype)initWithRecordInfo:(JPTemplateCompositionInfo *)videoInfo withComposition:(BOOL)isComposition
{
    if (self = [super initWithIsComposition:isComposition andRecordInfo:videoInfo]) {
        _videoRecordInfo = videoInfo;
        _templateFilter = [[JPTemplateFilter alloc] init];
        [self addGPUImageFilters:_templateFilter];
        _templateFilter.compostionInfo = videoInfo;
        self.generalFilter = [[JPGeneralFilter alloc] init];
        self.generalFilter.filterDelegate = videoInfo.filterDelegate;
        [self addGPUImageFilters:self.generalFilter];
        self.stickersFilter = [[JPStickersFilter alloc] initWithNeedCircular:NO];
        self.stickersFilter.totalDuration = self.compositon.duration;
        self.stickersFilter.videoSize = videoInfo.videoSize;
        [self addGPUImageFilters:self.stickersFilter];
        [self removeAllTargets];
        [self addTarget:self.filterGroup];
        [self.filterGroup addTarget:self.gpuImageView];
    }
    return self;
}






- (void)destruction
{
    [super destruction];
    [self.templateFilter endProcessing];
}




- (void)scrollToWatchThumImageWithTime:(CMTime)time
{
    [self scrollToWatchThumImageWithTime:time withSticker:YES];
}


- (void)startToRenderFrameAtTime:(CMTime)currentSampleTime
{
    NSMutableArray *dataArr = nil;
    dataArr = [NSMutableArray array];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(videoCompositionPlayerPlayAtTime:andAndStickerArr:andNeedApear:)])
        {
            [self.delegate videoCompositionPlayerPlayAtTime:currentSampleTime andAndStickerArr:dataArr andNeedApear:NO];
        }
    });
}

@end
