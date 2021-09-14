//
//  JPTemplateCompositionInfo.m
//  GPUImage
//
//  Created by FoundaoTEST on 2017/9/13.
//  Copyright © 2017年 Brad Larson. All rights reserved.
//

#import "JPTemplateCompositionInfo.h"
#import "UIColor+Hex.h"
#import "JPCustomCompositing.h"
#import "AVMutableVideoCompositionInstruction+JPComposition.h"
#import "JPTranstionsDefault.h"
#import "JPCoustomInstruction.h"
#import "JPVideoUtil.h"
#import "JPTemplateCompositionPlayer.h"

#define JPTemplateEndTranstionTime CMTimeMake(15, 30)

@implementation JPTemplateHeaderInfo

- (instancetype)initWithDic:(NSDictionary *)dic
{
    if (self = [super init]) {
        _videoPath = [[NSBundle mainBundle] pathForResource:dic[@"videoPath"] ofType:nil];
        _videoTime = CMTimeMake([dic[@"videoTime"] integerValue], 30);
        _appearTimeRange = CMTimeRangeMake(kCMTimeZero, _videoTime);
        _startShowOpening = CMTimeMake([dic[@"startShowOpening"] integerValue], 30);
        _openingApearTimeRange = CMTimeRangeMake(_startShowOpening, CMTimeSubtract(_videoTime, _startShowOpening));
        NSArray *openingArr = [dic[@"openingFrame"] componentsSeparatedByString:@","];
        _openingFrame = CGRectMake([openingArr[0] floatValue], [openingArr[1] floatValue], [openingArr[2] floatValue], [openingArr[3] floatValue]);
        _hasLogo = [dic[@"hasLogo"] boolValue];
       
        NSArray *logoArr = [dic[@"logoFrame"] componentsSeparatedByString:@","];
        _logoFrame = CGRectMake([logoArr[0] floatValue], [logoArr[1] floatValue], [logoArr[2] floatValue], [logoArr[3] floatValue]);
        
        NSArray *titleArr = [dic[@"titleFrame"] componentsSeparatedByString:@","];
        _titleFrame = CGRectMake([titleArr[0] floatValue], [titleArr[1] floatValue], [titleArr[2] floatValue], [titleArr[3] floatValue]);
        _titleFontSize = [dic[@"titleFontSize"] integerValue];
        _titleFontName = dic[@"titleFontName"];
        _titleMaxCount = [dic[@"titleMaxCount"] integerValue];
        _titleColor = [dic[@"titleColor"] longValue];
        _titleBackColor = [dic[@"titleBackColor"] longValue];
        _titleBackAlpha = [dic[@"titleBackAlpha"] boolValue];
        _openingTranstionType = [dic[@"openingTranstionType"] integerValue];
        _endTranstionTime = CMTimeRangeMake(CMTimeSubtract(_videoTime, JPTemplateEndTranstionTime), JPTemplateEndTranstionTime);
    }
    return self;
}

- (void)updateStartPictureWithTiltle:(NSString *)title andLogo:(UIImage *)logo
{
    _title = title;
    _logoImage = logo;
    if ((title && title.length > 0) || logo) {
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(_openingFrame.origin.x, _openingFrame.origin.y, _openingFrame.size.width, _openingFrame.size.height)];
        backView.backgroundColor = [UIColor clearColor];
        if (_hasLogo && logo) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(_logoFrame.origin.x, _logoFrame.origin.y, _logoFrame.size.width, _logoFrame.size.height)];
            imageView.image = logo;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            [backView addSubview:imageView];
            imageView.layer.masksToBounds = YES;
            imageView.layer.cornerRadius = 10;
        }
        if (title) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(_titleFrame.origin.x, _titleFrame.origin.y, _titleFrame.size.width, _titleFrame.size.height)];
            label.text = title;
            label.font = [UIFont fontWithName:_titleFontName size:_titleFontSize];
            label.textAlignment = NSTextAlignmentCenter;
            if (_titleBackAlpha) {
                label.backgroundColor = [UIColor clearColor];
            }else{
                label.backgroundColor = [UIColor colorWithNumber:_titleBackColor];
            }
            label.textColor = [UIColor colorWithNumber:_titleColor];
            label.layer.shadowOpacity = 0.15;
            label.layer.shadowOffset = CGSizeMake(0, 1);
            label.layer.shadowRadius = 1.5;
            label.layer.shadowColor = [UIColor blackColor].CGColor;
            [backView addSubview:label];
        }
        
        backView.layer.contentsScale = [UIScreen mainScreen].scale;
        UIImage *image = nil;
        @autoreleasepool {
            UIGraphicsBeginImageContextWithOptions(backView.bounds.size, NO,0);
            [backView.layer renderInContext:UIGraphicsGetCurrentContext()];
            image= UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [backView layoutIfNeeded];
        }
        if (image) {
            _startPicture = [[GPUImagePicture alloc] initWithImage:image];
        }
    }else{
        _startPicture = nil;
    }
}

