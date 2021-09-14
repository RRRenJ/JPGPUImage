//
//  JPTemplateFilter.h
//  GPUImage
//
//  Created by FoundaoTEST on 2017/9/13.
//  Copyright © 2017年 Brad Larson. All rights reserved.
//

#import "GPUImageFilter.h"
#import "JPTemplateCompositionInfo.h"

@interface JPTemplateFilter : GPUImageFilter

@property (nonatomic, strong) JPTemplateCompositionInfo *compostionInfo;
@end
