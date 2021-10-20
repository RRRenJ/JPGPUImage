//
//  JPVideoRecordSetting.m
//  jper
//
//  Created by FoundaoTEST on 2017/3/24.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#import "JPVideoRecordInfo.h"
#import "JPPublicConstant.h"
#import "JPCustomCompositing.h"
#import "AVMutableVideoCompositionInstruction+JPComposition.h"
#import "JPTranstionsDefault.h"
#import "JPCoustomInstruction.h"
#import <objc/runtime.h>
#import "JPVideoCompositionPlayer.h"

@implementation NSObject (FlyElephant)

- (void)swizzleMethod:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector{
    Class class = [self class];
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(class,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end


@implementation NSArray (JPObecjtAtIndex)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            NSArray *systemArr = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
            
            if ([systemArr.firstObject integerValue] >= 11) {
                [objc_getClass("__NSArray0") swizzleMethod:@selector(objectAtIndexedSubscript:) swizzledSelector:@selector(emptyObjectIndexELE:)];
                [objc_getClass("__NSArrayI") swizzleMethod:@selector(objectAtIndexedSubscript:) swizzledSelector:@selector(arrObjectIndexELE:)];
                [objc_getClass("__NSArrayM") swizzleMethod:@selector(objectAtIndexedSubscript:) swizzledSelector:@selector(mutableObjectIndexELE:)];
            }
            [objc_getClass("__NSArray0") swizzleMethod:@selector(objectAtIndex:) swizzledSelector:@selector(emptyObjectIndex:)];
            [objc_getClass("__NSArrayI") swizzleMethod:@selector(objectAtIndex:) swizzledSelector:@selector(arrObjectIndex:)];
            [objc_getClass("__NSArrayM") swizzleMethod:@selector(objectAtIndex:) swizzledSelector:@selector(mutableObjectIndex:)];
        }
    });
}


- (id)emptyObjectIndex:(NSInteger)index{
    if (self.count != 0) {
        if (index < 0) {
            return [self emptyObjectIndex:0];
        }else if (index >= self.count)
        {
            return [self emptyObjectIndex:self.count - 1];
        }else{
            return [self emptyObjectIndex:index];
        }
        
    }else
    {
        return nil;
    }
    
}


- (id)emptyObjectIndexELE:(NSInteger)index{
    if (self.count != 0) {
        if (index < 0) {
            return [self emptyObjectIndexELE:0];
        }else if (index >= self.count)
        {
            return [self emptyObjectIndexELE:self.count - 1];
        }else{
            return [self emptyObjectIndexELE:index];
        }
        
    }else
    {
        return nil;
    }

}

- (id)arrObjectIndex:(NSInteger)index{
    if (self.count != 0) {
        if (index < 0) {
            return [self arrObjectIndex:0];
        }else if (index >= self.count)
        {
            return [self arrObjectIndex:self.count - 1];
        }else{
            return [self arrObjectIndex:index];
        }
        
    }else
    {
        return nil;
    }
}


- (id)arrObjectIndexELE:(NSInteger)index{
    if (self.count != 0) {
        if (index < 0) {
            return [self arrObjectIndexELE:0];
        }else if (index >= self.count)
        {
            return [self arrObjectIndexELE:self.count - 1];
        }else{
            return [self arrObjectIndexELE:index];
        }
        
    }else
    {
        return nil;
    }
}


- (id)mutableObjectIndexELE:(NSInteger)index{
    if (self.count != 0) {
        if (index < 0) {
            return [self mutableObjectIndexELE:0];
        }else if (index >= self.count)
        {
            return [self mutableObjectIndexELE:self.count - 1];
        }else{
            return [self mutableObjectIndexELE:index];
        }
        
    }else
    {
        return nil;
    }
}


- (id)mutableObjectIndex:(NSInteger)index{
    if (self.count != 0) {
        if (index < 0) {
            return [self mutableObjectIndex:0];
        }else if (index >= self.count)
        {
            return [self mutableObjectIndex:self.count - 1];
        }else{
            return [self mutableObjectIndex:index];
        }
        
    }else
    {
        return nil;
    }
}

//- (void)mutableExchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2{
//    if (idx1 < self.count && idx2 < self.count) {
//        [self mutableExchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
//    }
//}
//
//- (void)mutableInsertObject:(id)object atIndex:(NSUInteger)index{
//    if (object && index < self.count) {
//        [self mutableInsertObject:object atIndex:index];
//    }
//}


@end



@interface  JPVideoRecordInfo()

@property (nonatomic, strong) AVMutableComposition *originVideoComposition;
@property (nonatomic, strong) AVMutableComposition *reaocrdVideoComposition;
@property (nonatomic, strong) AVMutableCompositionTrack *musicCompositionTrack;
@property (nonatomic, strong) AVMutableCompositionTrack *soundEffectAudioTrack;
@property (nonatomic, strong) AVMutableCompositionTrack *originRecordTrack;
@property (nonatomic, strong) AVMutableCompositionTrack *recordTrack;
@property (nonatomic, strong) NSMutableArray<JPVideoModel *> *dataSource;
@property (nonatomic, strong) NSMutableArray *audioDataSource;
@property (nonatomic, strong) NSMutableArray *soundEffectDataSource;
@property (nonatomic, strong) NSMutableDictionary *audioParamsDic;
@property (nonatomic, assign) CMTime reallyDuration;
@end