- (BOOL)canAddOpening:(CMTime)currentTime
{
    return CMTimeRangeContainsTime(_openingApearTimeRange, currentTime) && _startPicture;
}

- (BOOL)isEnding:(CMTime)currentTime
{
    return CMTimeRangeContainsTime(_endTranstionTime, currentTime);
}

- (CGFloat)endTranstionProgressWithTime:(CMTime)currentTime
{
    CMTime progressTime = CMTimeSubtract(currentTime, _endTranstionTime.start);
    Float64 progressSeconds = CMTimeGetSeconds(progressTime);
    return (CGFloat)(progressSeconds/CMTimeGetSeconds(JPTemplateEndTranstionTime));
}

- (CGFloat)openTranstionProgressWithTime:(CMTime)currentTime
{
    CMTime progressTime = CMTimeSubtract(currentTime, _openingApearTimeRange.start);
    Float64 progressSeconds = CMTimeGetSeconds(progressTime);
    CGFloat progress = (CGFloat)(progressSeconds/CMTimeGetSeconds(_openingApearTimeRange.duration));
    if (self.openingTranstionType == 1) {
        if (progress < 0.5) {
            return (progress / 0.5) * 0.9;
        }else{
            return 0.9 + 0.1 * (progress - 0.5) / 0.5;
        }
    }else{
        return progress;
    }
}


- (GPUImageRotationMode)insertThisTrackToCompostionTrack:(AVMutableCompositionTrack *)compositionTrack
{
    NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:_videoPath] options:inputOptions];
    [compositionTrack insertTimeRange:_appearTimeRange ofTrack:[videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject atTime:kCMTimeZero error:nil];
    return [JPVideoUtil degressFromVideoFileWithAsset:videoAsset];
}
@end


@implementation JPMusicAndFilter

- (instancetype)initWithDic:(NSDictionary *)dic
{
    if (self = [super init]) {
        _filterType = [dic[@"filterType"] integerValue];
        _musicPath = [[NSBundle mainBundle] pathForResource:dic[@"musicPath"] ofType:nil];
        _filterName = dic[@"filterName"] ;
        _musicName = dic[@"musicName"] ;

    }
    return self;
}

