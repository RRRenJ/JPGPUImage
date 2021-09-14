//
//  JPPhotoModel.h
//  jper
//
//  Created by FoundaoTEST on 2017/5/25.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, JPPhotoModelTranstionType){
    JPPhotoModelTranstionNormal = 0,
    JPPhotoModelTranstionSmallToBig = 2,
    JPPhotoModelTranstionBigToSmall = 1,

};

@interface JPPhotoModel : NSObject
@property (nonatomic, assign) CMTimeRange timeRange;
@property (nonatomic, assign) CMTimeRange startTranstionTimeRange;
@property (nonatomic, assign) CMTimeRange endTranstionTimeRange;
@property (nonatomic) JPPhotoModelTranstionType transtionType;
@property (nonatomic, assign) BOOL isStratTranstion;
@property (nonatomic, assign) BOOL isEndTranstion;

@end
