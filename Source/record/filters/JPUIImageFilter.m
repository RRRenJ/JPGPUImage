//
//  JPUIImageFilter.m
//  jper
//
//  Created by FoundaoTEST on 2017/3/27.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#import "JPUIImageFilter.h"

@interface JPUIImageFilter ()
{
    GLint  filterInputTextureUniform2, filterInputTextureUniform3, filterInputTextureUniform4, filterInputTextureUniform5, filterInputTextureUniform6;
    
}

@end

@implementation JPUIImageFilter

- (id)initWithFragmentShaderFromString:(NSString *)fragmentShaderString
{
    if (self = [super initWithVertexShaderFromString:kGPUImageVertexShaderString fragmentShaderFromString:fragmentShaderString]) {
        runSynchronouslyOnVideoProcessingQueue(^{
            [GPUImageContext useImageProcessingContext];
            filterInputTextureUniform2 = [filterProgram uniformIndex:@"inputImageTexture2"]; // This does assume a name of "inputImageTexture2" for second input texture in the fragment shader

            filterInputTextureUniform3 = [filterProgram uniformIndex:@"inputImageTexture3"]; // This does assume a name of "inputImageTexture3" for second input texture in the fragment shader
            filterInputTextureUniform4 = [filterProgram uniformIndex:@"inputImageTexture4"]; // This does assume a name of "inputImageTexture4" for second input texture in the fragment shader
            filterInputTextureUniform5 = [filterProgram uniformIndex:@"inputImageTexture5"]; // This does assume a name of "inputImageTexture5" for second input texture in the fragment shader
            filterInputTextureUniform6 = [filterProgram uniformIndex:@"inputImageTexture6"];
        });

    }
    return self;
}


- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates
{
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        [secondInputFramebuffer unlock];
        [thirdInputFramebuffer unlock];
        [forthInputFramebuffer unlock];
        [fifthInputFramebuffer unlock];
        [sixthInputFramebuffer unlock];
        return;
    }
    
    [GPUImageContext setActiveShaderProgram:filterProgram];
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    if (usingNextFrameForImageCapture)
    {
        [outputFramebuffer lock];
    }
    
    [self setUniformsForProgramAtIndex:0];
    
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform, 2);
    if (secondInputFramebuffer != nil) {
        glActiveTexture(GL_TEXTURE3);
        glBindTexture(GL_TEXTURE_2D, [secondInputFramebuffer texture]);
        glUniform1i(filterInputTextureUniform2, 3);
    }
    
    if (thirdInputFramebuffer != nil) {
        glActiveTexture(GL_TEXTURE4);
        glBindTexture(GL_TEXTURE_2D, [thirdInputFramebuffer texture]);
        glUniform1i(filterInputTextureUniform3, 4);
    }
    
    if (forthInputFramebuffer != nil) {
        glActiveTexture(GL_TEXTURE5);
        glBindTexture(GL_TEXTURE_2D, [forthInputFramebuffer texture]);
        glUniform1i(filterInputTextureUniform4, 5);
    }
    
    if (fifthInputFramebuffer != nil) {
        glActiveTexture(GL_TEXTURE6);
        glBindTexture(GL_TEXTURE_2D, [fifthInputFramebuffer texture]);
        glUniform1i(filterInputTextureUniform5, 6);
    }
    
    if (sixthInputFramebuffer != nil) {
        glActiveTexture(GL_TEXTURE7);
        glBindTexture(GL_TEXTURE_2D, [sixthInputFramebuffer texture]);
        glUniform1i(filterInputTextureUniform6, 7);
    }
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [firstInputFramebuffer unlock];
    [secondInputFramebuffer unlock];
    [thirdInputFramebuffer unlock];
    [forthInputFramebuffer unlock];
    [fifthInputFramebuffer unlock];
    [sixthInputFramebuffer unlock];
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex
{
    if (textureIndex == 0)
    {
        firstInputFramebuffer = newInputFramebuffer;
        [firstInputFramebuffer lock];
    }
    else if (secondInputFramebuffer == nil)
    {
        secondInputFramebuffer = newInputFramebuffer;
        [secondInputFramebuffer lock];
    }
    else if (thirdInputFramebuffer == nil) {
        thirdInputFramebuffer = newInputFramebuffer;
        [thirdInputFramebuffer lock];
    }
    else if (forthInputFramebuffer == nil) {
        forthInputFramebuffer = newInputFramebuffer;
        [forthInputFramebuffer lock];
    }
    else if (fifthInputFramebuffer == nil) {
        fifthInputFramebuffer = newInputFramebuffer;
        [fifthInputFramebuffer lock];
    }
    else if (sixthInputFramebuffer == nil) {
        sixthInputFramebuffer = newInputFramebuffer;
        [sixthInputFramebuffer lock];
    }
}


@end