- (void)addMusicTrack:(AVMutableComposition *)composition
{
    if ([composition tracksWithMediaType:AVMediaTypeAudio].count > 0) {
        [composition removeTrack:[composition tracksWithMediaType:AVMediaTypeAudio].firstObject];
    }
    AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:_musicPath] options:inputOptions];
    CMTime duration = composition.duration;
    CMTime restTime = duration;
    CMTime musicStartTime = kCMTimeZero;
    CMTime backMusicDurationTime = asset.duration;
    while (CMTimeCompare(restTime, kCMTimeZero) == 1) {
        if (CMTimeCompare(restTime, backMusicDurationTime) == 1) {
            [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, backMusicDurationTime) ofTrack:[[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:musicStartTime error:nil];
            restTime = CMTimeSubtract(restTime,  backMusicDurationTime);
            musicStartTime = CMTimeAdd(musicStartTime,  backMusicDurationTime);
        }else{
            [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, restTime) ofTrack:[[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:musicStartTime error:nil];
            restTime = CMTimeSubtract(restTime,  restTime);
            musicStartTime = CMTimeAdd(musicStartTime,  restTime);
        }
    }
}

@end


//@property (nonatomic, strong) NSString *videoPath;
//@property (nonatomic, assign) CMTime videoTime;
//@property (nonatomic, assign) CMTimeRange aprearTimeRange;
//@property (nonatomic, assign) CMTimeRange startTranstionRange;
@implementation JPTemplateFooterInfo
- (instancetype)initWithDic:(NSDictionary *)dic andStartTime:(CMTime)startTime
{
    if (self = [super init]) {
        _videoPath = [[NSBundle mainBundle] pathForResource:dic[@"videoPath"] ofType:nil];
        _videoTime = CMTimeMake([dic[@"videoTime"] integerValue], 30);
        _aprearTimeRange = CMTimeRangeMake(startTime, _videoTime);
        _startTranstionRange = CMTimeRangeMake(startTime, JPTemplateEndTranstionTime);
        
        NSArray *openingArr = [dic[@"openingFrame"] componentsSeparatedByString:@","];
        _openingFrame = CGRectMake([openingArr[0] floatValue], [openingArr[1] floatValue], [openingArr[2] floatValue], [openingArr[3] floatValue]);
        _hasLogo = [dic[@"hasLogo"] boolValue];
        
        NSArray *logoArr = [dic[@"logoFrame"] componentsSeparatedByString:@","];
        _logoFrame = CGRectMake([logoArr[0] floatValue], [logoArr[1] floatValue], [logoArr[2] floatValue], [logoArr[3] floatValue]);
        
        NSArray *titleArr = [dic[@"titleFrame"] componentsSeparatedByString:@","];
        _titleFrame = CGRectMake([titleArr[0] floatValue], [titleArr[1] floatValue], [titleArr[2] floatValue], [titleArr[3] floatValue]);
        _titleFontSize = [dic[@"titleFontSize"] integerValue];
        _titleFontName = dic[@"titleFontName"];
        _titleMaxCount = [dic[@"titleMaxCount"] integerValue];
        _titleColor = [dic[@"titleColor"] longValue];
        _titleBackColor = [dic[@"titleBackColor"] longValue];
        _titleBackAlpha = [dic[@"titleBackAlpha"] boolValue];
        _openingTranstionType = [dic[@"openingTranstionType"] integerValue];        
    }
    return self;
}


- (void)updateStartPictureWithTiltle:(NSString *)title andLogo:(UIImage *)logo
{
    _title = title;
    _logoImage = logo;
    if ((title && title.length > 0) || logo) {
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(_openingFrame.origin.x, _openingFrame.origin.y, _openingFrame.size.width, _openingFrame.size.height)];
        backView.backgroundColor = [UIColor clearColor];
        if (_hasLogo && logo) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(_logoFrame.origin.x, _logoFrame.origin.y, _logoFrame.size.width, _logoFrame.size.height)];
            imageView.image = logo;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            [backView addSubview:imageView];
            imageView.layer.masksToBounds = YES;
            imageView.layer.cornerRadius = 10;
        }
        if (title) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(_titleFrame.origin.x, _titleFrame.origin.y, _titleFrame.size.width, _titleFrame.size.height)];
            label.text = title;
            label.font = [UIFont fontWithName:_titleFontName size:_titleFontSize];
            label.textAlignment = NSTextAlignmentCenter;
            if (_titleBackAlpha) {
                label.backgroundColor = [UIColor clearColor];
            }else{
                label.backgroundColor = [UIColor colorWithNumber:_titleBackColor];
            }
            label.layer.shadowOpacity = 0.15;
            label.layer.shadowOffset = CGSizeMake(0, 1);
            label.layer.shadowRadius = 1.5;
            label.layer.shadowColor = [UIColor blackColor].CGColor;
            label.textColor = [UIColor colorWithNumber:_titleColor];
            [backView addSubview:label];
        }
        
        backView.layer.contentsScale = [UIScreen mainScreen].scale;
        UIImage *image = nil;
        @autoreleasepool {
            UIGraphicsBeginImageContextWithOptions(backView.bounds.size, NO,0);
            [backView.layer renderInContext:UIGraphicsGetCurrentContext()];
            image= UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [backView layoutIfNeeded];
        }
        if (image) {
            _startPicture = [[GPUImagePicture alloc] initWithImage:image];
        }
        
    }else{
        _startPicture = nil;
    }
}


- (BOOL)isStart:(CMTime)currentTime
{
    return CMTimeRangeContainsTime(_startTranstionRange, currentTime);
}

- (CGFloat)startTranstionProgressWithTime:(CMTime)currentTime
{
    CMTime progressTime = CMTimeSubtract(currentTime, _startTranstionRange.start);
    Float64 progressSeconds = CMTimeGetSeconds(progressTime);
    return (1.0 - (CGFloat)(progressSeconds/CMTimeGetSeconds(_startTranstionRange.duration)));
}
- (BOOL)canAddOpening:(CMTime)currentTime
{
    return CMTimeRangeContainsTime(_aprearTimeRange, currentTime) && _startPicture;
}