@implementation JPVideoRecordInfo


- (instancetype)initWithFilterManager:(id<JPVideoRecordInfoFilterManager>)manager
{
    if (self = [super initWithFilterManager:manager]) {
        self.aspectRatio = JPVideoAspectRatio16X9;
        //        _videoTotal = 5;
        _dataSource = [NSMutableArray array];
        _audioDataSource = [NSMutableArray array];
        _soundEffectDataSource = [NSMutableArray array];
        _totalDuration = CMTimeMake(1800, 1);
        _volume = 0.5f;
        _laterVolume = 0.5f;
        _hasChangedAspectRatio = NO;
        _hasAddVideo = NO;
    }
    return self;
}


- (void)becomeOrigin
{
    [_dataSource removeAllObjects];
    _dataSource = [NSMutableArray array];
    [_audioDataSource removeAllObjects];
    [_soundEffectDataSource removeAllObjects];
    _soundEffectDataSource = [NSMutableArray array];
    [self originCompositionBecomeNone];
    _pattnaerArr = nil;
    _hasAddVideo = NO;
}

- (void)addVideoFile:(JPVideoModel *)videoModel
{
    AVURLAsset *videoAsset = [AVURLAsset assetWithURL:videoModel.videoUrl];
    if ([videoAsset tracksWithMediaType:AVMediaTypeVideo].count == 0) {
        return;
    }
    if (![_dataSource containsObject:videoModel]) {
        videoModel.timeRange = CMTimeRangeMake(kCMTimeZero, videoModel.videoTime);
        if (videoModel.thumbImages == nil) {
            [videoModel asyncGetAllThumbImages];
        }
        videoModel.transtionType = 0;
        [_dataSource addObject:videoModel];
        [self originCompositionBecomeNone];
    }
}


- (CMTime)currentTotalTime
{
    CMTime currentTotalTime = kCMTimeZero;
    for (JPVideoModel *videoModel in _dataSource) {
        currentTotalTime = CMTimeAdd(videoModel.timeRange.duration, currentTotalTime);
    }
    return currentTotalTime;
}

- (void)setVolume:(CGFloat)volume {
    _volume = volume;
    [self resetRecordAudio];
}

- (void)setLaterVolume:(CGFloat)laterVolume {
    _laterVolume = laterVolume;
    [self resetRecordAudio];
}

- (void)deleteVideofile:(JPVideoModel *)videoModel
{
    if ([_dataSource containsObject:videoModel]) {
        [_dataSource removeObject:videoModel];
        [self originCompositionBecomeNone];
    }
}

- (void)removeAllAudioFile
{
    [_soundEffectDataSource removeAllObjects];
    [_audioDataSource removeAllObjects];
    [self audioCompositionToBeNone];
}

- (void)addAudioFile:(JPAudioModel *)audioModel {
    if (![_audioDataSource containsObject:audioModel]) {
        if (self.reaocrdVideoComposition == nil) {
            return;
        }
        [_audioDataSource addObject:audioModel];
        [self resetRecordAudio];
    }
}

- (void)deleteAudioFile:(JPAudioModel *)audioModel {
    if ([_audioDataSource containsObject:audioModel]) {
        [_audioDataSource removeObject:audioModel];
        [self resetRecordAudio];
    }
}


