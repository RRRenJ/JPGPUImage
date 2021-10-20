//
//  JPVideoModel.m
//  jper
//
//  Created by FoundaoTEST on 2017/3/24.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#import "JPVideoModel.h"
#import "JPInkwellFilter.h"
#import "GPUImagePicture.h"
#import "JPVideoUtil.h"
#import "JPPublicConstant.h"
@implementation JPVideoTranstionsModel

- (NSMutableDictionary *)configueDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@(_transtionIndex) forKey:@"transtionIndex"];
    if (_title) {
        [dict setObject:_title forKey:@"title"];
    }
    if (_offImageName) {
        [dict setObject:_offImageName forKey:@"offImageName"];
    }
    if (_onImageName) {
        [dict setObject:_onImageName forKey:@"onImageName"];
    }
    if (_selectImageName) {
        [dict setObject:_selectImageName forKey:@"selectImageName"];
    }
    if (_transtionGlslFileName) {
           [dict setObject:_transtionGlslFileName forKey:@"transtionGlslFileName"];
    }
    return dict;
}

- (void)updateInfoWithDict:(NSDictionary *)dict
{
    _title = [dict objectForKey:@"title"];
    _transtionGlslFileName = [dict objectForKey:@"transtionGlslFileName"];
    _selectImageName = [dict objectForKey:@"selectImageName"];
    _onImageName = [dict objectForKey:@"onImageName"];
    _offImageName = [dict objectForKey:@"offImageName"];
    _transtionIndex = [[dict objectForKey:@"transtionIndex"] integerValue];

}

@end

@interface JPVideoModel ()
@property (nonatomic, assign) BOOL isLoadAllThumbImages;

@end


@implementation JPVideoModel



- (instancetype)init
{
    if (self = [super init]) {
        _isLoadAllThumbImages = NO;
        _rotationMode = kGPUImageNoRotation;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    JPVideoModel *videoModel = [[JPVideoModel alloc] init];
    videoModel.videoTime = _videoTime;
    videoModel.sourceType = _sourceType;
    videoModel.startTime = _startTime;
    videoModel.endTime = _endTime;
    videoModel.cloudId = _cloudId;
    videoModel.videoBaseFile = _videoBaseFile;
    videoModel.movieName = _movieName;
    videoModel.timeRange = _timeRange;
    videoModel.filterThumbImage = _filterThumbImage;
    videoModel.originThumbImage = _originThumbImage;
    videoModel.aspectRatio = _aspectRatio;
    videoModel.transtionType = _transtionType;
    videoModel.originImage = _originImage;
    videoModel.photoTransionType = _photoTransionType;
    videoModel.isImage = _isImage;
    videoModel.imageSize = _imageSize;
    videoModel.thumbImages = _thumbImages;
    videoModel.isReverse = _isReverse;
    videoModel.reverseVideoBaseFile = _reverseVideoBaseFile;
    videoModel.timePlayType = _timePlayType;
    videoModel.transtionModel = _transtionModel;
    videoModel.isLoadAllThumbImages = _isLoadAllThumbImages;
    videoModel.videoSize = _videoSize;
    return videoModel;
}

- (void)setVideoBaseFile:(NSString *)videoBaseFile
{
    _videoBaseFile = videoBaseFile;
    [self degressFromVideoFileWithAsset:[self videoUrl]];
}

- (NSURL *)videoUrl
{
    if (_videoBaseFile) {
        return [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:_videoBaseFile]];
    }else{
        return nil;
    }
    
}

- (NSURL *)reverseUrl
{
    if (_reverseVideoBaseFile) {
        return [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:_reverseVideoBaseFile]];
    }else{
        return nil;
    }
}

- (void)degressFromVideoFileWithAsset:(NSURL *)url
{
//    NSUInteger degress = 0;
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
            // Portrait
            _rotationMode = kGPUImageRotateRight;
        }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            _rotationMode = kGPUImageRotateLeft;
        }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
//            degress = 0;
        }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
            _rotationMode = kGPUImageRotate180;
        }
       
    }

}

