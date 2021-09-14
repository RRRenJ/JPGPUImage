//
//  JPBaseCompositionPlayer.h
//  GPUImage
//
//  Created by FoundaoTEST on 2017/10/17.
//  Copyright © 2017年 Brad Larson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPVideoCamera.h"
#import "GPUImageFilterGroup.h"
#import "JPStickersFilter.h"
#import "JPBaseVideoRecordInfo.h"
#import "JPPublicConstant.h"
#import "JPVideoUtil.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
@protocol JPVideoCompositionPlayerDelegate <NSObject>
- (void)videoCompositionPlayerPlayAtTime:(CMTime)time andAndStickerArr:(NSArray *)patternArr andNeedApear:(BOOL)needApear;
- (void)videoCompositionPlayerWillPasue;
- (void)videoCompositionPlayerWillPlaying;
@end

@interface JPBaseCompositionPlayer : GPUImageOutput<AVPlayerItemOutputPullDelegate>

@property (nonatomic, assign, readonly) BOOL isPlaying;
@property (nonatomic, strong) GPUImageView *gpuImageView;
@property (nonatomic, readonly) CMTime videoDuration;
@property (nonatomic, assign) BOOL playAtActualSpeed;
@property(readwrite, nonatomic) BOOL runBenchmark;
@property (nonatomic, strong) AVMutableComposition *compositon;
@property (nonatomic, strong) AVMutableVideoComposition *videoComposition;
@property (nonatomic, strong) NSURL *savedAssetUrl;
@property (nonatomic, assign) BOOL audioMute;
@property (nonatomic, copy) void(^updateProgressBlock)(CGFloat progress);
@property (nonatomic, weak) id<JPVideoCompositionPlayerDelegate>delegate;
@property (nonatomic, strong) GPUImageFilterGroup *filterGroup;
@property (nonatomic, strong) JPGeneralFilter *generalFilter;
@property (nonatomic, strong) JPStickersFilter *stickersFilter;
@property (nonatomic, strong) JPBaseVideoRecordInfo *recordInfo;
@property (nonatomic, assign) BOOL stopWithSticker;
- (instancetype)initWithIsComposition:(BOOL)isComposition andRecordInfo:(JPBaseVideoRecordInfo *)recordInfo;;
- (void)switchFilter;
- (void)destruction;
- (void)stopRecordingMovieWithCompletion:(void(^)(NSURL *url))completion;
- (UIImage *)getThumbImage;
- (void)scrollToWatchThumImageWithTime:(CMTime)time withSticker:(BOOL)isSticker;
- (BOOL)startPlaying;
- (void)pauseToPlay;
- (void)levelCurrentPage;
- (void)returnCurrentPage;
- (void)addGPUImageFilters:(GPUImageOutput<GPUImageInput> *)filter;
- (void)startToRenderFrameAtTime:(CMTime)currentSampleTime;
- (void)seekToTime:(CMTime)time;


@end