- (void)resetMix
{
    CGFloat musicVolume = _laterVolume;
    CGFloat recordAudioVolume = _volume;
    CGFloat soundEffectVolume = _laterVolume;
    if (_backgroundMusic != nil && _backgroundMusic.fileUrl && _soundEffectDataSource.count && _audioDataSource.count) {
        recordAudioVolume = _volume*0.8;
        musicVolume = soundEffectVolume = _laterVolume*0.2;
    }else if (_soundEffectDataSource.count && _audioDataSource.count){
        recordAudioVolume = _volume*0.8;
        soundEffectVolume = _laterVolume*0.2;
    } else if (_backgroundMusic != nil && _backgroundMusic.fileUrl && _soundEffectDataSource.count){
        musicVolume = soundEffectVolume = _laterVolume*0.5;
    } else if (_backgroundMusic != nil && _backgroundMusic.fileUrl && _audioDataSource.count){
        recordAudioVolume = _volume*0.8;
        musicVolume = _laterVolume*0.2;
    }
    self.allAudioParams = [NSMutableArray array];
    if (_recordTrack) {
//        CMTime maxStartTime = kCMTimeZero;
        AVMutableAudioMixInputParameters *audioInputParams =
        [AVMutableAudioMixInputParameters audioMixInputParameters];
        [audioInputParams setVolume:recordAudioVolume atTime:kCMTimeZero];
//        for (JPAudioModel *audioModel in _audioDataSource) {
//            CMTime start = CMTimeAdd(audioModel.clipTimeRange.start, CMTimeMake(1, 20));
//            CMTime end = CMTimeSubtract(CMTimeAdd(audioModel.clipTimeRange.start, audioModel.clipTimeRange.duration), CMTimeMake(1, 20));
//            CMTime duration = CMTimeSubtract(end, start);
//            CGFloat timeValue = 0.15;
//            CMTime volumeChangeTime = CMTimeMultiplyByFloat64(duration,timeValue);
//            if (CMTimeCompare(volumeChangeTime, CMTimeMake(1, 1)) > 0 ) {
//                volumeChangeTime = CMTimeMake(1, 1);
//            }
//            [audioInputParams setVolumeRampFromStartVolume:recordAudioVolume toEndVolume:JP_AUDIO_VOLUME timeRange:CMTimeRangeMake(start, volumeChangeTime)];
//            [audioInputParams setVolumeRampFromStartVolume:JP_AUDIO_VOLUME toEndVolume:recordAudioVolume timeRange:CMTimeRangeMake(CMTimeSubtract(end, volumeChangeTime), volumeChangeTime)];
//            maxStartTime = CMTimeCompare(CMTimeAdd(audioModel.clipTimeRange.start, audioModel.clipTimeRange.duration), maxStartTime) > 0 ? CMTimeAdd(audioModel.clipTimeRange.start, audioModel.clipTimeRange.duration) : maxStartTime;
//        }
        [audioInputParams setTrackID:[_recordTrack trackID]];
        [self.allAudioParams addObject:audioInputParams];
    }
    if (_musicCompositionTrack) {
        CMTime maxStartTime = kCMTimeZero;
        if (CMTimeCompare(maxStartTime, CMTimeSubtract(self.reaocrdVideoComposition.duration, CMTimeMake(1, 1))) < 0) {
            maxStartTime = CMTimeSubtract(self.reaocrdVideoComposition.duration, CMTimeMake(1, 1));
        }
        AVMutableAudioMixInputParameters *audioInputParams =
        [AVMutableAudioMixInputParameters audioMixInputParameters];
        [audioInputParams setVolume:musicVolume atTime:kCMTimeZero];
        [audioInputParams setVolumeRampFromStartVolume:musicVolume toEndVolume:JP_AUDIO_VOLUME timeRange:CMTimeRangeMake(maxStartTime, CMTimeSubtract(self.reaocrdVideoComposition.duration, maxStartTime))];
        [audioInputParams setTrackID:[_musicCompositionTrack trackID]];
        [self.allAudioParams addObject:audioInputParams];
    }
    if (_soundEffectAudioTrack) {
//        CMTime maxStartTime = kCMTimeZero;
        AVMutableAudioMixInputParameters *audioInputParams =
        [AVMutableAudioMixInputParameters audioMixInputParameters];
        [audioInputParams setVolume:soundEffectVolume atTime:kCMTimeZero];
//        for (JPAudioModel *audioModel in _soundEffectDataSource) {
//            CMTime start = CMTimeAdd(audioModel.clipTimeRange.start, CMTimeMake(1, 20));
//            CMTime end = CMTimeSubtract(CMTimeAdd(audioModel.clipTimeRange.start, audioModel.clipTimeRange.duration), CMTimeMake(1, 20));
//            CMTime duration = CMTimeSubtract(end, start);
//            CGFloat timeValue = 0.15;
//            CMTime volumeChangeTime = CMTimeMultiplyByFloat64(duration,timeValue);
//            if (CMTimeCompare(volumeChangeTime, CMTimeMake(1, 1)) > 0 ) {
//                volumeChangeTime = CMTimeMake(1, 1);
//            }
//            [audioInputParams setVolumeRampFromStartVolume:soundEffectVolume toEndVolume:JP_AUDIO_VOLUME timeRange:CMTimeRangeMake(start, volumeChangeTime)];
//            [audioInputParams setVolumeRampFromStartVolume:JP_AUDIO_VOLUME toEndVolume:soundEffectVolume timeRange:CMTimeRangeMake(CMTimeSubtract(end, volumeChangeTime), volumeChangeTime)];
//            maxStartTime = CMTimeCompare(CMTimeAdd(audioModel.clipTimeRange.start, audioModel.clipTimeRange.duration), maxStartTime) > 0 ? CMTimeAdd(audioModel.clipTimeRange.start, audioModel.clipTimeRange.duration) : maxStartTime;
//        }
        [audioInputParams setTrackID:[_soundEffectAudioTrack trackID]];
        [self.allAudioParams addObject:audioInputParams];
    }
    if (_originRecordTrack) {
        AVMutableAudioMixInputParameters *audioInputParams =
        [AVMutableAudioMixInputParameters audioMixInputParameters];
        [audioInputParams setVolume:_volume atTime:kCMTimeZero];
        [audioInputParams setTrackID:[_originRecordTrack trackID]];
        [self.allAudioParams addObject:audioInputParams];
    }
}

- (void)removeAudioFilesWithArr:(NSArray *)array
{
    for (JPAudioModel *models in array) {
        if ([_audioDataSource containsObject:models]) {
            [_audioDataSource removeObject:models];
        }
    }
}

- (void)addSoundEffectFile:(JPAudioModel *)audioModel {
    if (![_soundEffectDataSource containsObject:audioModel]) {
        if (self.reaocrdVideoComposition == nil) {
            return;
        }
        [_soundEffectDataSource addObject:audioModel];
        [self resetRecordAudio];
    }
}

- (void)repelaceSoundEffectFileWithModel:(JPAudioModel *)model atIndex:(int)index {
    if (index < 0 || index > _soundEffectDataSource.count) {
        return;
    }
    [_soundEffectDataSource replaceObjectAtIndex:index withObject:model];
    [self resetRecordAudio];
}

