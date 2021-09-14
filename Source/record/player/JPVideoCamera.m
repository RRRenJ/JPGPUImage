//
//  JPVideoCamera.m
//  jper
//
//  Created by FoundaoTEST on 2017/3/27.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#import "JPVideoCamera.h"
#import "JPFilterGroupHelper.h"
#import "GPUImageBrightnessFilter.h"
#import "GPUImageMovieWriter.h"
#import "JPVideoUtil.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "GPUImageBeautifyFilter.h"
@interface JPVideoCamera ()
@property (nonatomic, strong) GPUImageFilterGroup *filterGroup;
@property (nonatomic, strong) GPUImageFilterGroup *originFilterGroup;
@property (nonatomic, strong) GPUImageBrightnessFilter *brightnessFilter;
@property (nonatomic, assign) CGFloat brightness;
@property (nonatomic, strong) JPFilterGroupHelper *filterHelp;
@property (nonatomic, strong) JPFilterGroupHelper *originFilterHelp;

@property (strong, readwrite) GPUImageView *renderView;
@property (nonatomic, assign) BOOL recordingMovie;
@property (nonatomic, strong) GPUImageMovieWriter *originMovieWriter;
@property (nonatomic, strong) NSString *originMoveName;
@property (nonatomic, assign) BOOL openLight;
@property (nonatomic, strong) GPUImageBeautifyFilter *beautifulfyFilter;

@end

@implementation JPVideoCamera

- (id)initWithSessionPreset:(NSString *)sessionPreset cameraPosition:(AVCaptureDevicePosition)cameraPosition withRecordInfo:(JPVideoRecordInfo *)recordInfo
{
    if (self = [super initWithSessionPreset:sessionPreset cameraPosition:cameraPosition]) {
        self.horizontallyMirrorFrontFacingCamera = YES;
        self.horizontallyMirrorRearFacingCamera = NO;
        self.outputImageOrientation = UIInterfaceOrientationPortrait;
        [self addAudioInputsAndOutputs];
        _recordInfo = recordInfo;
        NSDictionary* outputSettings = [videoOutput videoSettings];
        long width  = [[outputSettings objectForKey:@"Width"]  longValue];
        long height = [[outputSettings objectForKey:@"Height"] longValue];
        if (UIInterfaceOrientationIsPortrait([self outputImageOrientation])) {
            long buf = width;
            width = height;
            height = buf;
        }
        _supportSlow = NO;
        AVCaptureDevice *device = [self getInputDevice].device;
        for(AVCaptureDeviceFormat *format in [device formats] ) {
            for ( AVFrameRateRange *range in format.videoSupportedFrameRateRanges ) {
                if (range.maxFrameRate >= 100) {
                    _supportSlow = YES;
                }
            }
        }
        self.brightness = 0.0;
        _isFront = NO;
        _videoSize = CGSizeMake(width, height);
        _filterHelp = [[JPFilterGroupHelper alloc] initWithCameraSize:_videoSize];
        _filterHelp.isCrop = NO;
        _renderView = [[GPUImageView alloc] init];
        _filterGroup = [_filterHelp switchToNewFilterType:YES withSessionPreset:_recordInfo.aspectRatio andFilterDelegate:_recordInfo.filterDelegate];
        self.brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
        self.brightnessFilter.brightness = self.brightness;
        [self addTarget:self.brightnessFilter];
        if (_filterGroup.filterCount > 0) {
            [_filterGroup addTarget:_renderView];
            [self.brightnessFilter addTarget:_filterGroup];
        }else{
            [self.brightnessFilter addTarget:_renderView];
        }
      
    }
    return self;
}

- (void)switchFilter
{
    [_filterHelp switchFilterTypeWithFilterManager:_recordInfo.filterDelegate];
}


- (void)rotateCamera
{
    [super rotateCamera];
    _isFront = !_isFront;
    if (_isFront == YES) {
        _beautifulfyFilter = [[GPUImageBeautifyFilter alloc] init];
        [self removeAllTargets];
        [self addTarget:_beautifulfyFilter];
        [_beautifulfyFilter addTarget:_brightnessFilter];
    }else{
        [self removeAllTargets];
        [_beautifulfyFilter removeAllTargets];
        _beautifulfyFilter = nil;
        [self addTarget:_brightnessFilter];
    }
}
- (void)resetSetting
{
    [self.brightnessFilter removeAllTargets];
    [_filterGroup removeAllTargets];
    _filterGroup = [_filterHelp switchToNewFilterType:YES withSessionPreset:_recordInfo.aspectRatio andFilterDelegate:_recordInfo.filterDelegate];
    if (_filterGroup.filterCount > 0) {
        [_filterGroup addTarget:_renderView];
        [self.brightnessFilter addTarget:_filterGroup];
    }else{
        [self.brightnessFilter addTarget:_renderView];
    }
}