- (CGFloat)openTranstionProgressWithTime:(CMTime)currentTime
{
    CMTime progressTime = CMTimeSubtract(currentTime, _aprearTimeRange.start);
    Float64 progressSeconds = CMTimeGetSeconds(progressTime);
    CGFloat progress = (CGFloat)(progressSeconds/CMTimeGetSeconds(_aprearTimeRange.duration));
    if (self.openingTranstionType == 1) {
        if (progress < 0.33) {
            return (progress / 0.33) * 0.9;
        }else{
            return 0.9 + 0.1 * (progress - 0.33) / 0.67;
        }
    }else{
        return progress;
    }
    
    
}



- (GPUImageRotationMode)insertThisTrackToCompostionTrack:(AVMutableCompositionTrack *)compositionTrack
{
    NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:_videoPath] options:inputOptions];
    [compositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, _videoTime) ofTrack:[videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject atTime:_aprearTimeRange.start error:nil];
    return [JPVideoUtil degressFromVideoFileWithAsset:videoAsset];
}
@end


@implementation JPSimpleVideoInfo
//@property (nonatomic, assign) CMTime videoTime;
//@property (nonatomic, assign) BOOL needPhoto;
//@property (nonatomic, strong) NSString *reallyVideoPath;
//@property (nonatomic, assign) CMTimeRange apearTimeRange;
//@property (nonatomic, assign) CMTimeRange videoAtTrackTimeRange;
- (instancetype)initWithStartTime:(CMTime)startTime andDic:(NSDictionary *)dic
{
    if (self = [super init]) {
        _videoTime = CMTimeMake([dic[@"videoTime"] integerValue], 30);
        _needPhoto = [dic[@"needPhoto"] boolValue];
        _videoAtTrackTimeRange = CMTimeRangeMake(startTime, _videoTime);
        self.startApearTime = kCMTimeZero;
    }
    return self;
}
- (void)setStartApearTime:(CMTime)startApearTime
{
    _startApearTime = startApearTime;
    _startApearTimeRange = CMTimeRangeMake(startApearTime, _videoTime);
}

- (GPUImageRotationMode)insertThisTrackToCompostionTrack:(AVMutableCompositionTrack *)compositionTrack
{
    NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:(_isSimple ? _exampleVideoPathUrl : _reallyVideoPathUrl) options:inputOptions];
    [compositionTrack insertTimeRange:_startApearTimeRange ofTrack:[videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject atTime:_videoAtTrackTimeRange.start error:nil];
    return [JPVideoUtil degressFromVideoFileWithAsset:videoAsset];
}


- (NSArray *)inserHeaderTrackToTrack:(NSArray<AVMutableCompositionTrack *>*)tracks andTotalTime:(CMTime)time andCurrentIndex:(NSInteger *)index andStartTime:(CMTime)startTime
{
    NSMutableArray *array = [NSMutableArray array];
    NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:(_isSimple ? _exampleVideoPathUrl : _reallyVideoPathUrl) options:inputOptions];
    CMTime duration = time;
    CMTime restTime = duration;
    CMTime musicStartTime = startTime;
    CMTime backMusicDurationTime = videoAsset.duration;
    GPUImageRotationMode mode = [JPVideoUtil degressFromVideoFileWithAsset:videoAsset];
    NSInteger currentIndex = *index;
    while (CMTimeCompare(restTime, kCMTimeZero) == 1) {
        if (CMTimeCompare(restTime, backMusicDurationTime) == 1) {
            [tracks[currentIndex % 2] insertTimeRange:CMTimeRangeMake(kCMTimeZero, backMusicDurationTime) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:musicStartTime error:nil];
            restTime = CMTimeSubtract(restTime,  backMusicDurationTime);
            musicStartTime = CMTimeAdd(musicStartTime,  backMusicDurationTime);
        }else{
            [tracks[currentIndex % 2] insertTimeRange:CMTimeRangeMake(kCMTimeZero, restTime) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:musicStartTime error:nil];
            restTime = CMTimeSubtract(restTime,  restTime);
            musicStartTime = CMTimeAdd(musicStartTime,  restTime);
        }
        [array addObject:@(mode)];
        currentIndex++;
    }
    *index = currentIndex;
    return array.copy;
}

