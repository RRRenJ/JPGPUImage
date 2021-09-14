//
//  JPVideoLocal.m
//  jper
//
//  Created by FoundaoTEST on 2017/3/29.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#import "JPVideoLocal.h"
#import "JPFilterGroupHelper.h"
#import "NSString+Time.h"
#import "GPUImageMovieWriter.h"
#import "JPVideoUtil.h"
@interface JPVideoLocal ()
@property (nonatomic, strong) GPUImageFilterGroup *filterGroup;
@property (nonatomic, strong) JPFilterGroupHelper *filterHelp;
@property (strong, readwrite) GPUImageView *renderView;
@property (nonatomic, assign) NSInteger degress;
@property (nonatomic, strong) GPUImageMovieWriter *originMovieWriter;
@property (nonatomic, strong) NSString *baseMoiveName;
@property (nonatomic, strong) JPVideoRecordInfo *recordInfo;
@property (nonatomic) JPPhotoModelTranstionType photoModelTranstionType;
@property (nonatomic, strong) AVPlayer *avplayer;
@end

@implementation JPVideoLocal
- (id)initWithAsset:(AVAsset *)asset recordInfo:(JPVideoRecordInfo *)recordInfo
{
    if (self = [super initWithAsset:asset]) {
        _recordInfo = recordInfo;
        self.degress = [self degressFromVideoFileWithAsset:asset];
        self.runBenchmark = YES;
        self.playAtActualSpeed = YES;
        self.shouldRepeat = YES;
        _renderView = [[GPUImageView alloc] init];
        _filterHelp = [[JPFilterGroupHelper alloc] initWithCameraSize:CGSizeZero];
        _filterGroup = [_filterHelp switchToNewFilterType:YES withSessionPreset:JPVideoAspectRatioNomal andFilterDelegate:_recordInfo.filterDelegate];
        _photoModelTranstionType = JPPhotoModelTranstionNormal;
        if (_filterGroup.filterCount == 0) {
            [self addTarget:_renderView];
        }else{
            [self addTarget:_filterGroup];
            [_filterGroup addTarget:_renderView];
        } 
    }
    return self;
}

- (id)initWithURLPre:(AVAsset *)videoAsset recordInfo:(JPVideoRecordInfo *)recordInfo
{
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:videoAsset];
    
    if (self = [super initWithPlayerItem:playerItem]) {
        _recordInfo = recordInfo;
        self.degress = [self degressFromVideoFileWithAsset:videoAsset];
        self.avplayer = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
        self.runBenchmark = YES;
        self.playAtActualSpeed = YES;
        self.shouldRepeat = YES;
        _renderView = [[GPUImageView alloc] init];
        _filterHelp = [[JPFilterGroupHelper alloc] initWithCameraSize:CGSizeZero];
        _filterGroup = [_filterHelp switchToNewFilterType:YES withSessionPreset:JPVideoAspectRatioNomal andFilterDelegate:_recordInfo.filterDelegate];
        if (_filterGroup.filterCount == 0) {
            [self addTarget:_renderView];
        }else{
            [self addTarget:_filterGroup];
            [_filterGroup addTarget:_renderView];
        }
 
    }
    return self;
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    if (notification.object == self.playerItem) {
        [self.avplayer pause];
        [self.playerItem seekToTime:self.playTimeRange.start];
        [self.avplayer play];
    }
}

- (void)startProcessing
{
    [super startProcessing];
    if (self.playerItem) {
        [self.avplayer play];
    }
}
- (id)initWithURL:(NSURL *)url recordInfo:(JPVideoRecordInfo *)recordInfo
{
    if (self = [super initWithURL:url]) {
        _recordInfo = recordInfo;
        self.degress = [self degressFromVideoFileWithAsset:[AVURLAsset assetWithURL:url]];
        self.runBenchmark = YES;
        self.playAtActualSpeed = YES;
        self.shouldRepeat = YES;
        _renderView = [[GPUImageView alloc] init];
        _filterHelp = [[JPFilterGroupHelper alloc] initWithCameraSize:CGSizeZero];
        _filterGroup = [_filterHelp switchToNewFilterType:YES withSessionPreset:JPVideoAspectRatioNomal andFilterDelegate:_recordInfo.filterDelegate];
        if (_filterGroup.filterCount == 0) {
            [self addTarget:_renderView];
        }else{
            [self addTarget:_filterGroup];
            [_filterGroup addTarget:_renderView];
        }
    }
    return self;
}


- (NSUInteger)degressFromVideoFileWithAsset:(AVAsset *)asset
{
    NSUInteger degress = 0;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
            // Portrait
            degress = 90;
        }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            // PortraitUpsideDown
            degress = 270;
        }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
            // LandscapeRight
            degress = 0;
        }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
            // LandscapeLeft
            degress = 180;
        }
    }
    return degress;
}