- (void)setCurrentBrightness:(CGFloat)currentBrightness
{
    _currentBrightness = currentBrightness;
    _brightness = currentBrightness;
    self.brightnessFilter.brightness = self.brightness;
}

- (void)switchSessionPreset:(JPVideoAspectRatio)sessionPreset
{
    [self resetSetting];
}

- (GPUImageView *)gpuImageView
{
    return _renderView;
}

- (void)destruction
{
    [self stopCameraCapture];
    [_beautifulfyFilter removeAllTargets];
    [self.gpuImageView removeFromSuperview];
    [self removeAllTargets];
    [self.brightnessFilter removeAllTargets];
    [self.filterGroup removeAllTargets];
    [self.filterHelp destruction];
    [self.originFilterHelp destruction];
    [self.originFilterGroup removeAllTargets];
    [self.originMovieWriter setCompletionBlock:nil];
    [self setVideoCameraFinishRecordBlock:nil];
}
#pragma mark - Movie Writing methods

- (void)startRecordingMovie
{
    if (self.isRecordingMovie == YES) {
        return;
    }
    _recordingMovie = YES;
    _originFilterHelp = [[JPFilterGroupHelper alloc] initWithCameraSize:_videoSize];
    _originFilterGroup = [_originFilterHelp switchToNewFilterType:NO withSessionPreset:_recordInfo.aspectRatio andFilterDelegate:nil];
    _originMoveName = [JPVideoUtil fileNameForDocumentMovie];
    __weak typeof(self) weakself = self;
    self.originMovieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:_originMoveName]] size:_recordInfo.videoSize withFailureBlock:^(NSError *error) {
        weakself.recordingMovie = NO;
        weakself.audioEncodingTarget = nil;
        [weakself.brightnessFilter removeTarget:weakself.originFilterGroup];
        [weakself.originFilterGroup removeTarget:weakself.originMovieWriter];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"录制出错" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            [alertView show];
            if (weakself.videoCameraFinishRecordBlock) {
                weakself.videoCameraFinishRecordBlock();
            }
        });
    }];
    if (_howFastType == JPVideoHowFastFast) {
        _originMovieWriter.speedScale = 0.2;
    }else if (_howFastType == JPVideoHowFastSlow)
    {
        _originMovieWriter.speedScale = 4;
    }else
    {
        _originMovieWriter.shouldPassthroughAudio = YES;
        _originMovieWriter.hasAudioTrack=YES;
        self.audioEncodingTarget = _originMovieWriter;
    }
    _originMovieWriter.encodingLiveVideo = YES;
    self.originMovieWriter.fillSize = _recordInfo.videoSize;
    [self.brightnessFilter addTarget:_originFilterGroup];
    [self.originFilterGroup addTarget:_originMovieWriter];
    [self.originMovieWriter startRecording];
}

- (void)stopCameraCapture
{
    _recordingMovie = NO;
    self.audioEncodingTarget = nil;
    [self.originMovieWriter finishRecording];
    [self.brightnessFilter removeTarget:self.originFilterGroup];
    [self.originFilterGroup removeTarget:self.originMovieWriter];
    if (self.videoCameraFinishRecordBlock) {
        self.videoCameraFinishRecordBlock();
    }
    [super stopCameraCapture];
}

- (void)stopRecordingMovieWithCompletion:(JPVideoCameraCompletionBlock)completion
{
    _recordingMovie = NO;
    __weak typeof(self) weakSelf = self;
    self.audioEncodingTarget = nil;
    [self.originFilterGroup removeTarget:self.originMovieWriter];
    [self.brightnessFilter removeTarget:self.originFilterGroup];
    [self.originMovieWriter finishRecordingWithCompletionHandler:^{
          weakSelf.originMovieWriter = nil;
          ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
          [library saveVideo:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:weakSelf.originMoveName]] toAlbum:@"新建相册" completion:nil failure:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(weakSelf.originMoveName, weakSelf.originMoveName);
        });
    }];;
  
}

- (void)openFlashlight
{
    _openLight = YES;
    if ([[self activeCamera] position] != AVCaptureDevicePositionBack) {
        return;
    }
    AVCaptureDevice *device = [self activeCamera];
    [device lockForConfiguration:nil];
    if ([device hasFlash]) {
        device.flashMode = AVCaptureFlashModeOn;
        device.torchMode = AVCaptureTorchModeOn;
    }
    [device unlockForConfiguration];
}

