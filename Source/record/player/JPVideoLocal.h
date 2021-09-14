//
//  JPVideoLocal.h
//  jper
//
//  Created by FoundaoTEST on 2017/3/29.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPVideoRecordInfo.h"
#import "JPVideoCamera.h"
#import "GPUImageMovie.h"
@interface JPVideoLocal : GPUImageMovie
@property (nonatomic, strong) GPUImageView *gpuImageView;
- (id)initWithURL:(NSURL *)url recordInfo:(JPVideoRecordInfo *)recordInfo;
- (id)initWithAsset:(AVAsset *)asset recordInfo:(JPVideoRecordInfo *)recordInfo;
- (id)initWithURLPre:(AVAsset *)videoAsset recordInfo:(JPVideoRecordInfo *)recordInfo;

@property (nonatomic, strong) JPPhotoModel *photoModel;
@property (nonatomic, strong) UILabel *timeRenderLabel;
- (void)destruction;
- (void)stopRecordingMovieWithCompletion:(JPVideoCameraCompletionBlock)completion;
- (void)switchFilter;
- (void)addPhotoTranstionWithType:(JPPhotoModelTranstionType)type;
- (void)seekToTime:(CMTime)time;
- (void)play;
- (void)pause;
@end
