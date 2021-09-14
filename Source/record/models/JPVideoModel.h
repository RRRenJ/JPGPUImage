//
//  JPVideoModel.h
//  jper
//
//  Created by FoundaoTEST on 2017/3/24.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPPhotoModel.h"
#import "GPUImageContext.h"
//typedef NS_ENUM(NSInteger, JPVideoTranstionType)
//{
//    JPVideoTranstionNone = 0,
//    JPVideoTranstionGradient = 1,
//    JPVideoTranstionIncluded = 2,
//    JPVideoTranstionSuperposition = 3
//};

typedef void(^JPVideoModelGetThumbImageCompletion)(void);

typedef NS_ENUM(NSInteger, JPVideoSourceType)
{
    JPVideoSourceLocal,
    JPVideoSourceCamera,
    JPVideoSourceMediaCloud,
};


typedef NS_ENUM(NSInteger, JPVideoTimePlayType)
{
    JPVideoTimePlayTypeNone,
    JPVideoTimePlayTypeSlow,
    JPVideoTimePlayTypeFast,
};



@interface JPVideoTranstionsModel : NSObject
@property (nonatomic) NSInteger transtionIndex;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *offImageName;
@property (nonatomic, strong) NSString *onImageName;
@property (nonatomic, strong) NSString *selectImageName;
@property (nonatomic, strong) NSString *transtionGlslFileName;
- (NSMutableDictionary *)configueDict;
- (void)updateInfoWithDict:(NSDictionary *)dict;
@end

@interface JPVideoModel : NSObject<NSCopying>
@property (nonatomic, assign) CMTime videoTime;
@property (nonatomic, assign) CGSize videoSize;
@property (nonatomic) JPVideoSourceType sourceType;
@property (nonatomic, assign) CGFloat startTime;//云媒资统计用
@property (nonatomic, assign) CGFloat endTime;//云媒资统计用
@property (nonatomic, strong) NSString *cloudId;//云媒资统计用
@property (nonatomic, strong) NSString  *videoBaseFile;
@property (nonatomic, strong) NSString  *reverseVideoBaseFile;
@property (nonatomic, strong) NSString * movieName;
@property (nonatomic, assign) CMTimeRange timeRange;
@property (nonatomic, strong) UIImage *filterThumbImage;
@property (nonatomic, strong) UIImage *originThumbImage;
@property (nonatomic) GPUImageRotationMode rotationMode;
@property (nonatomic) NSInteger aspectRatio;
@property (nonatomic) NSInteger transtionType;
@property (nonatomic, strong) JPVideoTranstionsModel *transtionModel;
@property (nonatomic, strong) UIImage *originImage;
@property (nonatomic) JPPhotoModelTranstionType photoTransionType;
@property (nonatomic, assign) BOOL isImage;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) CMTime videoStartTime;
@property (nonatomic) JPVideoTimePlayType timePlayType;
@property (nonatomic, assign) BOOL isReverse;
@property (nonatomic, assign, readonly) CGFloat radios;

- (NSURL *)videoUrl;
- (NSURL *)reverseUrl;

- (void)asyncGetThumbImageWithCompletion:(void(^)(UIImage *, JPVideoModel *))completion;
@property (nonatomic, strong) NSMutableArray *thumbImages;
- (void)asyncGetAllThumbImages;
@property (nonatomic, copy) JPVideoModelGetThumbImageCompletion thumImageGetCompletion;
- (NSMutableDictionary *)configueDict;
- (void)updateInfoWithDict:(NSDictionary *)dict;


@end
