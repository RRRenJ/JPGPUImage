//
//  JPVideoUtil.m
//  jper
//
//  Created by FoundaoTEST on 2017/3/23.
//  Copyright © 2017年 MuXiao. All rights reserved.
//
#import <MobileCoreServices/MobileCoreServices.h>
#import "JPVideoUtil.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "JPPublicConstant.h"
@implementation JPVideoUtil
+ (void)newMoviewUrlWithVideoUrl:(NSURL *)videoUrl audioUrl:(NSURL *)audioUrl completion:(void (^)(JPVideoMergeStatus,NSURL *))completion
{
    CMTime nextClistartTime = kCMTimeZero;
    NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];

    AVMutableComposition *comsition = [AVMutableComposition composition];
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoUrl options:inputOptions];
    CMTimeRange videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    AVMutableCompositionTrack *videoTrack = [comsition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    [videoTrack insertTimeRange:videoTimeRange ofTrack:videoAssetTrack atTime:nextClistartTime error:nil];
    AVURLAsset * audioAsset = [[AVURLAsset alloc] initWithURL:audioUrl options:inputOptions];
    CMTimeRange audioTimeRange = videoTimeRange;
    //音频通道
    AVMutableCompositionTrack * audioTrack = [comsition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    //音频采集通道
    AVAssetTrack * audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    //加入合成轨道中
    [audioTrack insertTimeRange:audioTimeRange ofTrack:audioAssetTrack atTime:nextClistartTime error:nil];
    // 3.1 - Create AVMutableVideoCompositionInstruction
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    
    // 3.2 - Create an AVMutableVideoCompositionLayerInstruction for the video track and fix the orientation.
    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
//    UIImageOrientation videoAssetOrientation_  = UIImageOrientationUp;
//    BOOL isVideoAssetPortrait_  = NO;
//    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
//    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
//        videoAssetOrientation_ = UIImageOrientationRight;
//        isVideoAssetPortrait_ = YES;
//    }
//    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
//        videoAssetOrientation_ =  UIImageOrientationLeft;
//        isVideoAssetPortrait_ = YES;
//    }
//    if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
//        videoAssetOrientation_ =  UIImageOrientationUp;
//    }
//    if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
//        videoAssetOrientation_ = UIImageOrientationDown;
//    }
    [videolayerInstruction setTransform:videoAssetTrack.preferredTransform atTime:kCMTimeZero];
    [videolayerInstruction setOpacity:0.0 atTime:videoAsset.duration];
    
    // 3.3 - Add instructions
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:videolayerInstruction,nil];
    
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
//    CGSize naturalSize;
//    if(isVideoAssetPortrait_){
//        naturalSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
//    } else {
//        naturalSize = videoAssetTrack.naturalSize;
//    }
//    float renderWidth, renderHeight;
//    renderWidth = naturalSize.width;
//    renderHeight = naturalSize.height;
//    mainCompositionInst.renderSize = CGSizeMake(renderWidth, renderHeight);
    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    
    //创建输出
    AVAssetExportSession * assetExport = [[AVAssetExportSession alloc] initWithAsset:comsition presetName:AVAssetExportPresetHighestQuality];
    NSString *fileName = [@"Documents/" stringByAppendingFormat:@"Movie%d.mp4",(int)[[NSDate date] timeIntervalSince1970]];
    NSString * pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:fileName];

    assetExport.outputURL = [NSURL fileURLWithPath:pathToMovie];//输出路径
    assetExport.outputFileType = AVFileTypeMPEG4;//输出类型
    assetExport.shouldOptimizeForNetworkUse = YES;
    assetExport.videoComposition = mainCompositionInst;
    __weak typeof(assetExport) weakAssetExport = assetExport;
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (weakAssetExport.status) {
                case AVAssetExportSessionStatusFailed: // 失败
                    NSLog(@"exportSessionError: %@",assetExport.error.description);
                    if (completion) {
                        completion(JPVideoMergeFail, nil);
                    }
                    break;
                case AVAssetExportSessionStatusCompleted: // 成功
                    UISaveVideoAtPathToSavedPhotosAlbum(pathToMovie, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                    if (completion) {
                        completion(JPVideoMergeSuccess, [NSURL fileURLWithPath:pathToMovie]);
                    }
                    break;
                default:
                    break;
            }
            
        });
    }];
}