- (UIImage *)getThumbFirstImage
{
    NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:(_isSimple ? _exampleVideoPathUrl : _reallyVideoPathUrl) options:inputOptions];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    assetImageGenerator.maximumSize = CGSizeMake(120, 120);
    CGImageRef thumbnailImageRef = NULL;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:_startApearTime actualTime:NULL error:&thumbnailImageGenerationError];
    if(!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
    if (thumbnailImageRef) {
        CGImageRelease(thumbnailImageRef);
    }
    return thumbnailImage;

}


- (UIImage *)getFirstImage
{
    NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:(_isSimple ? _exampleVideoPathUrl : _reallyVideoPathUrl) options:inputOptions];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    assetImageGenerator.maximumSize = CGSizeMake(1280, 1280);
    CGImageRef thumbnailImageRef = NULL;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:_startApearTime actualTime:NULL error:&thumbnailImageGenerationError];
    if(!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
    if (thumbnailImageRef) {
        CGImageRelease(thumbnailImageRef);
    }
    return thumbnailImage;
}

@end


@implementation JPContentVideoInfo




- (instancetype)initWithDic:(NSDictionary *)dic andStartTime:(CMTime)startTime
{
    if (self = [super init]) {
        _exampleVideoPath = [[NSBundle mainBundle] pathForResource:dic[@"exampleVideoPath"] ofType:nil];
        _totalVideoTime = CMTimeMake([dic[@"totalVideoTime"] integerValue], 30);
        _beginPhotoTime = CMTimeMake([dic[@"beginPhotoTime"] integerValue], 30);
        _photoApearTimeRange = CMTimeRangeMake(startTime, _beginPhotoTime);
        _totalApearTimeRange = CMTimeRangeMake(startTime, _totalVideoTime);
        _videoType = [dic[@"videoType"] integerValue];
        _videoTypeColor = [dic[@"videoTypeColor"] longValue];
        _videoTypeName = dic[@"videoTypeName"];
        _videoApearTimeRange = CMTimeRangeMake(CMTimeAdd(_photoApearTimeRange.start, _photoApearTimeRange.duration), CMTimeSubtract(_totalVideoTime, _beginPhotoTime));
        _photoStartTimeRange = CMTimeRangeMake(startTime, JPTemplateEndTranstionTime);
        _photoEndTimeRange = CMTimeRangeMake(CMTimeSubtract(_videoApearTimeRange.start, JPTemplateEndTranstionTime), JPTemplateEndTranstionTime);
        _videoStartTimeRange = CMTimeRangeMake(_videoApearTimeRange.start, JPTemplateEndTranstionTime);
        _videoEndTimeRange = CMTimeRangeMake(CMTimeSubtract(CMTimeAdd(_videoApearTimeRange.start, _videoApearTimeRange.duration), JPTemplateEndTranstionTime), JPTemplateEndTranstionTime);
        _apearMessage = dic[@"apearMessage"];
        
        NSArray *openingArr = [dic[@"beginOpeningFrame"] componentsSeparatedByString:@","];
        _beginOpeningFrame = CGRectMake([openingArr[0] floatValue], [openingArr[1] floatValue], [openingArr[2] floatValue], [openingArr[3] floatValue]);
        _hasLogo = [dic[@"hasLogo"] boolValue];
        
        NSArray *logoArr = [dic[@"logoFrame"] componentsSeparatedByString:@","];
        _logoFrame = CGRectMake([logoArr[0] floatValue], [logoArr[1] floatValue], [logoArr[2] floatValue], [logoArr[3] floatValue]);
        
        NSArray *titleArr = [dic[@"titleFrame"] componentsSeparatedByString:@","];
        _titleFrame = CGRectMake([titleArr[0] floatValue], [titleArr[1] floatValue], [titleArr[2] floatValue], [titleArr[3] floatValue]);
        _titleFontSize = [dic[@"titleFontSize"] integerValue];
        _titleFontName = dic[@"titleFontName"];
        _titleMaxCount = [dic[@"titleMaxCount"] integerValue];
        _titleColor = [dic[@"titleColor"] longValue];
        _titleBackColor = [dic[@"titleBackColor"] longValue];
        _titleBackAlpha = [dic[@"titleBackAlpha"] boolValue];
        _openingTranstionType = [dic[@"openingTranstionType"] integerValue];
        NSArray *viedeosArr = dic[@"videos"];
        _videos = [NSMutableArray arrayWithCapacity:viedeosArr.count];
        CMTime currentTime = _videoApearTimeRange.start;
        NSInteger index = 0;
        CMTime trackTime = kCMTimeZero;
        for (NSDictionary *simpleVideo in viedeosArr) {
            JPSimpleVideoInfo *simple = [[JPSimpleVideoInfo alloc] initWithStartTime:currentTime andDic:simpleVideo];
            [_videos addObject:simple];
            [self updateVideoPathUrl:nil adIndex:index andStartTime:trackTime];
            trackTime = CMTimeAdd(trackTime, simple.videoTime);
            index = index + 1;
            currentTime = CMTimeAdd(currentTime, simple.videoTime);
        }
    }
    return self;
}

