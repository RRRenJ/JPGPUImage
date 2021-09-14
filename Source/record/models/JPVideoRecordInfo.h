//
//  JPVideoRecordSetting.h
//  jper
//
//  Created by FoundaoTEST on 2017/3/24.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPFilterModel.h"
#import "JPVideoModel.h"
#import "JPAudioModel.h"
#import "JPBaseVideoRecordInfo.h"
@interface NSObject (FlyElephant)
- (void)swizzleMethod:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector;
@end

@interface NSArray (JPObecjtAtIndex)

@end

@protocol JPPhotoLibraryViewControllerDelegate <NSObject>

- (void)selectTheVideoModel:(JPVideoModel *)videoModel;
- (void)videoBecomeNone;
@end


typedef NS_ENUM(NSInteger, JPVideoHowFast)
{
    JPVideoHowFastNormal = 0,
    JPVideoHowFastFast,
    JPVideoHowFastSlow,
};



@interface JPVideoRecordInfo : JPBaseVideoRecordInfo

@property (nonatomic, assign, readonly) CMTime totalDuration;
@property (nonatomic, assign, readonly) CMTime currentTotalTime;
@property (nonatomic, strong) JPFilterModel *currentFilterModel;
@property (nonatomic, readonly) NSArray<JPVideoModel *> *videoSource;
@property (nonatomic, readonly) NSArray *audioSource;
@property (nonatomic, readonly) NSArray *soundEffectSource;
@property (nonatomic, strong) JPAudioModel *backgroundMusic;
@property (nonatomic, assign) CGFloat volume;//原声音量
@property (nonatomic, assign) CGFloat laterVolume;//后期音量
@property (nonatomic, assign) BOOL hasChangedAspectRatio;
@property (nonatomic, strong) NSMutableArray *pattnaerArr;
@property (nonatomic, assign) BOOL hasAddVideo;

- (void)addVideoFile:(JPVideoModel *)videoModel;
- (void)deleteVideofile:(JPVideoModel *)videoModel;
- (void)becomeOrigin;
- (void)addAudioFile:(JPAudioModel *)audioModel;
- (void)deleteAudioFile:(JPAudioModel *)audioModel;
- (void)removeAllAudioFile;
- (void)removeAudioFilesWithArr:(NSArray *)array;
- (void)repelaceSoundEffectFileWithModel:(JPAudioModel *)model atIndex:(int)index;
- (void)addSoundEffectFile:(JPAudioModel *)audioModel;
- (void)deleteSoundEffectFile:(JPAudioModel *)audioModel;
- (void)removeSoundEffectFilesWithArr:(NSArray *)array;
- (void)exchangeVideoFileIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
- (void)audioCompositionToBeNone;
- (void)originCompositionBecomeNone;
+ (CGSize)getImageSizeWithRadio:(JPVideoAspectRatio)aspectRatio;

- (void)resetRecordAudio;

@end