- (void)closeFlashlight
{
    _openLight = NO;
    if ([[self activeCamera] position] != AVCaptureDevicePositionBack) {
        return;
    }
    AVCaptureDevice *device = [self activeCamera];
    [device lockForConfiguration:nil];
    if ([device hasFlash]) {
        device.flashMode = AVCaptureFlashModeOff;
        device.torchMode = AVCaptureTorchModeOff;
    }
    [device unlockForConfiguration];
}
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *) error contextInfo:(void *) contextInfo {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Saved" message:@"The video was saved in Camera Roll." delegate:nil cancelButtonTitle:@"Sweet" otherButtonTitles:nil];
    [alertView show];
}

- (BOOL)isRecordingMovie
{
    return _recordingMovie;
}




- (void)dealloc
{
    
}

#pragma mark - Focus

- (BOOL)cameraSupportsTapToFocus {
    return [[self activeCamera] isFocusPointOfInterestSupported];
}
// Switch to continuous auto focus mode at the specified point
- (void)focusAndLockAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = [self activeCamera];
    if ([self cameraSupportsTapToFocus] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            if ([device isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
                [device setExposurePointOfInterest:point];
                [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
            [device unlockForConfiguration];
        }
        else{
        }
    }
}


- (void)lockFocusAndAutoLight:(CGPoint)point
{
    AVCaptureDevice *device = [self activeCamera];
    if ([self cameraSupportsTapToFocus] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.focusPointOfInterest = point;
            
            device.focusMode = AVCaptureFocusModeLocked;
            if ([device isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
                [device setExposurePointOfInterest:point];
                [device setExposureMode:AVCaptureExposureModeAutoExpose];
            }
            [device unlockForConfiguration];

        }
        else{
        }
    }

}

- (AVCaptureDevice *)activeCamera {
    return [self getInputDevice].device;
}

- (void)setHowFastType:(JPVideoHowFast)howFastType
{
    _howFastType = howFastType;
    [self configureCameraForHighestFrameRate:[self getInputDevice].device];
}

- (void)startCameraCapture
{
    [super startCameraCapture];
    [self configureCameraForHighestFrameRate:[self getInputDevice].device];
    if ([[self activeCamera] position] == AVCaptureDevicePositionBack) {
        if (_openLight) {
            [self openFlashlight];
        }else{
            [self closeFlashlight];
        }
    }
}

-(void)configureCameraForHighestFrameRate:(AVCaptureDevice*) device
{
    if (_supportSlow == NO) {
        return;
    }
    if (_howFastType == JPVideoHowFastSlow) {
        if ([device position] == AVCaptureDevicePositionFront) {
            [self rotateCamera];
            if (_openLight) {
                [self openFlashlight];
            }else{
                [self closeFlashlight];
            }
        }
    }else if ([device position] == AVCaptureDevicePositionFront)
    {
        return;
    }
    AVCaptureDeviceFormat *bestFormat = nil;
    AVFrameRateRange *bestFrameRateRange = nil;
    for(AVCaptureDeviceFormat *format in [device formats] ) {
        CMVideoDimensions dim = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
        CGSize cameraSize = CGSizeMake(dim.height, dim.width);
        if (!CGSizeEqualToSize(cameraSize, _videoSize)) {
            continue;
        }
        for ( AVFrameRateRange *range in format.videoSupportedFrameRateRanges ) {
            if (_howFastType != JPVideoHowFastSlow) {
            if (range.maxFrameRate >= 24 && range.maxFrameRate <= 40 ) {
                    bestFormat = format;
                    bestFrameRateRange = range;
                    NSLog(@"current.....%.2f rate", range.maxFrameRate);
                _videoSize = cameraSize;
                    break;
                }
            }else if ( range.maxFrameRate >= 100 && range.maxFrameRate <= 140 ) {
                bestFormat = format;
                bestFrameRateRange = range;
            }
        }
        if (bestFormat) {
            _videoSize = cameraSize;
            break;
        }
    }
    if ( bestFormat ) {
        if ( [device lockForConfiguration:NULL] == YES ) {
            device.activeFormat = bestFormat;
            device.activeVideoMinFrameDuration = bestFrameRateRange.minFrameDuration;
            device.activeVideoMaxFrameDuration = bestFrameRateRange.minFrameDuration;
            NSLog(@"current.....%.4f  %.4f rate", CMTimeGetSeconds( bestFrameRateRange.maxFrameDuration),  CMTimeGetSeconds( bestFrameRateRange.minFrameDuration));

            [device unlockForConfiguration];
        }
    }
}
@end
