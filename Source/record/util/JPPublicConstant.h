//
//  JPPublicConstant.h
//  jper
//
//  Created by FoundaoTEST on 2017/3/20.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#ifndef JPPublicConstant_h
#define JPPublicConstant_h

//屏幕的宽高
#define JPGPU_SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define JPGPU_SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define JP_AUDIO_VOLUME (0.12f)

#define JPER_RECORD_FILES_FOLDER [NSString stringWithFormat:@"%@/%@/%@", NSHomeDirectory(), @"tmp", @"zhisheng"]

typedef NS_ENUM(NSInteger, JPPlatformType) {//平台类型
    JPPlatformTypeUnknown = -1,
    JPPlatformTypeApp = 1,//app
    JPPlatformTypeWeb = 2,//web
    JPPlatformTypeH5 = 3,//h5
};


typedef NS_ENUM(NSUInteger, JPHttpRequestType) {
    JPHttpRequestTypeGet = 0,
    JPHttpRequestTypePost
};

typedef NS_ENUM(NSInteger, JPVideoEditStep){
    JPVideoEditStepFirst = 1,
    JPVideoEditStepSecond,
    JPVideoEditStepThird
};

typedef NS_ENUM(NSInteger, JPHttpRequestErrorCode)
{
    JPHttpRequestErrorCodeNoNetwork = -1009
};



#pragma mark - enums

typedef NS_ENUM(NSUInteger, JPPackageMenuType) {//包装元素
    JPPackageMenuTypeGraph = 0,//图案
    JPPackageMenuTypePattern = 1,//压条
    JPPackageMenuTypeMusic      //音乐/语音
};

typedef NS_ENUM(NSUInteger, JPPackageGraphPatternType) {//图案压条类型
    JPPackageGraphPatternTypeWeather = 0,//天气
    JPPackageGraphPatternTypeDate,//日期
    JPPackageGraphPatternTypePosition,//位置
    JPPackageGraphPatternTypePicture      //照片
};

//typedef NS_ENUM(NSInteger, JPPackageTextPatternType) {//文字压条类型
//    JPPackageTextPatternTypeWithNone = 99999,//纯文本
//    JPPackageTextPatternTypeWithPinyin,//文本+拼音
//    JPPackageTextPatternTypeWithBackgroundColor,//文本+背景色
//    JPPackageTextPatternTypeWithBackgroundColorAndPhoto//文本+背景色+logo
//};

typedef NS_ENUM(NSInteger, JPPackagePatternType) {//压条类型
    JPPackagePatternTypeWeather = 0,//天气
    JPPackagePatternTypeDate,//日期
    JPPackagePatternTypePosition,//位置
    JPPackagePatternTypePicture, //image
    JPPackagePatternTypeDownloadedPicture,
    JPPackagePatternTypeTextWithNone = 99999,//纯文本
    JPPackagePatternTypeTextWithPinyin,//文本+拼音
    JPPackagePatternTypeTextWithBorderLine,//文本+边框
    JPPackagePatternTypeTextWithUpAndDownLine,//文本+上下边框
    JPPackagePatternTypeTextWithLogoAndLine,
    JPPackagePatternTypeTextWithBackgroundColor,//文本+背景色
    JPPackagePatternTypeHollowOutPicture, //image
    JPPackagePatternTypeWeekPicture,
    JPPackagePatternTypeSixthTextPattern,
    JPPackagePatternTypeSeventhTextPattern,
    JPPackagePatternTypeEighthTextPattern,
    JPPackagePatternTypeNinthTextPattern,
    JPPackagePatternTypeTenthTextPattern,
    JPPackagePatternTypeGifPattern
};

typedef NS_ENUM(NSInteger, JPPackagePatternAttributeType) {//压条属性
    JPPackagePatternAttributeTypeGlobalSwitch,//全局开关
    JPPackagePatternAttributeTypeBackgroundColor,//背景色
    JPPackagePatternAttributeTypeFontColor,//文本字体颜色
    JPPackagePatternAttributeTypePhoto,//logo
    JPPackagePatternAttributeTypeTimeRange, //压条时间
    JPPackagePatternAttributeTypeTextFontSize, //字体大小
    JPPackagePatternAttributeTypeTextFont, //字体
};



typedef NS_ENUM(NSInteger, JPWeatherType) {//天气类型
    JPWeatherTypeSun,
    JPWeatherTypeCloudy,
    JPWeatherTypeRain,
    JPWeatherTypeSnow
};

typedef NS_ENUM(NSInteger, JPPackagePatternTransitionAnimationType) {
    JPPackagePatternTransitionAnimationTypeDefault//渐隐渐现
};


typedef NS_ENUM(NSInteger, JPTextFontType){
    JPTextFontTypePingFang = 1,
    JPTextFontTypeXindi,
    JPTextFontTypeXiSong,
    JPTextFontTypePlacardMTStdCond,
    JPTextFontTypeTrajanPro,
    JPTextFontTypeArista
};

typedef NS_ENUM(NSInteger, JPPushVideoStatusCode){
    JPPushVideoStatusCodeFailed = -1,
    JPPushVideoStatusCodeSuccess = 0,
    JPPushVideoStatusCodeInvalidToken = 10000,
    JPPushVideoStatusCodeIsPushed = 10001
};

//播放器的几种状态
typedef NS_ENUM(NSInteger, JPPlayerState) {
    JPPlayerStateFailed,     // 播放失败
    JPPlayerStateBuffering,  // 缓冲中
    JPPlayerStatePlaying,    // 播放中
    JPPlayerStateStopped,    // 停止播放
    JPPlayerStatePause       // 暂停播放
};

#define JPTimeRangeContainsTime(timeRange, time) (CMTimeCompare(timeRange.start, time) < 0 && CMTimeCompare(CMTimeAdd(timeRange.start, timeRange.duration), time) > 0)

#define JPVideoTranstionTime CMTimeMake(1, 1)

#define JPVideoEndTransitionTime CMTimeMake(0, 100)

#define JP_WILL_CHANGE_FILTER_TYPE_NOTIFICATION @"JP_WILL_CHANGE_FILTER_TYPE_NOTIFICATION"

#define JP_Resource_bundle [NSBundle bundleWithIdentifier:@"com.foundao.JPResource"]

#endif /* JPPublicConstant_h */