- (void)deleteSoundEffectFile:(JPAudioModel *)audioModel {
    if ([_soundEffectDataSource containsObject:audioModel]) {
        [_soundEffectDataSource removeObject:audioModel];
        [self resetRecordAudio];
    }
}

- (void)removeSoundEffectFilesWithArr:(NSArray *)array{
    for (JPAudioModel *models in array) {
        if ([_soundEffectDataSource containsObject:models]) {
            [_soundEffectDataSource removeObject:models];
        }
    }
}

- (NSArray<JPVideoModel *> *)videoSource
{
    return [_dataSource copy];
}

- (NSArray *)audioSource
{
    return [_audioDataSource copy];
}

- (NSArray *)soundEffectSource {
    return [_soundEffectDataSource copy];
}


+ (CGSize)getImageSizeWithRadio:(JPVideoAspectRatio)aspectRatio
{
    CGSize iamgeSize = CGSizeZero;
    switch (aspectRatio) {
        case JPVideoAspectRatio1X1:
            iamgeSize = CGSizeMake(1080, 1080);
            break;
        case JPVideoAspectRatio16X9:
            iamgeSize = CGSizeMake(1280, 720);
            break;
        case JPVideoAspectRatio9X16:
            iamgeSize = CGSizeMake(1080, 1920);
            break;
        case JPVideoAspectRatio4X3:
            iamgeSize = CGSizeMake(1280, 960);
            break;
        case JPVideoAspectRatioCircular:
            iamgeSize = CGSizeMake(1080, 1080);
            break;
        default:
            break;
    }
    return iamgeSize;
}


- (void)exchangeVideoFileIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    if (fromIndex < toIndex) {
        for (NSInteger i = fromIndex; i < toIndex; i ++) {
            [_dataSource exchangeObjectAtIndex:i withObjectAtIndex:i + 1];
        }
    }else{
        for (NSInteger i = fromIndex; i > toIndex; i --) {
            [_dataSource exchangeObjectAtIndex:i withObjectAtIndex:i - 1];
        }
    }
    [self originCompositionBecomeNone];
}

- (AVMutableComposition *)composition
{
    @autoreleasepool {
        if (_audioDataSource.count == 0 && _backgroundMusic.fileUrl == nil && _soundEffectDataSource.count == 0) {
            return self.originVideoComposition.mutableCopy;
        }else{
            return self.reaocrdVideoComposition.mutableCopy;
        }
    }
}