- (void)asyncGetThumbImageWithCompletion:(void (^)(UIImage *, JPVideoModel *))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UIImage *image = self.originThumbImage;
        if (image == nil) {
            completion(nil, self);
            return ;
        }
     
        GPUImagePicture *source = [[GPUImagePicture alloc] initWithImage:image];
        JPInkwellFilter *filter = [[JPInkwellFilter alloc] init];
//        GPUImagePicture * sourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"inkwellMap" ofType:@"png"]]];
        UIImage * sourceImage = [UIImage imageNamed:@"inkwellMap" inBundle:JP_Resource_bundle compatibleWithTraitCollection:nil];
        GPUImagePicture * sourcePicture1 = [[GPUImagePicture alloc] initWithImage:sourceImage];
        [sourcePicture1 addTarget:filter atTextureLocation:1];
        [filter forceProcessingAtSize:source.outputImageSize];
        [filter useNextFrameForImageCapture];
        [source addTarget:filter];
        [source processImage];
        UIImage *filterImage = [filter imageFromCurrentFramebuffer];
        self.filterThumbImage = filterImage;
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(filterImage, self);
        });
        [source removeAllTargets];
        [sourcePicture1 removeAllTargets];

    });
}

- (void)dealloc
{
    
}

- (CGFloat)radios
{
    CGFloat radios = 1.0;
    if (self.timePlayType == JPVideoTimePlayTypeFast) {
        radios = 0.5;
    }else if (self.timePlayType == JPVideoTimePlayTypeSlow)
    {
        radios = 2.0;
    }
    return radios;
}

- (void)asyncGetAllThumbImages
{
    if (_isLoadAllThumbImages == YES) {
        return;
    }
    dispatch_queue_t aHQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    _thumbImages = [NSMutableArray array];
    __block CMTime totalTime = kCMTimeZero;
    NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *inputAsset = [[AVURLAsset alloc] initWithURL:self.videoUrl options:inputOptions];
    CMTime videoDuration = _videoTime;
    AVAssetImageGenerator * thumbImageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:inputAsset];
    thumbImageGenerator.appliesPreferredTrackTransform = YES;
    thumbImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    thumbImageGenerator.maximumSize = CGSizeMake(10000, (50));
    __block CMTime startTime = kCMTimeZero;
    __block CMTime actualTime;
    __block NSError *error = nil;
   __block CGImageRef halfWayImage = [thumbImageGenerator copyCGImageAtTime:startTime actualTime: &actualTime error: &error];
    __block UIImage *firsthumbnail;
    __block UIImage *lastThumbnail;
    __block CMTime duration = kCMTimeZero;
    if (halfWayImage) {
        UIImage *thumbnail = [[UIImage alloc] initWithCGImage:halfWayImage];
        firsthumbnail = thumbnail;
        _imageSize = thumbnail.size;
        CGImageRelease(halfWayImage);
    }else{
        UIImage *thumbnail = [UIImage imageNamed:@"logo@3x-1"];
        firsthumbnail = thumbnail;
        _imageSize = CGSizeMake(50, 50);
    }
    
    duration = CMTimeMultiplyByFloat64(CMTimeMake(1, 30),_imageSize.width / 2.0);
    totalTime = CMTimeAdd(totalTime, duration);
    [_thumbImages addObject:firsthumbnail];
    dispatch_async(aHQueue, ^{
        @autoreleasepool {
            if (CMTimeCompare(totalTime, videoDuration) < 0) {
                halfWayImage = [thumbImageGenerator copyCGImageAtTime:videoDuration actualTime: &actualTime error: &error];
                if (halfWayImage != nil) {
                    UIImage *thumbnail = [[UIImage alloc] initWithCGImage:halfWayImage];
                    lastThumbnail = thumbnail;
                    CGImageRelease(halfWayImage);
                }else{
                    UIImage *thumbnail = [UIImage imageNamed:@"logo@3x-1"];
                    lastThumbnail = thumbnail;
                }
                totalTime = CMTimeAdd(totalTime, duration);
                [_thumbImages addObject:lastThumbnail];
            }

//            if (CMTimeCompare(totalTime, videoDuration) < 0 ) {
//                [_thumbImages insertObject:firsthumbnail atIndex:0];
//                totalTime = CMTimeAdd(totalTime, duration);
//            }
//            if (CMTimeCompare(totalTime, videoDuration) < 0 ) {
//                [_thumbImages addObject:lastThumbnail];
//                totalTime = CMTimeAdd(totalTime, duration);
//            }
            startTime = CMTimeAdd(startTime, CMTimeMultiply(duration, 1));
            while (CMTimeCompare(videoDuration, totalTime) > 0) {
                halfWayImage = [thumbImageGenerator copyCGImageAtTime:startTime actualTime: &actualTime error: &error];
                if (halfWayImage != nil) {
                    UIImage *thumbnail = [[UIImage alloc] initWithCGImage:halfWayImage];
                    lastThumbnail = thumbnail;
                    CGImageRelease(halfWayImage);
                }else{
                    UIImage *thumbnail = [UIImage imageNamed:@"logo@3x-1"];
                    lastThumbnail = thumbnail;
                }
                [_thumbImages insertObject:lastThumbnail atIndex:_thumbImages.count - 1];
                totalTime = CMTimeAdd(totalTime, duration);
                startTime = CMTimeAdd(startTime, duration);
//                NSInteger count = arc4random() % 7 + 2;
//                for (NSInteger index = 0; index < count; index++) {
//                    [_thumbImages insertObject:lastThumbnail atIndex:_thumbImages.count - 2];
//                    totalTime = CMTimeAdd(totalTime, duration);
//                    startTime = CMTimeAdd(startTime, duration);
//                    if (CMTimeCompare(videoDuration, totalTime) <= 0) {
//                        break;
//                    }
//                }
            
            }
            _isLoadAllThumbImages = YES;
            if (self.thumImageGetCompletion) {
                self.thumImageGetCompletion();
                self.thumImageGetCompletion = nil;
            }
        }
    });
   }