+ (void)newMoviewUrlWithVideoUrl:(NSURL *)videoUrl audioTracks:(AVMutableComposition *)audioTrack allAudioParams:(NSMutableArray *)allAudioParams completion:(void(^)(JPVideoMergeStatus status, NSURL * url))completion
{
    if ([audioTrack tracksWithMediaType:AVMediaTypeAudio].firstObject == nil) {
        completion(JPVideoMergeSuccess,videoUrl);
        return;
    }
    
    AVMutableAudioMix *audioZeroMix = [AVMutableAudioMix audioMix];
    [audioZeroMix setInputParameters:allAudioParams];
      //创建输出
    AVAssetExportSession * assetExport = [[AVAssetExportSession alloc] initWithAsset:audioTrack presetName:AVAssetExportPresetHighestQuality];
    NSURL *outputUrl = [self fileURLForDocumentMovieMP4];
    assetExport.outputURL = outputUrl;//输出路径
    assetExport.outputFileType = AVFileTypeMPEG4;//输出类型
    assetExport.shouldOptimizeForNetworkUse = YES;
    assetExport.audioMix = audioZeroMix;
    __weak typeof(assetExport) weakAssetExport = assetExport;
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
        switch (weakAssetExport.status) {
            case AVAssetExportSessionStatusFailed: // 失败
                if (completion) {
                    completion(JPVideoMergeFail, nil);
                }
                break;
            case AVAssetExportSessionStatusCompleted: // 成功
                if (completion) {
                    CMTime nextClistartTime = kCMTimeZero;
                    AVMutableComposition *comsition = [AVMutableComposition composition];
                    NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
                    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoUrl options:inputOptions];
                    CMTime timeDuration = videoAsset.duration;
                    AVURLAsset *onlyAudioVideoAsset = [[AVURLAsset alloc] initWithURL:outputUrl options:inputOptions];
                    CMTimeRange onlyAudioVideoTimeRange = CMTimeRangeMake(kCMTimeZero, timeDuration);
                    AVMutableCompositionTrack *onlyAudioVideoTrackComposition = [comsition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                    AVAssetTrack *onlyAudioVideoTrack = [[onlyAudioVideoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
                    if (onlyAudioVideoTrack == nil) {
                        completion(JPVideoMergeSuccess,videoUrl);
                        return;
                    }
                    [onlyAudioVideoTrackComposition insertTimeRange:onlyAudioVideoTimeRange ofTrack:onlyAudioVideoTrack atTime:nextClistartTime error:nil];
                    
                    CMTimeRange videoTimeRange = CMTimeRangeMake(kCMTimeZero, timeDuration);
                    AVMutableCompositionTrack *videoTrackComposition = [comsition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
                    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
                    [videoTrackComposition insertTimeRange:videoTimeRange ofTrack:videoAssetTrack atTime:nextClistartTime error:nil];
                    
                    AVAssetExportSession *finalAssetExport = [[AVAssetExportSession alloc] initWithAsset:comsition presetName:AVAssetExportPresetHighestQuality];
                    NSURL *finalOutputUrl = [self fileURLForDocumentMovieMP4];
                    finalAssetExport.outputURL = finalOutputUrl;//输出路径
                    finalAssetExport.outputFileType = AVFileTypeMPEG4;//输出类型
                    finalAssetExport.shouldOptimizeForNetworkUse = YES;
                    
                    __weak typeof(assetExport) weakFinalAssetExport = finalAssetExport;
                    [finalAssetExport exportAsynchronouslyWithCompletionHandler:^{
                        switch (weakFinalAssetExport.status) {
                            case AVAssetExportSessionStatusFailed:
                                if (completion) {
                                    completion(JPVideoMergeFail, nil);
                                }
                                break;
                            case AVAssetExportSessionStatusCompleted:
                                if (completion) {
                                    completion(JPVideoMergeSuccess,finalOutputUrl);
                                }
                            break;
                            default:
                                break;
                        }
                    }];
                    //completion(JPVideoMergeSuccess,outputUrl);
                }
                break;
            default:
                break;
        }
    }];
}


+ (CMTime)getVideoDurationWithSourcePath:(NSURL *)path{
    NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *inputAsset = [[AVURLAsset alloc] initWithURL:path options:inputOptions];
    CMTime   time = [inputAsset duration];
    return time;
}

+ (void)getVideoFramesWithVideoUrl:(NSURL *)videoUrl renderWidth:(CGFloat)width renderHeight:(CGFloat)height completion:(JPVideoGetFrameCompletion)completion
{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @autoreleasepool {

            NSMutableArray<UIImage *> *imageArr = [NSMutableArray array];
            AVURLAsset *videoAsset = [AVURLAsset assetWithURL:videoUrl];
            CMTime totalTime = videoAsset.duration;
            AVURLAsset *asset = (AVURLAsset *)videoAsset;
            NSParameterAssert(asset);
            AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
            assetImageGenerator.appliesPreferredTrackTransform = YES;
            assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
            assetImageGenerator.maximumSize = CGSizeMake(width / 6, 1000);
            CGImageRef thumbnailImageRef = NULL;
            CMTime thumbnailImageTime = kCMTimeZero;
            NSError *thumbnailImageGenerationError = nil;
            thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:thumbnailImageTime actualTime:NULL error:&thumbnailImageGenerationError];
            if(!thumbnailImageRef)
                NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
            UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
            if (thumbnailImage) {
                [imageArr addObject:thumbnailImage];
                CFRelease(thumbnailImageRef);
            }
            NSInteger count = 6;
            CGFloat reallyWidth = width / count;
            CMTime duration = CMTimeMultiplyByFloat64(totalTime, 1.0 / ((CGFloat)(count - 1)));
            for (NSInteger index = 0; index < count - 1; index ++) {
                NSError *thumbnailImageGenerationError = nil;
                thumbnailImageTime = CMTimeAdd(thumbnailImageTime, duration);
                thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:thumbnailImageTime actualTime:NULL error:&thumbnailImageGenerationError];
                if(!thumbnailImageRef)
                    NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
                UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
                if (thumbnailImage) {
                    [imageArr addObject:thumbnailImage];
                    CGImageRelease(thumbnailImageRef);
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(imageArr, reallyWidth);
            });
        }
        });
 
    
}