- (void)setBackgroundMusic:(JPAudioModel *)backgroundMusic
{
    if (backgroundMusic == nil || backgroundMusic.fileUrl == nil) {
        _backgroundMusic = backgroundMusic;
        if (_musicCompositionTrack != nil) {
            [_reaocrdVideoComposition removeTrack:_musicCompositionTrack];
            _musicCompositionTrack = nil;
        }
        self.allAudioParams = nil;
        self.mixInputParameters = nil;
        [self resetRecordAudio];
    }else{
        if (_musicCompositionTrack == nil) {
            _musicCompositionTrack = [self.reaocrdVideoComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        }
        _backgroundMusic = backgroundMusic;
        [_musicCompositionTrack removeTimeRange:CMTimeRangeMake(kCMTimeZero, self.reaocrdVideoComposition.duration)];
        self.allAudioParams = [NSMutableArray array];
        NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:backgroundMusic.fileUrl options:inputOptions];
        CMTime duration = self.reaocrdVideoComposition.duration;
        CMTime restTime = duration;
        CMTime musicStartTime = kCMTimeZero;
        while (CMTimeCompare(restTime, kCMTimeZero) == 1) {
            if (CMTimeCompare(restTime, backgroundMusic.durationTime) == 1) {
                [_musicCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, backgroundMusic.durationTime) ofTrack:[[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:musicStartTime error:nil];
                restTime = CMTimeSubtract(restTime,  backgroundMusic.durationTime);
                musicStartTime = CMTimeAdd(musicStartTime,  backgroundMusic.durationTime);
            }else{
                [_musicCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, restTime) ofTrack:[[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:musicStartTime error:nil];
                restTime = CMTimeSubtract(restTime,  restTime);
                musicStartTime = CMTimeAdd(musicStartTime,  restTime);
            }
        }
        //背景音乐淡出----fixed by panyaling
        [self resetRecordAudio];
    }
}


- (void)resetRecordAudio
{
        [_recordTrack removeTimeRange:CMTimeRangeMake(kCMTimeZero, self.reaocrdVideoComposition.duration)];
        [_soundEffectAudioTrack removeTimeRange:CMTimeRangeMake(kCMTimeZero, self.reaocrdVideoComposition.duration)];
        if (_originRecordTrack && (_backgroundMusic == nil || _backgroundMusic.fileUrl == nil)) {
            [_recordTrack removeTimeRange:CMTimeRangeMake(kCMTimeZero, _reaocrdVideoComposition.duration)];
            [_recordTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, _reaocrdVideoComposition.duration) ofTrack:_originRecordTrack atTime:kCMTimeZero error:nil];
            [_soundEffectAudioTrack removeTimeRange:CMTimeRangeMake(kCMTimeZero, _reaocrdVideoComposition.duration)];
            [_soundEffectAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, _reaocrdVideoComposition.duration) ofTrack:_originRecordTrack atTime:kCMTimeZero error:nil];
        }else{
            [self.reaocrdVideoComposition removeTrack:_recordTrack];
            [self.reaocrdVideoComposition removeTrack:_soundEffectAudioTrack];
            _soundEffectAudioTrack = nil;
            _recordTrack = nil;
        }
        CMTime duration = CMTimeSubtract(self.reaocrdVideoComposition.duration, CMTimeMake(1, 3));
        for (JPAudioModel *audioModel in _audioDataSource) {

            NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:audioModel.fileUrl options:inputOptions];
            if ([asset tracksWithMediaType:AVMediaTypeAudio].count > 0) {
                if (_recordTrack == nil) {
                    _recordTrack = [self.reaocrdVideoComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                }
                CMTimeRange assetTimeInRange = audioModel.clipTimeRange;
                if (CMTimeCompare(assetTimeInRange.start, duration) >= 0) {
                    continue;
                }else{
                    CMTime assetduration = assetTimeInRange.duration;
                    if (CMTimeCompare(CMTimeAdd(assetTimeInRange.start, assetduration), duration) >= 0) {
                        assetduration = CMTimeSubtract(duration, assetTimeInRange.start);
                    }
                    assetTimeInRange.duration = assetduration;
                    [_recordTrack removeTimeRange:assetTimeInRange];
                    [_recordTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, assetTimeInRange.duration) ofTrack:[[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:assetTimeInRange.start error:nil];
                }
            }
        }
        //添加音效
        for (JPAudioModel *audioModel in _soundEffectDataSource) {
            NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:audioModel.fileUrl options:inputOptions];
            if ([asset tracksWithMediaType:AVMediaTypeAudio].count > 0) {
                if (_soundEffectAudioTrack == nil) {
                    _soundEffectAudioTrack = [self.reaocrdVideoComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                }
                CMTimeRange assetTimeInRange = audioModel.clipTimeRange;
                if (CMTimeCompare(assetTimeInRange.start, duration) >= 0) {
                    continue;
                }else{
                    CMTime assetduration = assetTimeInRange.duration;
                    if (CMTimeCompare(CMTimeAdd(assetTimeInRange.start, assetduration), duration) >= 0) {
                        assetduration = CMTimeSubtract(duration, assetTimeInRange.start);
                    }
                    assetTimeInRange.duration = assetduration;
                }
                [_soundEffectAudioTrack removeTimeRange:assetTimeInRange];
                [_soundEffectAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, assetTimeInRange.duration) ofTrack:[[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:assetTimeInRange.start error:nil];
            }
        }
    
    [self resetMix];
}


- (AVMutableComposition *)reaocrdVideoComposition
{
    if (_reaocrdVideoComposition == nil) {
        _reaocrdVideoComposition = self.originVideoComposition.mutableCopy;
        _originRecordTrack = [self.originVideoComposition tracksWithMediaType:AVMediaTypeAudio].firstObject;
        if (_originRecordTrack) {
            _recordTrack = [_reaocrdVideoComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            _soundEffectAudioTrack = [_reaocrdVideoComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [_recordTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, _reaocrdVideoComposition.duration) ofTrack:_originRecordTrack atTime:kCMTimeZero error:nil];
            [_soundEffectAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, _reaocrdVideoComposition.duration) ofTrack:_originRecordTrack atTime:kCMTimeZero error:nil];
        }
        if (_backgroundMusic.fileUrl != nil || _audioDataSource.count != 0 || _soundEffectDataSource.count != 0) {
            if (_backgroundMusic.fileUrl != nil) {
                [self setBackgroundMusic:_backgroundMusic];
            }else{
                [self resetRecordAudio];
            }
        }
    }
    return _reaocrdVideoComposition;
}

- (AVMutableComposition *)originVideoComposition
{
    if (_originVideoComposition == nil) {
        if (_dataSource.count == 0) {
            return nil;
        }
        _originVideoComposition = [AVMutableComposition composition];
        _originVideoComposition.naturalSize = self.videoSize;
        AVMutableCompositionTrack *compositionTrackA = [_originVideoComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                     preferredTrackID:kCMPersistentTrackID_Invalid];
        AVMutableCompositionTrack *compositionTrackB = [_originVideoComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                     preferredTrackID:kCMPersistentTrackID_Invalid];
        AVMutableCompositionTrack *compositionAudioTracks;
        NSArray *tracks = @[compositionTrackA, compositionTrackB];
        CMTime cursorTime = kCMTimeZero;
        NSUInteger videoCount = _dataSource.count;
        NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        NSInteger lastTranstionType = 0;
        NSMutableArray *transTionArr = [NSMutableArray array];
        for (NSUInteger i = 0; i < videoCount; i++) {
            JPVideoModel *videoModel = _dataSource[i];
            NSURL *url = videoModel.videoUrl;
            if (videoModel.isReverse == YES && videoModel.reverseUrl != nil) {
                url = videoModel.reverseUrl;
            }
            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:inputOptions];
            NSUInteger trackIndex = i % 2;
            CMTimeRange timeRangeInAsset;
            timeRangeInAsset = videoModel.timeRange;
            CGFloat radios = videoModel.radios;
            JPPhotoModel *photo = nil;
            if (videoModel.isImage == YES) {
                photo = [[JPPhotoModel alloc] init];
                photo.transtionType = videoModel.photoTransionType;
                CMTime startTime = cursorTime;
                CMTime durationTime = timeRangeInAsset.duration;
                
                if (lastTranstionType != 0) {
                    JPNewTranstionMode *transtionModel = transTionArr.lastObject;
                    transtionModel.secondImageModel = photo;
                }
                photo.timeRange = CMTimeRangeMake(startTime, durationTime);
            }
            if (lastTranstionType != 0) {
                JPNewTranstionMode *transtionModel = transTionArr.lastObject;
                transtionModel.backgroundMode = videoModel.rotationMode;
            }

            AVAssetTrack *assetTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
            AVMutableCompositionTrack *currentTrack = tracks[trackIndex];
            [currentTrack insertTimeRange:timeRangeInAsset ofTrack:assetTrack atTime:cursorTime error:nil];
            CMTime reallyTime = CMTimeMultiplyByFloat64(timeRangeInAsset.duration, radios);
            [currentTrack scaleTimeRange:CMTimeRangeMake(cursorTime, timeRangeInAsset.duration) toDuration:reallyTime];
            AVAssetTrack *audioAssetTrack = nil;
            if ([asset tracksWithMediaType:AVMediaTypeAudio].count > 0) {
                audioAssetTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
            }
            if (audioAssetTrack != nil && videoModel.timePlayType == JPVideoTimePlayTypeNone && videoModel.isReverse == NO) {
                if (compositionAudioTracks == nil) {
                    compositionAudioTracks = [_originVideoComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                }
                CMTime transtionTime = kCMTimeZero;
                if (videoModel.transtionType != 0 && i != videoCount - 1) {
                    transtionTime = JPVideoTranstionTime;
                }else if (i == videoCount  -1)
                {
                    transtionTime = JPVideoEndTransitionTime;
                }
                [compositionAudioTracks insertTimeRange:CMTimeRangeMake(timeRangeInAsset.start, CMTimeSubtract(timeRangeInAsset.duration, transtionTime)) ofTrack:audioAssetTrack atTime:cursorTime error:nil];
            }
            cursorTime = CMTimeAdd(cursorTime, reallyTime);
            if (videoModel.transtionType != 0 && i != videoCount - 1) {
                cursorTime = CMTimeSubtract(cursorTime, JPVideoTranstionTime);
                JPNewTranstionMode *model = [[JPNewTranstionMode alloc] init];
                model.foregroundMode = videoModel.rotationMode;
                if (videoModel.isImage == YES && videoModel.photoTransionType == JPPhotoModelTranstionSmallToBig) {
                    model.firstTrackIsImage = 1;
                    model.firstImageStartProgress = 0.7;
                }
                if (videoModel.isImage == YES && photo) {
                    model.firstImageModel = photo;
                }
                if (i < videoCount - 1) {
                    JPVideoModel *lastModel = _dataSource[i + 1];
                    if (lastModel.isImage == YES && lastModel.photoTransionType == JPPhotoModelTranstionBigToSmall) {
                        model.secondTrackIsImage = 1;
                        model.secondImageStartProgress = 0.7;
                    }
                }
                model.transtionTimeRange = CMTimeRangeMake(cursorTime, JPVideoTranstionTime);
                model.videoTranstionType = videoModel.transtionType;
                model.programStr = [JPTranstionsDefault  programStrGetWithTranstionModel:videoModel.transtionModel];
                [transTionArr addObject:model];
            }else if (i == videoCount - 1)
            {
                cursorTime = CMTimeSubtract(cursorTime, JPVideoEndTransitionTime);
            }
            lastTranstionType = videoModel.transtionType;
        }
        [JPTranstionsDefault shareInstance].transtionArr = transTionArr;
        [JPTranstionsDefault shareInstance].filterType = self.currentFilterType;
        _reallyDuration = cursorTime;
        NSString *endName = @"16to9fcp";
        if (self.aspectRatio == JPVideoAspectRatio1X1 || self.aspectRatio == JPVideoAspectRatioCircular) {
            endName = @"1to1fcp";
        }else if (self.aspectRatio == JPVideoAspectRatio9X16)
        {
            endName = @"9to16fcp";
        }else if (self.aspectRatio == JPVideoAspectRatio4X3)
        {
            endName = @"4to3fcp";
        }
        NSString *endPath = [JP_Resource_bundle pathForResource:endName ofType:@"mov"];
        AVURLAsset *endAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:endPath] options:inputOptions];
        NSUInteger trackIndex = videoCount % 2;
        AVMutableCompositionTrack *currentTrack = tracks[trackIndex];
        BOOL isex = NO;
        if (isex) {
            //永远不加片尾
            [currentTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, endAsset.duration) ofTrack:[endAsset tracksWithMediaType:AVMediaTypeVideo].firstObject atTime:cursorTime error:nil];
        }else {
            if (self.videoSource.count == 1) {
                [_originVideoComposition removeTrack:currentTrack];
            }
        }
        self.videoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:_originVideoComposition];
        self.videoComposition.frameDuration = CMTimeMake(1, 30); // 30 fps
        self.videoComposition.renderSize = self.videoSize;
        NSInteger index = 0;
        NSInteger noTranstionIndex = 0;
        NSInteger transtionIndex = 0;
        NSMutableArray *instructions = [NSMutableArray array];
        self.videoComposition.customVideoCompositorClass = [JPCustomCompositing class];
        for (AVMutableVideoCompositionInstruction *instruction in self.videoComposition.instructions) {
            if (instruction.layerInstructions.count == 2) {
                NSUInteger trackIndex = noTranstionIndex % 2;
                CMPersistentTrackID foregroundTrackIDs = [tracks[1 - trackIndex] trackID];
                CMPersistentTrackID backgroundTrackIDs = [tracks[trackIndex] trackID];
                JPCoustomInstruction *videoInstruction = [[JPCoustomInstruction alloc] initTransitionWithSourceTrackIDs:@[[NSNumber numberWithInt:foregroundTrackIDs], [NSNumber numberWithInt:backgroundTrackIDs]] forTimeRange:instruction.timeRange];
                videoInstruction.foregroundTrackID = foregroundTrackIDs;
                videoInstruction.backgroundTrackID = backgroundTrackIDs;
                videoInstruction.isTransition = YES;
                if (transtionIndex >= transTionArr.count) {
                    transtionIndex = transTionArr.count - 1;
                }
                JPNewTranstionMode *model = [transTionArr objectAtIndex:transtionIndex];
                videoInstruction.backgroundMode = model.backgroundMode;
                videoInstruction.foregroundMode = model.foregroundMode;
                if (model.secondImageModel) {
                    CMTime startTime = CMTimeAdd(instruction.timeRange.start, instruction.timeRange.duration);
                    CMTime endTime = CMTimeAdd(model.secondImageModel.timeRange.start, model.secondImageModel.timeRange.duration);
                    CMTime duration = CMTimeSubtract(endTime, startTime);
                    model.secondImageModel.timeRange = CMTimeRangeMake(startTime, duration);
                    model.secondImageModel.isStratTranstion = YES;
                    model.secondImageModel.startTranstionTimeRange = instruction.timeRange;
                }
                if (model.firstImageModel) {
                    CMTime startTime = model.firstImageModel.timeRange.start;
                    CMTime endTime = instruction.timeRange.start;
                    CMTime duration = CMTimeSubtract(endTime, startTime);
                    model.firstImageModel.timeRange = CMTimeRangeMake(startTime, duration);
                    model.firstImageModel.isEndTranstion = YES;
                    model.firstImageModel.endTranstionTimeRange = instruction.timeRange;
                }
                videoInstruction.transtionMode = model;
                [instructions addObject:videoInstruction];
                transtionIndex++;
            }else{
                CMPersistentTrackID trackId = [instruction.layerInstructions[0] trackID];
                JPCoustomInstruction *videoInstruction = [[JPCoustomInstruction alloc] initPassThroughTrackID:trackId forTimeRange:instruction.timeRange];
                videoInstruction.isTransition = NO;
                [instructions addObject:videoInstruction];
                JPVideoModel *videoModel = _dataSource[noTranstionIndex];
                GPUImageRotationMode rotationMode = videoModel.rotationMode;
                if (noTranstionIndex == _dataSource.count) {
                    rotationMode = kGPUImageNoRotation;
                    videoInstruction.isImage = NO;
                }else{
                    videoInstruction.isImage = videoModel.isImage;
                    videoInstruction.photoTranstionType = videoModel.photoTransionType;
                }
                videoInstruction.passthoudMode = rotationMode;
                noTranstionIndex ++;
            }
            index ++;
        }
        self.videoComposition.instructions = instructions;
    }
    return _originVideoComposition;
}


