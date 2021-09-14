//
//  JPBaseVideoRecordInfo.h
//  GPUImage
//
//  Created by FoundaoTEST on 2017/10/17.
//  Copyright © 2017年 Brad Larson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPGeneralFilter.h"


typedef NS_ENUM(NSInteger, JPVideoAspectRatio)
{
    JPVideoAspectRatioNomal = 0,
    JPVideoAspectRatio16X9 = 1,
    JPVideoAspectRatio9X16 = 2,
    JPVideoAspectRatio1X1 = 3,
    JPVideoAspectRatio4X3 = 4,
    JPVideoAspectRatioCircular = 5,
};

@class JPBaseCompositionPlayer;
@protocol JPVideoRecordInfoFilterManager <NSObject>

- (id<JPGeneralFilterDelegate>)filterManagerGeneralImageFilterDelegeteWithFilterType:(NSInteger)filterType;

@end

@interface JPBaseVideoRecordInfo : NSObject
@property (nonatomic, strong) NSString *recordId;
@property (nonatomic, strong) AVMutableComposition *composition;
@property (nonatomic, strong) AVMutableVideoComposition *videoComposition;
@property (nonatomic, strong) NSDate *saveDate;//保存到草稿箱的时间
@property (nonatomic, strong) NSString * localType;//1 是保存到草稿箱  2 本地化info 3 当前上传的info 4已上传的info
@property (nonatomic, copy) NSString * localPath;///合成后本地的path
@property (nonatomic, copy) NSString * onlineURL;///上传后线上url
@property (nonatomic, assign, readonly) CMTime totalVideoDuraion;
@property (nonatomic, assign, readonly) NSInteger videoCount;
@property (nonatomic,assign, readonly) CGSize videoSize;
@property (nonatomic, strong , readonly) NSString *filterCNName;
@property (nonatomic, strong, readonly) NSString *backgorudMusicFileName;
@property (nonatomic, strong, readonly) NSString *backgorudMusicResouceId;
@property (nonatomic, strong, readonly) NSArray *soundsMusicArr;//音效数组
@property (nonatomic, assign, readonly)  NSInteger audioCount;
@property (nonatomic) NSInteger currentFilterType;
@property (nonatomic, strong) NSMutableArray *allAudioParams;
@property (nonatomic, strong) AVMutableAudioMixInputParameters *mixInputParameters;
@property (nonatomic) JPVideoAspectRatio aspectRatio;
@property (nonatomic, strong, readonly) id<JPGeneralFilterDelegate>filterDelegate;
@property (nonatomic, strong, readonly) id<JPVideoRecordInfoFilterManager>filterManager;
- (instancetype)initWithFilterManager:(id<JPVideoRecordInfoFilterManager>)manager;
- (JPBaseCompositionPlayer *)getCompositionPlayer;
- (void)becomeOrigin;

- (NSMutableDictionary *)configueDict;
- (void)updateInfoWithDict:(NSDictionary *)dict;
@end