+ (CGSize)getVideoSizeWithUrl:(NSURL *)url
{
    @autoreleasepool {
        NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:inputOptions];
        NSParameterAssert(asset);
        AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
        assetImageGenerator.appliesPreferredTrackTransform = YES;
        assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
        
        CGImageRef thumbnailImageRef = NULL;
        CFTimeInterval thumbnailImageTime = 0;
        NSError *thumbnailImageGenerationError = nil;
        thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 24)actualTime:NULL error:&thumbnailImageGenerationError];
        if(!thumbnailImageRef)
            NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
        UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
        if (thumbnailImageRef) {
            CGImageRelease(thumbnailImageRef);
        }
        return thumbnailImage.size;
  
    }
 }

+ (UIImage *)getFirstImageWithVideoUrl:(NSURL *)videoUrl
{
    @autoreleasepool {
        NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoUrl options:inputOptions];
        NSParameterAssert(asset);
        AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
        assetImageGenerator.appliesPreferredTrackTransform = YES;
        assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
        assetImageGenerator.maximumSize = CGSizeMake(100, 100);
        CGImageRef thumbnailImageRef = NULL;
        CFTimeInterval thumbnailImageTime = 10;
        NSError *thumbnailImageGenerationError = nil;
        thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 24)actualTime:NULL error:&thumbnailImageGenerationError];
        if(!thumbnailImageRef)
            NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
        UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
        if (thumbnailImageRef) {
            CGImageRelease(thumbnailImageRef);
        }
        return thumbnailImage;
    }
  
}

+ (UIImage *)getFirstImageWithVideoAsset:(AVAsset *)videoAsset
{
    @autoreleasepool {
        AVURLAsset *asset = (AVURLAsset *)videoAsset;
        NSParameterAssert(asset);
        AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
        assetImageGenerator.appliesPreferredTrackTransform = YES;
        assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
        
        CGImageRef thumbnailImageRef = NULL;
        CFTimeInterval thumbnailImageTime = 10;
        NSError *thumbnailImageGenerationError = nil;
        thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 24)actualTime:NULL error:&thumbnailImageGenerationError];
        if(!thumbnailImageRef)
            NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
        UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
        if (thumbnailImageRef) {
            CGImageRelease(thumbnailImageRef);
        }
        return thumbnailImage;

    }
 
}