- (void)audioCompositionToBeNone
{
    if (_recordTrack) {
        [_reaocrdVideoComposition removeTrack:_recordTrack];
        _recordTrack = nil;
    }
    if (_musicCompositionTrack) {
        [_reaocrdVideoComposition removeTrack:_musicCompositionTrack];
        _musicCompositionTrack = nil;
    }
    if (_soundEffectAudioTrack) {
        [_reaocrdVideoComposition removeTrack:_soundEffectAudioTrack];
        _soundEffectAudioTrack = nil;
    }
    _originRecordTrack = nil;
    _reaocrdVideoComposition = nil;
    self.mixInputParameters = nil;

}

- (void)originCompositionBecomeNone
{
    _reallyDuration = kCMTimeZero;
    _originVideoComposition = nil;
    _reaocrdVideoComposition = nil;
    _recordTrack = nil;
    _originRecordTrack = nil;
    _musicCompositionTrack = nil;
    _soundEffectAudioTrack = nil;
    [self.allAudioParams removeAllObjects];
    self.allAudioParams = nil;
    self.mixInputParameters = nil;
    self.videoComposition = nil;
}

- (CMTime)totalVideoDuraion
{
    return _reallyDuration;
}

- (NSInteger)videoCount
{
    return self.videoSource.count;
}

