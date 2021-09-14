//
//  JPPackageMenuAttribute.m
//  jper
//
//  Created by 藩 亜玲 on 2017/3/29.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#import "JPPackagePatternAttribute.h"
#import "JPPublicConstant.h"
#import "UIColor+JP_Helper.h"

@interface JPPackagePatternAttribute ()
{
    GLfloat vertext[8];
}
@end
@implementation JPPackagePatternAttribute


- (id)copyWithZone:(NSZone *)zone
{
    JPPackagePatternAttribute *attribute = [[JPPackagePatternAttribute allocWithZone:zone] init];
    attribute.text = _text;
    attribute.subTitle = _subTitle;
    attribute.backgroundColor = _backgroundColor;
    attribute.textColor = _textColor;
    attribute.logoImageFilePath = _logoImageFilePath;
    attribute.logoImageIfFromBundle = _logoImageIfFromBundle;
    attribute.thumPictureName = _thumPictureName;
    attribute.thumImageIfFromBundle = _thumImageIfFromBundle;
    attribute.pictureAssetID = _pictureAssetID;
    attribute.patternType = _patternType;
    attribute.selectBackColorIndex = _selectBackColorIndex;
    attribute.selectColorIndex = _selectColorIndex;
    attribute.videoTime = _videoTime;
    attribute.timeRange = kCMTimeRangeZero;
    attribute.patternName = _patternName;
    attribute.resource_id = _resource_id;
    attribute.originImageName = _originImageName;
    attribute.frame = _frame;
//    attribute.textFontType = _textFontType;
    attribute.textFontSize = _textFontSize;
    attribute.textFontName = _textFontName;
    attribute.originImgSize = _originImgSize;
    attribute.isGlod = _isGlod;
    attribute.thumImageUrlName = _thumImageUrlName;
    attribute.thumImageUrlNameFromBundle = _thumImageUrlNameFromBundle;
    attribute.firstPNGName = _firstPNGName;
    attribute.gifPNGCount = _gifPNGCount;
    attribute.secondOfFrame = _secondOfFrame;
    attribute.thumFirstPNGName = _thumFirstPNGName;
    return attribute;
}

- (NSString *)thumImageUrl
{
    if (_thumImageUrlName) {
        if (_thumImageUrlNameFromBundle) {
            return [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:_thumImageUrlName];
        }else{
            return _thumImageUrlName;
        }
    }else{
        return nil;
    }
}

- (GLuint)getCurrentPictureTexureAtTime:(CMTime)currentTime
{
    if (_patternType != JPPackagePatternTypeGifPattern) {
        return _imagePicture.framebufferForOutput.texture;
    }else{
        GLuint texure = 0;
        NSInteger startIndex = CMTimeGetSeconds(_timeRange.start) * _secondOfFrame;
        NSInteger currentIndex = CMTimeGetSeconds(currentTime) * _secondOfFrame;
        NSInteger reallyIndex = currentIndex - startIndex;
        if (reallyIndex < 0) {
            reallyIndex = 0;
        }else if (reallyIndex >= self.gifPNGCount)
        {
            reallyIndex = self.gifPNGCount - 1;
        }
        if (reallyIndex < self.gifPNGCount - 1) {
            UIImage *image = [self getImageForGifAtIndex:reallyIndex];
            GPUImagePicture *imagePicture = [[GPUImagePicture alloc] initWithImage:image];
            texure = [[imagePicture framebufferForOutput] texture];
        }else{
            if (_imagePicture == nil) {
                UIImage *image = [self getlastImage];
                _imagePicture = [[GPUImagePicture alloc] initWithImage:image];
            }
            texure = [[_imagePicture framebufferForOutput] texture];
        }
        return texure;
    }
}



- (void)setOriginImageName:(NSString *)originImageName
{
    if ([_originImageName isEqualToString:originImageName] == NO) {
        _originImageName = originImageName;
        _needUpdate = YES;
    }
}

