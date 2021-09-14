//
//  JPVideoCompositionPlayer.h
//  jper
//
//  Created by FoundaoTEST on 2017/4/6.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#import "JPVideoRecordInfo.h"
#import "JPBaseCompositionPlayer.h"
#import "JPPackagePatternAttribute.h"
@interface JPVideoCompositionPlayer : JPBaseCompositionPlayer

@property (nonatomic, strong) JPVideoRecordInfo *videoRecordInfo;
- (instancetype)initWithRecordInfo:(JPVideoRecordInfo *)videoInfo withStickers:(BOOL)sticker withComposition:(BOOL)isComposition;
- (instancetype)initWithRecordInfo:(JPVideoRecordInfo *)videoInfo withComposition:(BOOL)isComposition;
- (void)addPackagePattern:(JPPackagePatternAttribute *)pagePattern;
- (void)removePackagePattern:(JPPackagePatternAttribute *)pagePattern;
@end