- (NSString *)filterCNName
{
    return _currentFilterModel.filterCNName;
}


- (NSString *)backgorudMusicFileName
{
    return _backgroundMusic.fileName;
}

- (NSString *)backgorudMusicResouceId {
    return _backgroundMusic.resource_id;
}

- (NSArray *)soundsMusicArr {
    return [_soundEffectDataSource copy];
}

- (NSInteger)audioCount
{
    return self.audioSource.count;
}


- (JPBaseCompositionPlayer *)getCompositionPlayer
{
    JPBaseCompositionPlayer *compositionPlayer = [[JPVideoCompositionPlayer alloc] initWithRecordInfo:self withStickers:YES withComposition:YES];
    compositionPlayer.recordInfo = self;
    return compositionPlayer;
}

- (NSMutableDictionary *)configueDict
{
    NSMutableDictionary *dict = [super configueDict];
    if (_currentFilterModel) {
        [dict setObject:[_currentFilterModel configueDict] forKey:@"currentFilterModel"];
    }
    if (_backgroundMusic) {
        [dict setObject:[_backgroundMusic configueDict] forKey:@"backgroundMusic"];
    }
    [dict setObject:@(_volume) forKey:@"volume"];
    [dict setObject:@(_laterVolume) forKey:@"laterVolume"];
    [dict setObject:@(_hasChangedAspectRatio) forKey:@"hasChangedAspectRatio"];
    [dict setObject:@(_hasAddVideo) forKey:@"hasAddVideo"];
    if (_pattnaerArr && _pattnaerArr.count > 0) {
        NSMutableArray *array = [NSMutableArray array];
        for (JPPackagePatternAttribute *attr in _pattnaerArr) {
            [array addObject:[attr configueDict]];
        }
        [dict setObject:array forKey:@"pattnaerArr"];
    }
    if (_audioDataSource && _audioDataSource.count > 0) {
        NSMutableArray *array = [NSMutableArray array];
        for (JPAudioModel *attr in _audioDataSource) {
            [array addObject:[attr configueDict]];
        }
        [dict setObject:array forKey:@"audioDataSource"];
    }
    
    if (_soundEffectDataSource && _soundEffectDataSource.count > 0) {
        NSMutableArray *array = [NSMutableArray array];
        for (JPAudioModel *attr in _soundEffectDataSource) {
            [array addObject:[attr configueDict]];
        }
        [dict setObject:array forKey:@"soundEffectDataSource"];
    }
    
    if (_dataSource && _dataSource.count > 0) {
        NSMutableArray *array = [NSMutableArray array];
        for (JPVideoModel *attr in _dataSource) {
            [array addObject:[attr configueDict]];
        }
        [dict setObject:array forKey:@"dataSource"];
    }
    return dict;
}