+ (NSString *)fileNameForDocumentAudio {
    NSString *name = [NSString stringWithFormat:@"Documents/paike/Audio_%.0f.m4a",[[NSDate date] timeIntervalSince1970]];
    NSString *fullName = [NSHomeDirectory() stringByAppendingPathComponent:name];
    while ([[NSFileManager defaultManager] fileExistsAtPath:fullName]) {
        name = [NSString stringWithFormat:@"Documents/paike/Audio_%.0f%u.m4a",[[NSDate date] timeIntervalSince1970], arc4random() % 100000];
        fullName = [NSHomeDirectory() stringByAppendingPathComponent:name];
    }
    return name;
}

+ (NSString *)fileNameForDocumentImage
{
    NSString *name = [NSString stringWithFormat:@"Documents/paike/image_%.0f.png",[[NSDate date] timeIntervalSince1970]];
    NSString *fullName = [NSHomeDirectory() stringByAppendingPathComponent:name];
    while ([[NSFileManager defaultManager] fileExistsAtPath:fullName]) {
        name = [NSString stringWithFormat:@"Documents/paike/image_%.0f%u.png",[[NSDate date] timeIntervalSince1970], arc4random() % 100000];
        fullName = [NSHomeDirectory() stringByAppendingPathComponent:name];
    }
    return name;
}

+ (NSString *)fileNameForDocumentMovie{
    NSString *name = [NSString stringWithFormat:@"Documents/paike/Movie_%.0f.MOV",[[NSDate date] timeIntervalSince1970]];
    NSString *fullName = [NSHomeDirectory() stringByAppendingPathComponent:name];
    while ([[NSFileManager defaultManager] fileExistsAtPath:fullName]) {
        name = [NSString stringWithFormat:@"Documents/paike/Movie_%.0f%u.MOV",[[NSDate date] timeIntervalSince1970], arc4random() % 100000];
        fullName = [NSHomeDirectory() stringByAppendingPathComponent:name];
    }
    return name;
}

+ (NSURL *)fileURLForDocumentMovieMP4
{
    NSString *filePath = [JPER_RECORD_FILES_FOLDER stringByAppendingPathComponent:[NSString stringWithFormat:@"Movie%.0f.mp4",[[NSDate date] timeIntervalSince1970]]];
    while ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        filePath = [JPER_RECORD_FILES_FOLDER stringByAppendingPathComponent:[NSString stringWithFormat:@"Movie%.0f%u.mp4",[[NSDate date] timeIntervalSince1970], arc4random() % 100000]];
    }
    return [NSURL fileURLWithPath:filePath];
}

