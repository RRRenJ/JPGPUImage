//
//  JPVideoUtil.h
//  jper
//
//  Created by FoundaoTEST on 2017/3/23.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPVideoRecordInfo.h"

typedef void(^HKProgressHandle)(CGFloat progress);


typedef NS_ENUM(NSInteger, JPVideoMergeStatus)
{
    JPVideoMergeSuccess,
    JPVideoMergeFail
};

typedef void(^JPVideoGetFrameCompletion)(NSArray<UIImage *> *, CGFloat imageWidth);

@interface JPVideoUtil : NSObject
+ (void)newMoviewUrlWithVideoUrl:(NSURL *)videoUrl audioUrl:(NSURL *)audioUrl completion:(void(^)(JPVideoMergeStatus status, NSURL * url))completion;

+ (void)newMoviewUrlWithVideoUrl:(NSURL *)videoUrl audioTracks:(AVMutableComposition *)audioTrack allAudioParams:(NSMutableArray *)allAudioParams completion:(void(^)(JPVideoMergeStatus status, NSURL * url))completion;

+ (CMTime)getVideoDurationWithSourcePath:(NSURL *)path;

+ (void)getVideoFramesWithVideoUrl:(NSURL *)videoUrl renderWidth:(CGFloat)width renderHeight:(CGFloat)height completion:(JPVideoGetFrameCompletion)completion;
+ (CGSize)getVideoSizeWithUrl:(NSURL *)url;

+ (UIImage *)getFirstImageWithVideoUrl:(NSURL *)videoUrl;
+ (UIImage *)getFirstImageWithVideoAsset:(AVAsset *)videoAsset;
+ (NSString *)fileNameForDocumentMovie;
+ (NSString *)fileNameForDocumentAudio;
+ (NSString *)fileNameForDocumentImage;

+ (NSURL *)fileURLForDocumentMovieMP4;
+ (void)setSpeed:(JPVideoHowFast)howFast WithVideoUrl:(NSURL *)videoUrl andOutPutUrl:(NSURL *)outputUrl completed:(void(^)(NSError *))completed;
+ (AVAsset *)loadAudioTrackWithUrl:(NSURL *)videoUrl andTimeRange:(CMTimeRange)timeRange;

+ (void)assetByReversingAsset:(AVAsset *)asset videoComposition:(AVMutableVideoComposition *)videoComposition duration:(CMTime)duration outputURL:(NSURL *)outputURL progressHandle:(HKProgressHandle)progressHandle cancle:(BOOL *)cancle compoletion:(void(^)(NSURL *url))compoletion;

+ (GPUImageRotationMode)degressFromVideoFileWithAsset:(AVURLAsset *)asset;
@end