- (void)updateInfoWithDict:(NSDictionary *)dict
{
    [super updateInfoWithDict:dict];
    NSDictionary *filter = [dict objectForKey:@"currentFilterModel"];
    if (filter) {
        _currentFilterModel = [[JPFilterModel alloc] init];
        [_currentFilterModel updateInfoWithDict:filter];
    }
    NSDictionary *backgroundMusic = [dict objectForKey:@"backgroundMusic"];
    if (backgroundMusic) {
        _backgroundMusic = [[JPAudioModel alloc] init];
        [_backgroundMusic updateInfoWithDict:backgroundMusic];
    }
    _volume = [[dict objectForKey:@"volume"] floatValue];
    _laterVolume = [[dict objectForKey:@"laterVolume"] floatValue];
    _hasChangedAspectRatio = [[dict objectForKey:@"hasChangedAspectRatio"] boolValue];
    _hasAddVideo = [[dict objectForKey:@"hasAddVideo"] boolValue];
    NSArray *pattnaerArr = [dict objectForKey:@"pattnaerArr"];
    if (pattnaerArr && pattnaerArr.count > 0) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *paDict in pattnaerArr) {
            JPPackagePatternAttribute *attribute = [[JPPackagePatternAttribute alloc] init];
            [attribute updateInfoWithDict:paDict];
            [array addObject:attribute];
        }
        _pattnaerArr = array;
    }
    NSArray *audioDataSource = [dict objectForKey:@"audioDataSource"];
    if (audioDataSource && audioDataSource.count > 0) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *paDict in audioDataSource) {
            JPAudioModel *attribute = [[JPAudioModel alloc] init];
            [attribute updateInfoWithDict:paDict];
            [array addObject:attribute];
        }
        _audioDataSource = array;
    }else{
        _audioDataSource = [NSMutableArray array];
    }
    
    NSArray *soundEffectDataSource = [dict objectForKey:@"soundEffectDataSource"];
    if (soundEffectDataSource && soundEffectDataSource.count > 0) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *paDict in soundEffectDataSource) {
            JPAudioModel *attribute = [[JPAudioModel alloc] init];
            [attribute updateInfoWithDict:paDict];
            [array addObject:attribute];
        }
        _soundEffectDataSource = array;
    }else{
        _soundEffectDataSource = [NSMutableArray array];
    }
    NSArray *dataSource = [dict objectForKey:@"dataSource"];
    if (dataSource && dataSource.count > 0) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *paDict in dataSource) {
            JPVideoModel *attribute = [[JPVideoModel alloc] init];
            [attribute updateInfoWithDict:paDict];
            [array addObject:attribute];
        }
        _dataSource = array;
    }else{
        _dataSource = [NSMutableArray array];
    }
}

@end