+ (void)setSpeed:(JPVideoHowFast)howFast WithVideoUrl:(NSURL *)videoUrl andOutPutUrl:(NSURL *)outputUrl completed:(void(^)(NSError *))completed;
 {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"video set thread: %@", [NSThread currentThread]);
        // 适配视频速度比率
        CGFloat scale = 1.0;
        if(howFast == JPVideoHowFastFast){
            scale = 0.2f;  // 快速 x5
        } else if (howFast == JPVideoHowFastSlow) {
            scale = 4.0f;  // 慢速 x4
        }
        // 获取视频
        NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];

        AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:videoUrl options:inputOptions];
        CMTime dutionTime = videoAsset.duration;
        if (howFast == JPVideoHowFastFast) {
            dutionTime = CMTimeMultiplyByFloat64(dutionTime, scale);
        }else if (howFast == JPVideoHowFastSlow) {
            dutionTime = CMTimeMultiplyByFloat64(dutionTime, 0.25); 
        }
        // 视频混合
        AVMutableComposition* mixComposition = [AVMutableComposition composition];
        // 视频轨道
        AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        // 音频轨道
        AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        // 视频的方向
        CGAffineTransform videoTransform = [videoAsset tracksWithMediaType:AVMediaTypeVideo].lastObject.preferredTransform;
        if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
            NSLog(@"垂直拍摄");
            videoTransform = CGAffineTransformMakeRotation(M_PI_2);
        }else if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
            NSLog(@"倒立拍摄");
            videoTransform = CGAffineTransformMakeRotation(-M_PI_2);
        }else if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
            NSLog(@"Home键右侧水平拍摄");
            videoTransform = CGAffineTransformMakeRotation(0);
        }else if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
            NSLog(@"Home键左侧水平拍摄");
            videoTransform = CGAffineTransformMakeRotation(M_PI);
        }
        // 根据视频的方向同步视频轨道方向
        compositionVideoTrack.preferredTransform = videoTransform;
        compositionVideoTrack.naturalTimeScale = 600;
        AVMutableAudioMixInputParameters *trackMix = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:compositionAudioTrack];
        [trackMix setVolume:0.05f atTime:kCMTimeZero];

        switch (howFast) {
            case JPVideoHowFastNormal:
                // 插入视频轨道
                [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,videoAsset.duration) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject] atTime:kCMTimeZero error:nil];
                // 插入音频轨道
                [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject] atTime:kCMTimeZero error:nil];
                break;
            case JPVideoHowFastSlow:
                // 插入视频轨道
                [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,videoAsset.duration) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject] atTime:kCMTimeZero error:nil];

                // 插入音频轨道
                [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, dutionTime) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject] atTime:kCMTimeZero error:nil];

                [compositionAudioTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, dutionTime) toDuration:CMTimeMake(dutionTime.value * scale, dutionTime.timescale)];
                break;
            case JPVideoHowFastFast:
                // 插入视频轨道
                [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,dutionTime) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject] atTime:kCMTimeZero error:nil];
                // 插入音频轨道
                [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject] atTime:kCMTimeZero error:nil];
                [compositionAudioTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) toDuration:CMTimeMake(videoAsset.duration.value * scale, videoAsset.duration.timescale)];
                break;
            default:
                break;
        }
        
        
        
        // 配置导出
        AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
        // 导出视频的临时保存路径
        NSURL *exportUrl = outputUrl;
        
        // 导出视频的格式 .MOV
        _assetExport.outputFileType = (NSString *)kUTTypeMPEG4;
        _assetExport.outputURL = exportUrl;
        _assetExport.shouldOptimizeForNetworkUse = YES;
        
        // 导出视频
        [_assetExport exportAsynchronouslyWithCompletionHandler:
         ^(void ) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 // 将导出的视频保存到相册
                 if (_assetExport.status == AVAssetExportSessionStatusCompleted) {
                       UISaveVideoAtPathToSavedPhotosAlbum(exportUrl.path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                     completed(nil);
                 }else{
                     completed(_assetExport.error);
                 }
             });
         }];
    });
}
+ (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *) error contextInfo:(void *) contextInfo {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Saved" message:@"The video was saved in Camera Roll." delegate:nil cancelButtonTitle:@"Sweet" otherButtonTitles:nil];
    [alertView show];
}

