//
//  JPTranstionsDefault.h
//  GPUImage
//
//  Created by FoundaoTEST on 2017/8/4.
//  Copyright © 2017年 Brad Larson. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "JPVideoModel.h"

#import "JPFilterModel.h"
#import "JPVideoModel.h"
#import "JPPhotoModel.h"
@interface JPNewTranstionMode : NSObject
@property (nonatomic, assign) NSInteger videoTranstionType;
@property (nonatomic, strong) NSString *programStr;
@property (nonatomic, assign) CMTimeRange transtionTimeRange;
@property (nonatomic, assign) NSInteger firstTrackIsImage;
@property (nonatomic, assign) NSInteger secondTrackIsImage;
@property (nonatomic, assign) CGFloat firstImageStartProgress;
@property (nonatomic, assign) CGFloat secondImageStartProgress;
@property (nonatomic, weak) JPPhotoModel * firstImageModel;
@property (nonatomic, weak) JPPhotoModel * secondImageModel;
@property (nonatomic) GPUImageRotationMode foregroundMode;
@property (nonatomic) GPUImageRotationMode backgroundMode;

@end



@interface JPTranstionsDefault : NSObject
@property (nonatomic)  NSInteger filterType;
@property (nonatomic, strong) NSArray *transtionArr;
+(instancetype)shareInstance;
+ (NSString *)programStrGetWithTranstionModel:(JPVideoTranstionsModel *)transtionsModel;

@end
