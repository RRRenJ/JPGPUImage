//
//  JPTranstionProgramModel.h
//  GPUImage
//
//  Created by FoundaoTEST on 2017/8/4.
//  Copyright © 2017年 Brad Larson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLProgram.h"
#import "GPUImageContext.h"
#import "JPTranstionsDefault.h"
#import "GPUImageFramebuffer.h"
@interface JPTranstionProgramModel : NSObject
@property (nonatomic, assign) NSInteger transtionType;
- (instancetype)initWithTranstionModel:(JPNewTranstionMode *)transtionModel;

- (CVOpenGLESTextureRef)lumaTextureForPixelBuffer:(CVPixelBufferRef)pixelBuffer;
- (CVOpenGLESTextureRef)chromaTextureForPixelBuffer:(CVPixelBufferRef)pixelBuffer;
- (void)renderPixelBuffer:(CVPixelBufferRef)destinationPixelBuffer usingForegroundSourceBuffer:(CVPixelBufferRef)foregroundPixelBuffer andBackgroundSourceBuffer:(CVPixelBufferRef)backgroundPixelBuffer forTweenFactor:(float)tween andTranstionModel:(JPNewTranstionMode *)transtionModel forInputRotation:(GPUImageRotationMode)forRotat backInputRotation:(GPUImageRotationMode)backRat;

@end
