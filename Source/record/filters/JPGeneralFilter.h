//
//  JPGeneralFilter.h
//  GPUImage
//
//  Created by FoundaoTEST on 2017/6/16.
//  Copyright © 2017年 Brad Larson. All rights reserved.
//

#import "GPUImageFilter.h"
#import "JPFiltersAttributeModel.h"
#import "JPPhotoModel.h"

@protocol JPGeneralFilterDelegate <NSObject>

- (void)useProgramAsCurrent;
- (void)bindFilterbufferToRender:(GPUImageFramebuffer *)framebuffer;
- (void)setVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates;
@end

@interface JPGeneralFilter : GPUImageFilter
@property (nonatomic, strong) id<JPGeneralFilterDelegate>filterDelegate;
@end
