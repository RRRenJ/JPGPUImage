//
//  JPVideoCamera.h
//  jper
//
//  Created by FoundaoTEST on 2017/3/27.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#import "JPFilterModel.h"
#import "JPVideoRecordInfo.h"
#import "GPUImageVideoCamera.h"
#import "GPUImageView.h"
typedef void(^JPVideoCameraCompletionBlock)(NSString *basevideoPath, NSString *originvideoPath);

@interface JPVideoCamera : GPUImageVideoCamera
@property (nonatomic, strong) GPUImageView *gpuImageView;
@property (nonatomic, strong) JPVideoRecordInfo *recordInfo;
@property (nonatomic, copy) void(^videoCameraFinishRecordBlock)(void);
@property (nonatomic, assign) BOOL supportSlow;
@property (nonatomic) JPVideoHowFast howFastType;
@property (nonatomic, assign, readonly) BOOL isRecordingMovie;
@property (nonatomic, assign) BOOL isFront;
- (void)switchFilter;
- (void)startRecordingMovie;
- (void)stopRecordingMovieWithCompletion:(JPVideoCameraCompletionBlock)completion;
- (void)switchSessionPreset:(JPVideoAspectRatio)sessionPreset;
- (void)destruction;
- (id)initWithSessionPreset:(NSString *)sessionPreset cameraPosition:(AVCaptureDevicePosition)cameraPosition withRecordInfo:(JPVideoRecordInfo *)recordInfo;
- (void)focusAndLockAtPoint:(CGPoint)point;
-(void)openFlashlight;
- (void)closeFlashlight;
@property (nonatomic, assign) CGSize videoSize;
@property (nonatomic, assign) CGFloat currentBrightness;
- (void)lockFocusAndAutoLight:(CGPoint)point;
@end