- (UIImage *)originImage
{
    JPPackagePatternAttribute *model = self;
    if (model.patternType == JPPackagePatternTypeWeekPicture || model.patternType == JPPackagePatternTypeHollowOutPicture || model.patternType == JPPackagePatternTypePicture || model.patternType == JPPackagePatternTypeDownloadedPicture) {
        if (model.patternType == JPPackagePatternTypeHollowOutPicture || model.patternType == JPPackagePatternTypeWeekPicture) {
            NSString *title = @"4to3";
            if (model.videoFrame == JPVideoAspectRatio16X9) {
                title = @"16to9";
            }else if (model.videoFrame == JPVideoAspectRatio9X16)
            {
                title = @"9to16";
                
            }else if (model.videoFrame == JPVideoAspectRatio1X1 || model.videoFrame == JPVideoAspectRatioCircular)
            {
                title = @"1to1";
            }
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@%@", title, model.originImageName] ofType:@"png"];
            @autoreleasepool {
                return [UIImage imageWithContentsOfFile:imagePath];
            }
        }else if(model.patternType == JPPackagePatternTypePicture){
            @autoreleasepool {
                return model.thumPicture;
            }
        } else if (JPPackagePatternTypeDownloadedPicture == model.patternType){
            NSString *fullPath = [NSHomeDirectory() stringByAppendingPathComponent:model.originImageName];
            if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
                @autoreleasepool {
                    return [UIImage imageWithContentsOfFile:fullPath];
                }
            }else{
                @autoreleasepool {
                    return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:_originImageName ofType:@"png"]];
                }
            }
        }else{
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:model.originImageName ofType:@"png"];
            @autoreleasepool {
                return [UIImage imageWithContentsOfFile:imagePath];
            }
        }
        return nil;
    }
    return nil;
}

- (void)setText:(NSString *)text
{
    if ([_text isEqualToString:text] == NO) {
        _text = text;
        _needUpdate = YES;
    }
}

- (void)setTextFontSize:(NSInteger)textFontSize
{
    if (textFontSize != _textFontSize) {
        _textFontSize = textFontSize;
        _needUpdate = YES;
    }
}

- (void)setTextFontName:(NSString *)textFontName {
    if (textFontName != _textFontName) {
        _textFontName = textFontName;
        _needUpdate = YES;
    }
}

- (void)setFirstPNGName:(NSString *)firstPNGName
{
    if (_firstPNGName != firstPNGName) {
        _firstPNGName = firstPNGName;
        _needUpdate = YES;
    }
}

//- (void)setTextFontType:(JPTextFontType)textFontType
//{
//    if (textFontType != _textFontType) {
//        _textFontType = textFontType;
//        _needUpdate = YES;
//    }
//}

- (void)setSubTitle:(NSString *)subTitle {
    if (NO == [_subTitle isEqualToString:subTitle]) {
        _subTitle = subTitle;
        _needUpdate = YES;
    }
}

- (void)setVideoTime:(NSString *)videoTime
{
    if ([_videoTime isEqualToString:videoTime] == NO) {
        _videoTime = videoTime;
        _needUpdate = YES;
    }
}

- (UIImage *)thumPicture
{
    NSString *filePath = nil;
    if (_thumPictureName) {
        if (_thumImageIfFromBundle) {
            return [UIImage imageNamed:_thumPictureName];
        }else{
            filePath = [NSHomeDirectory() stringByAppendingPathComponent:_thumPictureName];
        }
    }
    if (filePath) {
        return [UIImage imageWithContentsOfFile:filePath];
    }else{
        return nil;
    }
}

- (void)setThumPictureName:(NSString *)thumPictureName
{
  if (![_thumPictureName isEqualToString:thumPictureName]) {
       _thumPictureName = thumPictureName;
       _needUpdate = YES;
   }
}

- (void)setThumImageIfFromBundle:(BOOL)thumImageIfFromBundle
{
    if (_thumImageIfFromBundle != thumImageIfFromBundle) {
        _thumImageIfFromBundle = thumImageIfFromBundle;
        _needUpdate = YES;
    }
}

- (void)setLogoImageIfFromBundle:(BOOL)logoImageIfFromBundle
{
    if (logoImageIfFromBundle != _logoImageIfFromBundle) {
        _logoImageIfFromBundle = logoImageIfFromBundle;
        _needUpdate = YES;
    }
}

