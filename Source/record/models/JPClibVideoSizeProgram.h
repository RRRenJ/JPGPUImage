//
//  JPClibVideoSizeProgram.h
//  GPUImage
//
//  Created by FoundaoTEST on 2017/9/4.
//  Copyright © 2017年 Brad Larson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLProgram.h"
#import "GPUImageContext.h"
#import "JPTranstionsDefault.h"
#import "GPUImageFramebuffer.h"
@interface JPClibVideoSizeProgram : NSObject

@property CGAffineTransform renderTransform;

- (CVOpenGLESTextureRef)lumaTextureForPixelBuffer:(CVPixelBufferRef)pixelBuffer;
- (CVOpenGLESTextureRef)chromaTextureForPixelBuffer:(CVPixelBufferRef)pixelBuffer;
- (void)renderPixelBuffer:(CVPixelBufferRef)destinationPixelBuffer usingSourceBuffer:(CVPixelBufferRef)pixelBuffer andRotation:(GPUImageRotationMode)rotationMode andIsImage:(BOOL)isImage imageProgress:(CGFloat)imageProgress andImageType:(NSInteger)imageType;

@end
