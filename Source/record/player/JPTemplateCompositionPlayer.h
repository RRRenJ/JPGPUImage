//
//  JPTemplateCompositionPlayer.h
//  GPUImage
//
//  Created by FoundaoTEST on 2017/9/13.
//  Copyright © 2017年 Brad Larson. All rights reserved.
//

#import "GPUImageOutput.h"
#import "JPBaseCompositionPlayer.h"
#import "JPTemplateCompositionInfo.h"
@interface JPTemplateCompositionPlayer : JPBaseCompositionPlayer

@property (nonatomic, strong) JPTemplateCompositionInfo *videoRecordInfo;
- (instancetype)initWithRecordInfo:(JPTemplateCompositionInfo *)videoInfo withComposition:(BOOL)isComposition;
- (void)scrollToWatchThumImageWithTime:(CMTime)time;


@end