- (void)setLogoImageFilePath:(NSString *)logoImageFilePath
{
    if (![_logoImageFilePath isEqualToString:logoImageFilePath]) {
        _logoImageFilePath = logoImageFilePath;
        _needUpdate = YES;
    }
}

- (UIImage *)logoImage
{
    NSString *filePath = nil;
    if (_logoImageFilePath) {
        if (_logoImageIfFromBundle) {
           return [UIImage imageNamed:_logoImageFilePath];
        }else{
            filePath = [NSHomeDirectory() stringByAppendingPathComponent:_logoImageFilePath];
        }
    }
    if (filePath) {
        return [UIImage imageWithContentsOfFile:filePath];
    }else{
        return nil;
    }
}

- (void)setSelectColorIndex:(NSInteger)selectColorIndex
{
    if (_selectColorIndex != selectColorIndex) {
        _selectColorIndex = selectColorIndex;
        _needUpdate = YES;
    }
}

- (void)setSelectBackColorIndex:(NSInteger)selectBackColorIndex
{
    if (_selectBackColorIndex != selectBackColorIndex) {
        _selectBackColorIndex = selectBackColorIndex;
        _needUpdate = YES;
    }
}

- (instancetype)init
{
    if (self = [super init]) {
        _needUpdate = YES;
        _needUpdateFrame = YES;
        _transitionAnimation = JPPackagePatternTransitionAnimationTypeDefault;
        _frame = CGRectMake(SCREEN_WIDTH / 4, SCREEN_WIDTH / 4, 100, 100);
        _textFontSize = 18;
        _isGlod = NO;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    if (CGRectEqualToRect(frame, _frame) == NO) {
        _needUpdateFrame = YES;
        _frame = frame;
    }
}

- (void)setApearFrame:(CGRect)apearFrame
{
    _apearFrame = apearFrame;
    CGRect stikersFrame = apearFrame;
    GLfloat sticersVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    if (_patternType != JPPackagePatternTypeWeekPicture) {
        sticersVertices[0] = -1.0 + stikersFrame.origin.x * 2;
        sticersVertices[1] = -1.0 + stikersFrame.origin.y * 2;
        sticersVertices[2] = 1.0 - (2 - (stikersFrame.origin.x + stikersFrame.size.width) * 2);
        sticersVertices[3] = sticersVertices[1];
        sticersVertices[4] = sticersVertices[0];
        sticersVertices[5] = 1.0 - (2 - (stikersFrame.origin.y + stikersFrame.size.height) * 2);
        sticersVertices[6] = sticersVertices[2];
        sticersVertices[7] = sticersVertices[5];
    }
    for (NSInteger index = 0; index < 8; index++) {
        vertext[index] = sticersVertices[index];
    }

}

- (GLfloat *)getReallyVertext
{
    return vertext;
}

- (UIImage *)getImageForGifAtIndex:(NSInteger)index
{
    NSString *number = [NSString stringWithFormat:@"%ld", (long)index];
    while (number.length < 5) {
        number = [NSString stringWithFormat:@"0%@", number];
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@%@", _firstPNGName, number] ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}

- (UIImage *)getlastImage
{
    if ([self thumPicture] == nil) {
        return  [self getImageForGifAtIndex:self.gifPNGCount - 1];
    }
    return [self thumPicture];
}


- (UIImage *)getThumbImageForGifAtIndex:(NSInteger)index
{
    NSString *number = [NSString stringWithFormat:@"%ld", (long)index];
    while (number.length < 5) {
        number = [NSString stringWithFormat:@"0%@", number];
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@%@", _thumFirstPNGName, number] ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}

- (CGSize)gifImageSize
{
    UIImage *image = [self getImageForGifAtIndex:0];
    CGSize size = image.size;
    CGFloat scale = SCREEN_WIDTH / 1080.0;
    return CGSizeMake(size.width * scale, size.height * scale);
}

- (NSMutableDictionary *)configueDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (_backgroundColor) {
        [dict setObject:[_backgroundColor jp_helper_hexString] forKey:@"backgroundColor"];
    }
    if (_textColor) {
        [dict setObject:[_textColor jp_helper_hexString] forKey:@"textColor"];
    }
    if (_text) {
        [dict setObject:_text forKey:@"text"];
    }
    if (_subTitle) {
        [dict setObject:_subTitle forKey:@"subTitle"];
    }
    if (_videoTime) {
        [dict setObject:_videoTime forKey:@"videoTime"];
    }
    
    [dict setObject:@(_logoImageIfFromBundle) forKey:@"logoImageIfFromBundle"];
    if (_logoImageFilePath) {
        [dict setObject:_logoImageFilePath forKey:@"logoImageFilePath"];
    }
    if (_thumPictureName) {
        [dict setObject:_thumPictureName forKey:@"thumPictureName"];
    }
    [dict setObject:@(_thumImageIfFromBundle) forKey:@"thumImageIfFromBundle"];
    if (_pictureAssetID) {
        [dict setObject:_pictureAssetID forKey:@"pictureAssetID"];
    }
    [dict setObject:@(_patternType) forKey:@"patternType"];
    [dict setObject:@(_selectColorIndex) forKey:@"selectColorIndex"];
    [dict setObject:@(_selectBackColorIndex) forKey:@"selectBackColorIndex"];
    NSString *timeRange = [NSString stringWithFormat:@"%lld,%d,%lld,%d", _timeRange.start.value, _timeRange.start.timescale, _timeRange.duration.value,_timeRange.duration.timescale];
    [dict setObject:timeRange forKey:@"timeRange"];
    NSString *apearFrame = [NSString stringWithFormat:@"%.4f,%.4f,%.4f,%.4f", _apearFrame.origin.x, _apearFrame.origin.y, _apearFrame.size.width, _apearFrame.size.height];
    [dict setObject:apearFrame forKey:@"apearFrame"];
    NSString *frame = [NSString stringWithFormat:@"%.4f,%.4f,%.4f,%.4f", _frame.origin.x, _frame.origin.y, _frame.size.width, _frame.size.height];
    [dict setObject:frame forKey:@"frame"];
    if (_patternName) {
        [dict setObject:_patternName forKey:@"patternName"];
    }
    if (_resource_id) {
        [dict setObject:_resource_id forKey:@"resource_id"];
    }
    [dict setObject:@(_thumImageUrlNameFromBundle) forKey:@"thumImageUrlNameFromBundle"];
    if (_thumImageUrlName) {
        [dict setObject:_thumImageUrlName forKey:@"thumImageUrlName"];
    }
    NSString *originImgSize = [NSString stringWithFormat:@"%.4f,%.4f", _originImgSize.width, _originImgSize.height];
    [dict setObject:originImgSize forKey:@"originImgSize"];
    [dict setObject:@(_transitionAnimation) forKey:@"transitionAnimation"];
    if (_originImageName) {
        [dict setObject:_originImageName forKey:@"originImageName"];
    }
    [dict setObject:@(_textFontSize) forKey:@"textFontSize"];
    [dict setObject:@(_videoFrame) forKey:@"videoFrame"];
    if (_textFontName) {
        [dict setObject:_textFontName forKey:@"textFontName"];
    }
    [dict setObject:@(_isGlod) forKey:@"isGlod"];
    if (_firstPNGName) {
        [dict setObject:_firstPNGName forKey:@"firstPNGName"];
    }
    [dict setObject:@(_gifPNGCount) forKey:@"gifPNGCount"];
    NSString *gifImageSize = [NSString stringWithFormat:@"%.4f,%.4f", _gifImageSize.width, _gifImageSize.height];
    [dict setObject:gifImageSize forKey:@"gifImageSize"];
    [dict setObject:@(_secondOfFrame) forKey:@"secondOfFrame"];
    if (_thumFirstPNGName) {
        [dict setObject:_thumFirstPNGName forKey:@"thumFirstPNGName"];
    }
    return dict;
}

- (void)updateInfoWithDict:(NSDictionary *)dict
{
    NSString *backgroundColor = [dict objectForKey:@"backgroundColor"];
    if (backgroundColor) {
        _backgroundColor = [UIColor jp_helper_colorWithHexString:backgroundColor];
    }
    NSString *textColor = [dict objectForKey:@"textColor"];
    if (textColor) {
        _textColor = [UIColor jp_helper_colorWithHexString:textColor];
    }
    _text = [dict objectForKey:@"text"];
    _subTitle = [dict objectForKey:@"subTitle"];
    _videoTime = [dict objectForKey:@"videoTime"];
    _logoImageIfFromBundle = [[dict objectForKey:@"logoImageIfFromBundle"] boolValue];
    _logoImageFilePath = [dict objectForKey:@"logoImageFilePath"];
    _thumPictureName = [dict objectForKey:@"thumPictureName"];
    _thumImageIfFromBundle = [[dict objectForKey:@"thumImageIfFromBundle"] boolValue];
    _pictureAssetID = [dict objectForKey:@"pictureAssetID"];
    _patternType = [[dict objectForKey:@"patternType"] integerValue];
    _selectColorIndex = [[dict objectForKey:@"selectColorIndex"] integerValue];
    _selectBackColorIndex = [[dict objectForKey:@"selectBackColorIndex"] integerValue];
    NSString *timeRange = [dict objectForKey:@"timeRange"];
    NSArray *timeRanges = [timeRange componentsSeparatedByString:@","];
    if (timeRanges && timeRanges.count == 4) {
        _timeRange = CMTimeRangeMake(CMTimeMake([timeRanges[0] longLongValue], [timeRanges[1] intValue]), CMTimeMake([timeRanges[2] longLongValue], [timeRanges[3] intValue]));
    }
    NSString *apearFrame = [dict objectForKey:@"apearFrame"];
    NSArray *apearFrames = [apearFrame componentsSeparatedByString:@","];
    if (apearFrames && apearFrames.count == 4) {
        _apearFrame = CGRectMake([apearFrames[0] floatValue], [apearFrames[1] floatValue], [apearFrames[2] floatValue], [apearFrames[3] floatValue]);
    }
    NSString *frame = [dict objectForKey:@"frame"];
    NSArray *frames = [frame componentsSeparatedByString:@","];
    if (frames && frames.count == 4) {
        _frame = CGRectMake([frames[0] floatValue], [frames[1] floatValue], [frames[2] floatValue], [frames[3] floatValue]);
    }
    _patternName = [dict objectForKey:@"patternName"];
    _resource_id = [dict objectForKey:@"resource_id"];
    _thumImageUrlNameFromBundle = [[dict objectForKey:@"thumImageUrlNameFromBundle"] boolValue];
    _thumImageUrlName = [dict objectForKey:@"thumImageUrlName"];
    NSString *originImgSize = [dict objectForKey:@"originImgSize"];
    NSArray *originImgSizes = [originImgSize componentsSeparatedByString:@","];
    if (originImgSizes && originImgSizes.count == 2) {
        _originImgSize = CGSizeMake([originImgSizes[0] floatValue], [originImgSizes[1] floatValue]);
    }
    _transitionAnimation = [[dict objectForKey:@"transitionAnimation"] integerValue];
    _originImageName = [dict objectForKey:@"originImageName"];
    _textFontSize = [[dict objectForKey:@"textFontSize"] integerValue];
    _videoFrame = [[dict objectForKey:@"videoFrame"] integerValue];
    _textFontName = [dict objectForKey:@"textFontName"];
    _isGlod = [[dict objectForKey:@"isGlod"] boolValue];
    _firstPNGName = [dict objectForKey:@"firstPNGName"];
    _gifPNGCount = [[dict objectForKey:@"gifPNGCount"] integerValue];
    NSString *gifImageSize = [dict objectForKey:@"gifImageSize"];
    NSArray *gifImageSizes = [gifImageSize componentsSeparatedByString:@","];
    if (gifImageSizes && gifImageSizes.count == 2) {
        _gifImageSize = CGSizeMake([gifImageSizes[0] floatValue], [gifImageSizes[1] floatValue]);
    }
    _secondOfFrame = [[dict objectForKey:@"secondOfFrame"] integerValue];
    _thumFirstPNGName = [dict objectForKey:@"thumFirstPNGName"];
    _needUpdate = YES;
    _needUpdateFrame = YES;
}
@end