- (void)updateStartPictureWithTiltle:(NSString *)title andLogo:(UIImage *)logo
{
    _title = title;
    _logoImage = logo;
    if ((title && title.length > 0) || logo) {
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(_beginOpeningFrame.origin.x, _beginOpeningFrame.origin.y, _beginOpeningFrame.size.width, _beginOpeningFrame.size.height)];
        backView.backgroundColor = [UIColor clearColor];
        if (_hasLogo && logo) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(_logoFrame.origin.x, _logoFrame.origin.y, _logoFrame.size.width, _logoFrame.size.height)];
            imageView.image = logo;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            [backView addSubview:imageView];
            imageView.layer.masksToBounds = YES;
            imageView.layer.cornerRadius = 10;
        }
        if (title) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(_titleFrame.origin.x, _titleFrame.origin.y, _titleFrame.size.width, _titleFrame.size.height)];
            label.text = title;
            label.font = [UIFont fontWithName:_titleFontName size:_titleFontSize];
            label.textAlignment = NSTextAlignmentCenter;
            if (_titleBackAlpha) {
                label.backgroundColor = [UIColor clearColor];
            }else{
                label.backgroundColor = [UIColor colorWithNumber:_titleBackColor];
            }
            label.textColor = [UIColor colorWithNumber:_titleColor];
            label.layer.shadowOpacity = 0.15;
            label.layer.shadowOffset = CGSizeMake(0, 1);
            label.layer.shadowRadius = 1.5;
            label.layer.shadowColor = [UIColor blackColor].CGColor;
            [backView addSubview:label];
        }
        
        backView.layer.contentsScale = [UIScreen mainScreen].scale;
        UIImage *image = nil;
        @autoreleasepool {
            UIGraphicsBeginImageContextWithOptions(backView.bounds.size, NO,0);
            [backView.layer renderInContext:UIGraphicsGetCurrentContext()];
            image= UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [backView layoutIfNeeded];
        }
        if (image) {
            _startPicture = [[GPUImagePicture alloc] initWithImage:image];
        }
    }else{
        _startPicture = nil;
    }
}


- (void)updateVideoPathUrl:(NSURL *)pathUrl adIndex:(NSInteger)index andStartTime:(CMTime)startTime
{
    JPSimpleVideoInfo *simple = _videos[index];
    if (pathUrl == nil) {
        pathUrl = [NSURL fileURLWithPath:_exampleVideoPath];
        startTime = kCMTimeZero;
        for (NSInteger count = 0; count < index; count++) {
            JPSimpleVideoInfo *simpleVideoInfo = _videos[count];
            startTime = CMTimeAdd(startTime, simpleVideoInfo.videoTime);
        }
        simple.isSimple = YES;
        simple.exampleVideoPathUrl = pathUrl;
    }else{
        simple.isSimple = NO;
        simple.reallyVideoPathUrl = pathUrl;
    }
    simple.startApearTime = startTime;
    if (index == 0) {
        UIImage *image =  [simple getFirstImage];
        _beginPicture = [[GPUImagePicture alloc] initWithImage:image];
    }
}


- (BOOL)canAddOpening:(CMTime)currentTime
{
    return CMTimeRangeContainsTime(_photoApearTimeRange, currentTime);
}

- (CGFloat)openTranstionProgressWithTime:(CMTime)currentTime
{
    CMTime progressTime = CMTimeSubtract(currentTime, _photoApearTimeRange.start);
    Float64 progressSeconds = CMTimeGetSeconds(progressTime);
    CGFloat progress = (CGFloat)(progressSeconds/CMTimeGetSeconds(_photoApearTimeRange.duration));
    if (self.openingTranstionType == 1) {
        if (progress < 0.33) {
            return (progress / 0.33) * 0.9;
        }else{
            return 0.9 + 0.1 * (progress - 0.33) / 0.67;
        }
    }else{
        return progress;
    }
}

