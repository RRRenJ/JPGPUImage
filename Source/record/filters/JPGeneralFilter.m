//
//  JPGeneralFilter.m
//  GPUImage
//
//  Created by FoundaoTEST on 2017/6/16.
//  Copyright © 2017年 Brad Larson. All rights reserved.
//

#import "JPGeneralFilter.h"

@interface JPGeneralFilter ()

@property (nonatomic, assign) CMTime crurrentTime;
@property (nonatomic, strong) JPFiltersAttributeModel * filterAttributeModel;

@end

@implementation JPGeneralFilter

- (instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}


- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates
{
    if (self.preventRendering || self.filterDelegate == nil)
    {
        [firstInputFramebuffer unlock];
        return;
    }
    [self.filterDelegate useProgramAsCurrent];
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    if (usingNextFrameForImageCapture)
    {
        [outputFramebuffer lock];
    }
    
    [self setUniformsForProgramAtIndex:0];
    
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self.filterDelegate bindFilterbufferToRender:firstInputFramebuffer];
    [self.filterDelegate setVertices:vertices textureCoordinates:textureCoordinates];
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    [firstInputFramebuffer unlock];
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex
{
    self.crurrentTime = frameTime;
    [super newFrameReadyAtTime:frameTime atIndex:textureIndex];

}

@end