- (void)addTarget:(id<GPUImageInput>)newTarget
{
    [super addTarget:newTarget];
    if (self.degress == 90) {
        [newTarget setInputRotation:kGPUImageRotateRight atIndex:0];
    }else if (self.degress == 180){
        [newTarget setInputRotation:kGPUImageRotate180 atIndex:0];
    }else if (self.degress == 270){
        [newTarget setInputRotation:kGPUImageRotateLeft atIndex:0];
    }
}
- (GPUImageView *)gpuImageView
{
    return _renderView;
}

- (void)updatePlayTime
{
    if (CMTimeCompare(CMTimeAdd(self.playTimeRange.start, self.playTimeRange.duration), self.cureentPlayTime) <= 0) {
        [self seekToTime:self.playTimeRange.start];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger currentTime = (NSInteger)ceil(CMTimeGetSeconds(CMTimeSubtract(self.cureentPlayTime, self.playTimeRange.start)));
        if (currentTime <= 0) {
            currentTime = 0;
        }
        _timeRenderLabel.text = [NSString stringWithTimeInterval:currentTime];
    });
}
- (void)pause
{
    [_avplayer pause];
}

- (void)play
{
    [_avplayer play];
}
- (void)seekToTime:(CMTime)time
{
    
    double seconds  = CMTimeGetSeconds(time);
    [self.playerItem seekToTime:CMTimeMakeWithSeconds(seconds, 24) toleranceBefore:CMTimeMake(1, 24) toleranceAfter:CMTimeMake(1, 24)];
}

- (void)endProcessing
{
    [super endProcessing];
    [self.avplayer pause];
    self.avplayer = nil;
}

- (void)destruction
{

    [self.avplayer pause];
    [self.avplayer replaceCurrentItemWithPlayerItem:nil];
    self.playerItem = nil;
    self.avplayer = nil;
    [self.originMovieWriter setCompletionBlock:nil];
    [self endProcessing];
    [self.gpuImageView removeFromSuperview];
    [self removeAllTargets];
    [self.filterGroup removeAllTargets];
    [self.filterHelp destruction];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)stopRecordingMovieWithCompletion:(JPVideoCameraCompletionBlock)completion
{
    self.playAtActualSpeed = NO;
    self.shouldRepeat = NO;
    _baseMoiveName = [JPVideoUtil fileNameForDocumentMovie];
    CGSize videoSize = [JPVideoUtil getVideoSizeWithUrl:self.url];
    CGSize reallySize = _recordInfo.videoSize;
    CGSize fillSize ;
    if (videoSize.height / videoSize.width > reallySize.height / reallySize.width) {
        CGFloat width = videoSize.width / (videoSize.height / reallySize.height);
        fillSize = CGSizeMake(width, reallySize.height);
    }else if (videoSize.width / videoSize.height > reallySize.width / reallySize.height){
        CGFloat height = videoSize.height / (videoSize.width / reallySize.width);
        fillSize = CGSizeMake(reallySize.width, height);
    }else{
        fillSize = reallySize;
    }
    __weak typeof(self) weakSelf = self;

    self.originMovieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:_baseMoiveName]] size:reallySize withFailureBlock:^(NSError *error) {
        weakSelf.audioEncodingTarget = nil;
        [weakSelf removeTarget:weakSelf.originMovieWriter];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, nil);
        });
    }];
    self.originMovieWriter.encodingLiveVideo = NO;
    self.originMovieWriter.fillSize = fillSize;
    [self addTarget:_originMovieWriter];
    [self enableSynchronizedEncodingUsingMovieWriter:self.originMovieWriter];
    [_originMovieWriter startRecording];
    [self startProcessing];
    [_originMovieWriter setCompletionBlock:^{
        weakSelf.audioEncodingTarget = nil;
        [weakSelf.originMovieWriter finishRecording];
        [weakSelf removeTarget:weakSelf.originMovieWriter];
        dispatch_async(dispatch_get_main_queue(), ^{
//            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (weakSelf.originMoiveUrl.path)) {
//                UISaveVideoAtPathToSavedPhotosAlbum (weakSelf.originMoiveUrl.path, weakSelf, @selector(video:didFinishSavingWithError:contextInfo:), nil);
//            }

            completion(weakSelf.baseMoiveName, weakSelf.baseMoiveName);
        });
    }];
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *) error contextInfo:(void *) contextInfo {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Saved" message:@"The video was saved in Camera Roll." delegate:nil cancelButtonTitle:@"Sweet" otherButtonTitles:nil];
    [alertView show];
}

- (void)switchFilter
{
    [_filterHelp switchFilterTypeWithFilterManager:_recordInfo.filterDelegate];
}
- (void)addPhotoTranstionWithType:(JPPhotoModelTranstionType)type;
{
    _photoModelTranstionType = type;
    [self switchFilter];
}

- (void)dealloc
{
}
@end