- (BOOL)isInTranstionWithTime:(CMTime)currenTime
{
    return (CMTimeRangeContainsTime(_photoStartTimeRange, currenTime) || CMTimeRangeContainsTime(_photoEndTimeRange, currenTime) || CMTimeRangeContainsTime(_videoStartTimeRange, currenTime) || CMTimeRangeContainsTime(_videoEndTimeRange, currenTime));
}

- (UIImage *)getThumbImage
{
    return [_videos[0] getThumbFirstImage];
}

- (CGFloat)transtionProgressWithTime:(CMTime)currentTime
{
    
    if (CMTimeRangeContainsTime(_photoStartTimeRange, currentTime)) {
        CMTime progressTime = CMTimeSubtract(currentTime, _photoStartTimeRange.start);
        Float64 progressSeconds = CMTimeGetSeconds(progressTime);
        return (1.0 - (CGFloat)(progressSeconds/CMTimeGetSeconds(_photoStartTimeRange.duration)));
    }else if (CMTimeRangeContainsTime(_photoEndTimeRange, currentTime))
    {
        CMTime progressTime = CMTimeSubtract(currentTime, _photoEndTimeRange.start);
        Float64 progressSeconds = CMTimeGetSeconds(progressTime);
        return (CGFloat)(progressSeconds/CMTimeGetSeconds(_photoEndTimeRange.duration));
    }else if (CMTimeRangeContainsTime(_videoStartTimeRange, currentTime))
    {
        CMTime progressTime = CMTimeSubtract(currentTime, _videoStartTimeRange.start);
        Float64 progressSeconds = CMTimeGetSeconds(progressTime);
        return (1.0 - (CGFloat)(progressSeconds/CMTimeGetSeconds(_videoStartTimeRange.duration)));
    }else{
        CMTime progressTime = CMTimeSubtract(currentTime, _videoEndTimeRange.start);
        Float64 progressSeconds = CMTimeGetSeconds(progressTime);
        return (CGFloat)(progressSeconds/CMTimeGetSeconds(_videoEndTimeRange.duration));
    }
}


- (NSArray *)insertThisTrackToCompostionTrack:(NSArray<AVMutableCompositionTrack *> *)compositionTracks andCurrentIndex:(NSInteger *)index
{
    NSMutableArray *rotationModes = [NSMutableArray array];
    [rotationModes addObjectsFromArray:[_videos.firstObject inserHeaderTrackToTrack:compositionTracks andTotalTime:_beginPhotoTime andCurrentIndex:index andStartTime:_photoApearTimeRange.start]];
    NSInteger currentIndex = *index;
    for (JPSimpleVideoInfo *videoInfo in _videos) {
        [rotationModes addObject:@([videoInfo insertThisTrackToCompostionTrack:compositionTracks[currentIndex % 2]])];
        currentIndex++;
    }
    *index = currentIndex;
    return rotationModes.copy;
}
@end


@interface JPTemplateCompositionInfo ()

@property (nonatomic, strong) NSMutableArray *rotationModes;
@end


@implementation JPTemplateCompositionInfo


- (instancetype)initWithConfPath:(NSString *)path andVideoRecordFilterManager:(id<JPVideoRecordInfoFilterManager>)manager
{
    if (self = [super initWithFilterManager:manager]) {
        self.aspectRatio = JPVideoAspectRatio16X9;
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
        NSArray *musciFilters = dic[@"musicFilters"];
        NSMutableArray *musicfilterArr = [NSMutableArray arrayWithCapacity:musciFilters.count];
        for (NSDictionary *filter in musciFilters) {
            JPMusicAndFilter *musicAndFilter = [[JPMusicAndFilter alloc] initWithDic:filter];
            [musicfilterArr addObject:musicAndFilter];
        }
        _musicFilters = musicfilterArr.copy;
        _header = [[JPTemplateHeaderInfo alloc] initWithDic:dic[@"header"]];
        NSArray *contents = dic[@"contentVideos"];
        CMTime startTime = _header.videoTime;
        NSMutableArray *videosARR = [NSMutableArray arrayWithCapacity:contents.count];
        for (NSDictionary *video in contents) {
            JPContentVideoInfo *videoInfo = [[JPContentVideoInfo alloc] initWithDic:video andStartTime:startTime];
            [videosARR addObject:videoInfo];
            startTime = CMTimeAdd(startTime, videoInfo.totalVideoTime);
        }
        _contentVideos = videosARR.copy;
        _footer = [[JPTemplateFooterInfo alloc] initWithDic:dic[@"footer"] andStartTime:startTime];
        _currentUserMudicFilterIndex = -1;
        [self resetVideoCompostion];
    }
    return self;
}

