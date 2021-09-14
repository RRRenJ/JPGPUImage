//
//  JPAudioModel.h
//  jper
//
//  Created by 藩 亜玲 on 2017/4/18.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, JPAudioSourceType){
    JPAudioSourceTypeLocal,
    JPAudioSourceTypeRecorded,
    JPAudioSourceTypeSoundEffect
};

@interface JPAudioModel : NSObject<NSCopying>
@property (nonatomic, assign) CMTime durationTime;
@property (nonatomic, assign) CMTime startTime;
@property (nonatomic, assign) CMTimeRange clipTimeRange;
//@property (nonatomic, strong) NSURL *fileUrl;
@property (nonatomic, assign) BOOL isBundle;
@property (nonatomic) JPAudioSourceType sourceType;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, copy) NSString *resource_id;//素材的mid
@property (nonatomic, strong) NSString *selectedThumImgName;
@property (nonatomic, strong) NSString *unSelectedThumImgName;
@property (nonatomic, strong) NSString *theme;
@property (nonatomic, assign) BOOL isITunes;
@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, assign) CGFloat volume;
@property (nonatomic, assign) CGFloat fileNameWidth;
@property (nonatomic, strong) NSString *baseFilePath;

- (NSURL *)fileUrl;
- (UIImage *)selectedThumImg;
- (UIImage *)unSelectedThumImg;

//+ (NSArray<JPAudioModel *> *)loadAllLocalMusic;

- (NSMutableDictionary *)configueDict;
- (void)updateInfoWithDict:(NSDictionary *)dict;

@end