- (void)setThumImageGetCompletion:(JPVideoModelGetThumbImageCompletion)thumImageGetCompletion
{
    if (_isLoadAllThumbImages) {
        _thumImageGetCompletion = nil;
    }else{
        _thumImageGetCompletion = thumImageGetCompletion;
    }
}


- (NSMutableDictionary *)configueDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSString *videoTime = [NSString stringWithFormat:@"%lld,%d", _videoTime.value, _videoTime.timescale];
    [dict setObject:videoTime forKey:@"videoTime"];
    NSString *videoSize = [NSString stringWithFormat:@"%.4f,%.4f", _videoSize.width, _videoSize.height];
    [dict setObject:videoSize forKey:@"videoSize"];
    [dict setObject:@(_sourceType) forKey:@"sourceType"];
    [dict setObject:@(_startTime) forKey:@"startTime"];
    [dict setObject:@(_endTime) forKey:@"endTime"];
    if (_cloudId) {
        [dict setObject:_cloudId forKey:@"cloudId"];
    }
    if (_videoBaseFile) {
        [dict setObject:_videoBaseFile forKey:@"videoBaseFile"];
    }
    if (_reverseVideoBaseFile) {
        [dict setObject:_reverseVideoBaseFile forKey:@"reverseVideoBaseFile"];
    }
    if (_movieName) {
        [dict setObject:_movieName forKey:@"movieName"];
    }
    NSString *timeRange = [NSString stringWithFormat:@"%lld,%d,%lld,%d", _timeRange.start.value, _timeRange.start.timescale, _timeRange.duration.value,_timeRange.duration.timescale];
    [dict setObject:timeRange forKey:@"timeRange"];
    [dict setObject:@(_rotationMode) forKey:@"rotationMode"];
    [dict setObject:@(_aspectRatio) forKey:@"aspectRatio"];
    [dict setObject:@(_transtionType) forKey:@"transtionType"];
    if (_transtionModel) {
        [dict setObject:[_transtionModel configueDict] forKey:@"transtionModel"];
    }
    [dict setObject:@(_photoTransionType) forKey:@"photoTransionType"];
    [dict setObject:@(_isImage) forKey:@"isImage"];
    NSString *imageSize = [NSString stringWithFormat:@"%.4f,%.4f", _imageSize.width, _imageSize.height];
    [dict setObject:imageSize forKey:@"imageSize"];
    NSString *videoStartTime = [NSString stringWithFormat:@"%lld,%d", _videoStartTime.value, _videoStartTime.timescale];
    [dict setObject:videoStartTime forKey:@"videoStartTime"];
    [dict setObject:@(_timePlayType) forKey:@"timePlayType"];
    [dict setObject:@(_isReverse) forKey:@"isReverse"];
    return dict;
}
- (void)updateInfoWithDict:(NSDictionary *)dict
{
    NSString *videoTime = [dict objectForKey:@"videoTime"];
    NSArray *videoTimes = [videoTime componentsSeparatedByString:@","];
    if (videoTimes && videoTimes.count == 2) {
        _videoTime = CMTimeMake([videoTimes[0] longLongValue], [videoTimes[1] intValue]);
    }
    NSString *videoSize = [dict objectForKey:@"videoSize"];
    NSArray *videoSizes = [videoSize componentsSeparatedByString:@","];
    if (videoSizes && videoSizes.count == 2) {
        _videoSize = CGSizeMake([videoSizes[0] floatValue], [videoSizes[1] floatValue]);
    }
    _sourceType = [[dict objectForKey:@"sourceType"] integerValue];
    _startTime = [[dict objectForKey:@"startTime"] floatValue];
    _endTime = [[dict objectForKey:@"endTime"] floatValue];
    _cloudId = [dict objectForKey:@"cloudId"];
    _videoBaseFile = [dict objectForKey:@"videoBaseFile"];
    _reverseVideoBaseFile = [dict objectForKey:@"reverseVideoBaseFile"];
    _movieName = [dict objectForKey:@"movieName"];
    NSString *timeRange = [dict objectForKey:@"timeRange"];
    NSArray *timeRanges = [timeRange componentsSeparatedByString:@","];
    if (timeRanges && timeRanges.count == 4) {
        _timeRange = CMTimeRangeMake(CMTimeMake([timeRanges[0] longLongValue], [timeRanges[1] intValue]), CMTimeMake([timeRanges[2] longLongValue], [timeRanges[3] intValue]));
    }
    _rotationMode = [[dict objectForKey:@"rotationMode"] integerValue];
    _aspectRatio = [[dict objectForKey:@"aspectRatio"] integerValue];
    _transtionType = [[dict objectForKey:@"transtionType"] integerValue];
    NSDictionary *transtionModel = [dict objectForKey:@"transtionModel"];
    if (transtionModel) {
        _transtionModel = [[JPVideoTranstionsModel alloc] init];
        [_transtionModel updateInfoWithDict:transtionModel];
    }
    _photoTransionType = [[dict objectForKey:@"photoTransionType"] integerValue];
    _isImage = [[dict objectForKey:@"isImage"] boolValue];
    NSString *imageSize = [dict objectForKey:@"imageSize"];
    NSArray *imageSizes = [imageSize componentsSeparatedByString:@","];
    if (imageSizes && imageSizes.count == 2) {
        _imageSize = CGSizeMake([imageSizes[0] floatValue], [imageSizes[1] floatValue]);
    }
    NSString *videoStartTime = [dict objectForKey:@"videoStartTime"];
    NSArray *videoStartTimes = [videoStartTime componentsSeparatedByString:@","];
    if (videoStartTimes && videoStartTimes.count == 2) {
        _videoStartTime = CMTimeMake([videoStartTimes[0] longLongValue], [videoStartTimes[1] intValue]);
    }
    _timePlayType = [[dict objectForKey:@"timePlayType"] integerValue];
    _isReverse = [[dict objectForKey:@"isReverse"] integerValue];
    _isLoadAllThumbImages = NO;
    self.originThumbImage = [JPVideoUtil getFirstImageWithVideoUrl:self.videoUrl];

}


@end
