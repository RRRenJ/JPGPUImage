//
//  JPTemplateCompositionInfo.h
//  GPUImage
//
//  Created by FoundaoTEST on 2017/9/13.
//  Copyright © 2017年 Brad Larson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "GPUImagePicture.h"
#import "JPBaseVideoRecordInfo.h"
@interface JPTemplateHeaderInfo : NSObject
@property (nonatomic, strong) NSString *videoPath;
@property (nonatomic, assign) CMTime videoTime;
@property (nonatomic, assign) CMTime startShowOpening;
@property (nonatomic, assign) CGRect openingFrame;
@property (nonatomic, assign) BOOL hasLogo;
@property (nonatomic, assign) CGRect logoFrame;
@property (nonatomic, assign) CGRect titleFrame;
@property (nonatomic, assign) NSInteger titleFontSize;
@property (nonatomic, strong) NSString *titleFontName;
@property (nonatomic, assign) NSInteger titleMaxCount;
@property (nonatomic, strong) GPUImagePicture *startPicture;
@property (nonatomic, assign) CMTimeRange appearTimeRange;
@property (nonatomic, assign) CMTimeRange openingApearTimeRange;
@property (nonatomic, assign) long titleColor;
@property (nonatomic, assign) long titleBackColor;
@property (nonatomic, assign) BOOL titleBackAlpha;
@property (nonatomic, assign) CMTimeRange endTranstionTime;
@property (nonatomic, assign) NSInteger openingTranstionType;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *logoImage;
- (instancetype)initWithDic:(NSDictionary *)dic;
- (void)updateStartPictureWithTiltle:(NSString *)title andLogo:(UIImage *)logo;
- (BOOL)canAddOpening:(CMTime)currentTime;
- (BOOL)isEnding:(CMTime)currentTime;
- (CGFloat)endTranstionProgressWithTime:(CMTime)currentTime;
- (CGFloat)openTranstionProgressWithTime:(CMTime)currentTime;
- (GPUImageRotationMode)insertThisTrackToCompostionTrack:(AVMutableCompositionTrack *)compositionTrack;
@end


@interface JPMusicAndFilter : NSObject
@property (nonatomic, assign) NSInteger filterType;
@property (nonatomic, strong) NSString *musicPath;
@property (nonatomic, strong) NSString *filterName;
@property (nonatomic, strong) NSString *musicName;
- (instancetype)initWithDic:(NSDictionary *)dic;
- (void)addMusicTrack:(AVMutableComposition *)composition;

@end


@interface JPTemplateFooterInfo : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *logoImage;
@property (nonatomic, strong) NSString *videoPath;
@property (nonatomic, assign) CMTime videoTime;
@property (nonatomic, assign) CMTimeRange aprearTimeRange;
@property (nonatomic, assign) CMTimeRange startTranstionRange;

@property (nonatomic, assign) CGRect openingFrame;
@property (nonatomic, assign) BOOL hasLogo;
@property (nonatomic, assign) CGRect logoFrame;
@property (nonatomic, assign) CGRect titleFrame;
@property (nonatomic, assign) NSInteger titleFontSize;
@property (nonatomic, strong) NSString *titleFontName;
@property (nonatomic, assign) NSInteger titleMaxCount;
@property (nonatomic, strong) GPUImagePicture *startPicture;
@property (nonatomic, assign) long titleColor;
@property (nonatomic, assign) long titleBackColor;
@property (nonatomic, assign) BOOL titleBackAlpha;
@property (nonatomic, assign) NSInteger openingTranstionType;


- (instancetype)initWithDic:(NSDictionary *)dic andStartTime:(CMTime)startTime;
- (BOOL)isStart:(CMTime)currentTime;
- (CGFloat)startTranstionProgressWithTime:(CMTime)currentTime;
- (GPUImageRotationMode)insertThisTrackToCompostionTrack:(AVMutableCompositionTrack *)compositionTrack;
- (BOOL)canAddOpening:(CMTime)currentTime;
- (CGFloat)openTranstionProgressWithTime:(CMTime)currentTime;
- (void)updateStartPictureWithTiltle:(NSString *)title andLogo:(UIImage *)logo;

@end