- (void)resetVideoCompostion
{
    self.composition = [AVMutableComposition composition];
    _rotationModes = [NSMutableArray array];
    NSArray *videoTracks = nil;
    if (videoTracks == nil) {
        AVMutableCompositionTrack *videoTrack = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        AVMutableCompositionTrack *videoTrack1 = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        videoTracks = @[videoTrack, videoTrack1];
    }
    NSInteger trackIndex = 0;
    [_rotationModes addObject:@([_header insertThisTrackToCompostionTrack:videoTracks[trackIndex % 2]])];
    trackIndex++;
    for (JPContentVideoInfo *contentVideo in _contentVideos) {
        [_rotationModes addObjectsFromArray:[contentVideo insertThisTrackToCompostionTrack:videoTracks andCurrentIndex:&trackIndex]];
    }
    [_rotationModes addObject:@([_footer insertThisTrackToCompostionTrack:videoTracks[trackIndex % 2]])];
    [JPTranstionsDefault shareInstance].transtionArr = [NSArray array];
    [JPTranstionsDefault shareInstance].filterType = 0;
    self.videoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:self.composition];
    self.videoComposition.frameDuration = CMTimeMake(1, 30); // 30 fps
    self.videoComposition.renderSize = self.videoSize;
    NSInteger index = 0;
    NSMutableArray *instructions = [NSMutableArray array];
    self.videoComposition.customVideoCompositorClass = [JPCustomCompositing class];
    for (AVMutableVideoCompositionInstruction *instruction in self.videoComposition.instructions) {
        if (instruction.layerInstructions.count == 1) {
            CMPersistentTrackID trackId = [instruction.layerInstructions[0] trackID];
            JPCoustomInstruction *videoInstruction = [[JPCoustomInstruction alloc] initPassThroughTrackID:trackId forTimeRange:instruction.timeRange];
            videoInstruction.isTransition = NO;
            [instructions addObject:videoInstruction];
            GPUImageRotationMode rotationMode = [_rotationModes[index] integerValue];
            videoInstruction.passthoudMode = rotationMode;
            index ++;
        }
    }
    self.videoComposition.instructions = instructions;
}

- (void)switchFilterIndex
{
    _currentUserMudicFilterIndex = _currentUserMudicFilterIndex + 1;
    if (_currentUserMudicFilterIndex > _musicFilters.count - 1) {
        _currentUserMudicFilterIndex = 0;
    }
    self.currentFilterType = [_musicFilters objectAtIndex:_currentUserMudicFilterIndex].filterType;
    [self resetMusciTrack];
}

- (void)resetMusciTrack
{
    JPMusicAndFilter *musciAndFilter = [_musicFilters objectAtIndex:_currentUserMudicFilterIndex];
    [musciAndFilter addMusicTrack:self.composition];
}

- (void)resetFilter
{
    _currentUserMudicFilterIndex = -1;
    self.currentFilterType = 0;
}

- (JPMusicAndFilter *)currentMusicAnFilter
{
    return [_musicFilters objectAtIndex:_currentUserMudicFilterIndex];
}



- (CMTime)totalVideoDuraion
{
    return self.composition.duration;
}

- (NSInteger)videoCount
{
    return self.contentVideos.count;
}

- (NSString *)filterCNName
{
    return _currentMusicAnFilter.filterName;
}


- (NSString *)backgorudMusicFileName
{
    return _currentMusicAnFilter.musicName;
}

- (NSInteger)audioCount
{
    return 0;
}

- (JPBaseCompositionPlayer *)getCompositionPlayer
{
    JPBaseCompositionPlayer* templateCompositionPlayer = [[JPTemplateCompositionPlayer alloc] initWithRecordInfo:self withComposition:YES];
    JPBaseVideoRecordInfo *recordInfo = self;
    templateCompositionPlayer.recordInfo = recordInfo;
    return templateCompositionPlayer;
  
}

- (JPVideoAspectRatio)aspectRatio
{
    return JPVideoAspectRatio16X9;
}
@end
