//
//  JPPackageMenuAttribute.h
//  jper
//
//  Created by 藩 亜玲 on 2017/3/29.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPPublicConstant.h"
#import "GPUImagePicture.h"
#import "JPVideoRecordInfo.h"
@import Photos;

@interface JPPackagePatternAttribute : NSObject<NSCopying>

@property (nonatomic, strong) UIColor *backgroundColor;//背景色
@property (nonatomic, strong) UIColor *textColor;//字体颜色
@property (nonatomic, copy) NSString *text;//文字
@property (nonatomic, copy) NSString *subTitle;//文字
@property (nonatomic, copy) NSString *videoTime;//文字
@property (nonatomic, strong) NSString *logoImageFilePath;//logo
@property (nonatomic, assign) BOOL logoImageIfFromBundle;//logo
@property (nonatomic, strong) NSString *thumPictureName;//图片
@property (nonatomic, assign) BOOL thumImageIfFromBundle;//logo
@property (nonatomic, copy) NSString *resource_id;//素材的mid
@property (nonatomic, strong) NSString *pictureAssetID;
@property (nonatomic, assign) JPPackagePatternType patternType;
@property (nonatomic, assign) NSInteger selectColorIndex;
@property (nonatomic, assign) NSInteger selectBackColorIndex;
@property (nonatomic, assign) CMTimeRange timeRange;
@property (nonatomic, assign) CGRect apearFrame;
@property (nonatomic, strong) GPUImagePicture *imagePicture;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) BOOL needUpdateFrame;
@property (nonatomic, assign) BOOL needUpdate;
@property (nonatomic, strong) NSString *patternName;
@property (nonatomic, strong) NSString *thumImageUrlName;
@property (nonatomic, assign) BOOL thumImageUrlNameFromBundle;//logo
@property (nonatomic, assign) CGSize originImgSize;
@property (nonatomic, assign) JPPackagePatternTransitionAnimationType transitionAnimation;//压条转场动画
@property (nonatomic, strong) NSString *originImageName;
@property (nonatomic, assign) NSInteger textFontSize;
@property (nonatomic, strong) NSString *textFontName;
@property (nonatomic, assign) JPVideoAspectRatio videoFrame;;
@property (nonatomic, assign) BOOL isGlod;
@property (nonatomic, strong) NSString *firstPNGName;
@property (nonatomic, assign) NSInteger gifPNGCount;
@property (nonatomic, assign) CGSize gifImageSize;
@property (nonatomic, assign) NSInteger secondOfFrame;
@property (nonatomic, strong) NSString *thumFirstPNGName;
- (UIImage *)originImage;
- (NSString *)thumImageUrl;
- (UIImage *)logoImage;
- (UIImage *)thumPicture;
- (UIImage *)getlastImage;
- (UIImage *)getThumbImageForGifAtIndex:(NSInteger)index;
- (UIImage *)getImageForGifAtIndex:(NSInteger)index;
- (GLuint)getCurrentPictureTexureAtTime:(CMTime)currentTime;
- (GLfloat *)getReallyVertext;

- (NSMutableDictionary *)configueDict;
- (void)updateInfoWithDict:(NSDictionary *)dict;


@end