@interface JPSimpleVideoInfo : NSObject
@property (nonatomic, assign) CMTime videoTime;
@property (nonatomic, assign) BOOL needPhoto;
@property (nonatomic, strong) NSURL *reallyVideoPathUrl;
@property (nonatomic, strong) NSURL *exampleVideoPathUrl;
@property (nonatomic, assign) BOOL isSimple;
@property (nonatomic, assign) CMTime startApearTime;
@property (nonatomic, assign) CMTimeRange startApearTimeRange;
@property (nonatomic, assign) CMTimeRange videoAtTrackTimeRange;
- (instancetype)initWithStartTime:(CMTime)startTime andDic:(NSDictionary *)dic;
- (GPUImageRotationMode)insertThisTrackToCompostionTrack:(AVMutableCompositionTrack *)compositionTrack;
- (UIImage *)getFirstImage;
- (UIImage *)getThumbFirstImage;
@end


@interface JPContentVideoInfo : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *logoImage;
@property (nonatomic, strong) NSString *exampleVideoPath;
@property (nonatomic, assign) CMTime totalVideoTime;
@property (nonatomic, assign) CMTime beginPhotoTime;
@property (nonatomic, strong) GPUImagePicture *beginPicture;
@property (nonatomic, assign) CGRect beginOpeningFrame;
@property (nonatomic, assign) BOOL hasLogo;
@property (nonatomic, assign) CGRect logoFrame;
@property (nonatomic, assign) CGRect titleFrame;
@property (nonatomic, assign) NSInteger titleFontSize;
@property (nonatomic, strong) NSString *titleFontName;
@property (nonatomic, assign) NSInteger titleMaxCount;
@property (nonatomic, assign) long titleColor;
@property (nonatomic, assign) long titleBackColor;
@property (nonatomic, assign) BOOL titleBackAlpha;
@property (nonatomic, strong) GPUImagePicture *startPicture;
@property (nonatomic, assign) NSInteger openingTranstionType;
@property (nonatomic, assign) CMTimeRange photoApearTimeRange;
@property (nonatomic, assign) CMTimeRange videoApearTimeRange;
@property (nonatomic, assign) CMTimeRange photoStartTimeRange;
@property (nonatomic, assign) CMTimeRange photoEndTimeRange;
@property (nonatomic, assign) CMTimeRange videoStartTimeRange;
@property (nonatomic, assign) CMTimeRange videoEndTimeRange;
@property (nonatomic, assign) CMTimeRange totalApearTimeRange;
@property (nonatomic, assign) NSInteger videoType;
@property (nonatomic, strong) NSString *videoTypeName;
@property (nonatomic, assign) long videoTypeColor;
@property (nonatomic, strong) NSMutableArray<JPSimpleVideoInfo *> *videos;
@property (nonatomic, strong) NSString *apearMessage;

- (instancetype)initWithDic:(NSDictionary *)dic andStartTime:(CMTime)startTime;
- (void)updateStartPictureWithTiltle:(NSString *)title andLogo:(UIImage *)logo;
- (BOOL)canAddOpening:(CMTime)currentTime;
- (CGFloat)openTranstionProgressWithTime:(CMTime)currentTime;
- (BOOL)isInTranstionWithTime:(CMTime)currenTime;
- (CGFloat)transtionProgressWithTime:(CMTime)currentTime;
- (NSArray *)insertThisTrackToCompostionTrack:(NSArray<AVMutableCompositionTrack *> *)compositionTracks andCurrentIndex:(NSInteger *)index;
- (void)updateVideoPathUrl:(NSURL *)pathUrl adIndex:(NSInteger)index andStartTime:(CMTime)startTime;
- (UIImage *)getThumbImage;
@end


@interface JPTemplateCompositionInfo : JPBaseVideoRecordInfo

@property (nonatomic, strong) NSArray<JPContentVideoInfo *> *contentVideos;
@property (nonatomic, strong) JPTemplateHeaderInfo *header;
@property (nonatomic, strong) JPTemplateFooterInfo *footer;
@property (nonatomic, strong) NSArray<JPMusicAndFilter *> * musicFilters;
@property (nonatomic, assign) NSInteger currentUserMudicFilterIndex;
@property (nonatomic, strong) JPMusicAndFilter *currentMusicAnFilter;
- (instancetype)initWithConfPath:(NSString *)path andVideoRecordFilterManager:(id<JPVideoRecordInfoFilterManager>)manager;
- (void)resetVideoCompostion;
- (void)switchFilterIndex;
- (void)resetFilter;
@end