+ (AVAsset *)loadAudioTrackWithUrl:(NSURL *)videoUrl andTimeRange:(CMTimeRange)timeRange
{
    
    NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *inputAsset = [[AVURLAsset alloc] initWithURL:videoUrl options:inputOptions];
    AVAssetTrack *audioTrck = [inputAsset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    if (audioTrck) {
        AVMutableComposition *audioComposition = [AVMutableComposition composition];
        AVMutableCompositionTrack *audioTrackComposition = [audioComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioTrackComposition insertTimeRange:timeRange ofTrack:audioTrck atTime:kCMTimeZero error:nil];
        return audioComposition;
    }else{
        return  nil;
    }
}


+ (void)assetByReversingAsset:(AVAsset *)asset videoComposition:(AVMutableVideoComposition *)videoComposition duration:(CMTime)duration outputURL:(NSURL *)outputURL progressHandle:(HKProgressHandle)progressHandle cancle:(BOOL *)cancle compoletion:(void(^)(NSURL *url))compoletion
{
    if (*(cancle)) {
        compoletion(nil);
        return ;
    }
    NSError *error;
    //获取视频的总轨道
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] lastObject];
    //按照每秒一个视频的长度，分割轨道，生成对应的时间范围
    NSMutableArray *timeRangeArray = [NSMutableArray array];
    NSMutableArray *startTimeArray = [NSMutableArray array];
    CMTime startTime = kCMTimeZero;
    for (NSInteger i = 0; i <(CMTimeGetSeconds(duration)); i ++) {
        CMTimeRange timeRange = CMTimeRangeMake(startTime, CMTimeMakeWithSeconds(1, duration.timescale));
        if (CMTimeRangeContainsTimeRange(videoTrack.timeRange, timeRange)) {
            [timeRangeArray addObject:[NSValue valueWithCMTimeRange:timeRange]];
        } else {
            timeRange = CMTimeRangeMake(startTime, CMTimeSubtract(duration, startTime));
            [timeRangeArray addObject:[NSValue valueWithCMTimeRange:timeRange]];
        }
        [startTimeArray addObject:[NSValue valueWithCMTime:startTime]];
        startTime = CMTimeAdd(timeRange.start, timeRange.duration);
    }
    
    NSMutableArray *tracks = [NSMutableArray array];
    NSMutableArray *assets = [NSMutableArray array];
    
    
    for (NSInteger i = 0; i < timeRangeArray.count; i ++) {
        AVMutableComposition *subAsset = [[AVMutableComposition alloc]init];
        AVMutableCompositionTrack *subTrack =   [subAsset addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [subTrack  insertTimeRange:[timeRangeArray[i] CMTimeRangeValue] ofTrack:videoTrack atTime:[startTimeArray[i] CMTimeValue] error:nil];
        AVAsset *assetNew = [subAsset copy];
        AVAssetTrack *assetTrackNew = [[assetNew tracksWithMediaType:AVMediaTypeVideo] lastObject];
        [tracks addObject:assetTrackNew];
        [assets addObject:assetNew];
    }
    
    AVAssetReader *totalReader = nil ;;
    
    NSDictionary *totalReaderOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange], kCVPixelBufferPixelFormatTypeKey, nil];
    AVAssetReaderOutput *totalReaderOutput = nil;
    if (videoComposition) {
        totalReaderOutput = [AVAssetReaderVideoCompositionOutput assetReaderVideoCompositionOutputWithVideoTracks:@[videoTrack] videoSettings:totalReaderOutputSettings];
        ((AVAssetReaderVideoCompositionOutput *)totalReaderOutput).videoComposition = videoComposition;
    } else {
        totalReaderOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:totalReaderOutputSettings];
    }
    totalReader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    if([totalReader canAddOutput:totalReaderOutput]){
        [totalReader addOutput:totalReaderOutput];
    } else {
        compoletion(nil);
        return;
    }
    [totalReader startReading];
    NSMutableArray *sampleTimes = [NSMutableArray array];
    CMSampleBufferRef totalSample;
    
    while((totalSample = [totalReaderOutput copyNextSampleBuffer])) {
        CMTime presentationTime = CMSampleBufferGetPresentationTimeStamp(totalSample);
        [sampleTimes addObject:[NSValue valueWithCMTime:presentationTime]];
        CFRelease(totalSample);
    }
    
    //配置Writer
    AVAssetWriter *writer = [[AVAssetWriter alloc] initWithURL:outputURL
                                                      fileType:AVFileTypeMPEG4
                                                         error:&error];
    NSDictionary *videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:
                                           @(videoTrack.estimatedDataRate), AVVideoAverageBitRateKey,
                                           nil];
    CGFloat width = videoTrack.naturalSize.width;
    CGFloat height = videoTrack.naturalSize.height;
    if (videoComposition) {
        width = videoComposition.renderSize.width;
        height = videoComposition.renderSize.height;
    }
    NSDictionary *writerOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                          AVVideoCodecH264, AVVideoCodecKey,
                                          [NSNumber numberWithInt:height], AVVideoHeightKey,
                                          [NSNumber numberWithInt:width], AVVideoWidthKey,
                                          videoCompressionProps, AVVideoCompressionPropertiesKey,
                                          nil];
    AVAssetWriterInput *writerInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo
                                                                     outputSettings:writerOutputSettings
                                                                   sourceFormatHint:(__bridge CMFormatDescriptionRef)[videoTrack.formatDescriptions lastObject]];
    [writerInput setExpectsMediaDataInRealTime:NO];
    
    // Initialize an input adaptor so that we can append PixelBuffer
    AVAssetWriterInputPixelBufferAdaptor *pixelBufferAdaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:writerInput sourcePixelBufferAttributes:nil];
    
    [writer addInput:writerInput];
    
    [writer startWriting];
    [writer startSessionAtSourceTime:videoTrack.timeRange.start];
    
    NSInteger counter = 0;
    size_t countOfFrames = 0;
    size_t totalCountOfArray = 40;
    size_t arrayIncreasment = 40;
    CMSampleBufferRef *sampleBufferRefs = (CMSampleBufferRef *) malloc(totalCountOfArray * sizeof(CMSampleBufferRef ));
    memset(sampleBufferRefs, 0, sizeof(CMSampleBufferRef *) * totalCountOfArray);
    for (NSInteger i = tracks.count -1; i <= tracks.count; i --) {
        if (*(cancle)) {
            [writer cancelWriting];
            free(sampleBufferRefs);
            compoletion(nil);
            return;
        }
        AVAssetReader *reader = nil;
        
        countOfFrames = 0;
        AVAssetReaderOutput *readerOutput = nil;
        if (videoComposition) {
            readerOutput = [AVAssetReaderVideoCompositionOutput assetReaderVideoCompositionOutputWithVideoTracks:@[tracks[i]] videoSettings:totalReaderOutputSettings];
            ((AVAssetReaderVideoCompositionOutput *)readerOutput).videoComposition = videoComposition;
        } else {
            readerOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:tracks[i] outputSettings:totalReaderOutputSettings];
        }
        
        reader = [[AVAssetReader alloc] initWithAsset:assets[i] error:&error];
        if([reader canAddOutput:readerOutput]){
            [reader addOutput:readerOutput];
        } else {
            break;
        }
        [reader startReading];
        
        CMSampleBufferRef sample;
        while((sample = [readerOutput copyNextSampleBuffer])) {
            CMTime presentationTime = CMSampleBufferGetPresentationTimeStamp(sample);
            if (CMTIME_COMPARE_INLINE(presentationTime, >=, [startTimeArray[i] CMTimeValue])) {
                if (countOfFrames  + 1 > totalCountOfArray) {
                    totalCountOfArray += arrayIncreasment;
                    sampleBufferRefs = (CMSampleBufferRef *)realloc(sampleBufferRefs, totalCountOfArray);
                }
                *(sampleBufferRefs + countOfFrames) = sample;
                countOfFrames++;
            } else {
                if (sample != NULL) {
                    CFRelease(sample);
                }
            }
        }
        [reader cancelReading];
        for(NSInteger j = 0; j < countOfFrames; j++) {
            
            @autoreleasepool {
                // Get the presentation time for the frame
               if (counter > sampleTimes.count - 1) {
                   break;
               }
               CMTime presentationTime = [sampleTimes[counter] CMTimeValue];
               
               // take the image/pixel buffer from tail end of the array
               CMSampleBufferRef bufferRef = *(sampleBufferRefs + countOfFrames - j - 1);
               CVPixelBufferRef imageBufferRef = CMSampleBufferGetImageBuffer(bufferRef);
               
               while (!writerInput.readyForMoreMediaData) {
                   [NSThread sleepForTimeInterval:0.1];
               }
               [pixelBufferAdaptor appendPixelBuffer:imageBufferRef withPresentationTime:presentationTime];
               progressHandle(((CGFloat)counter/(CGFloat)sampleTimes.count));
               counter++;
               CFRelease(bufferRef);
               *(sampleBufferRefs + countOfFrames - j - 1) = NULL;
            }
        }
    }
    free(sampleBufferRefs);
    [writer finishWritingWithCompletionHandler:^{
        compoletion(outputURL);
    }];
    return;
}


+ (GPUImageRotationMode)degressFromVideoFileWithAsset:(AVURLAsset *)asset
{
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
            // Portrait
            return  kGPUImageRotateRight;
        }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            return kGPUImageRotateLeft;
        }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
            return kGPUImageNoRotation;
        }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
            return kGPUImageRotate180;
        }
    }
    return kGPUImageNoRotation;
}


@end
