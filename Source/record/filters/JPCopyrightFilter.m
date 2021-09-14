//
//  JPCopyrightFilter.m
//  jper
//
//  Created by FoundaoTEST on 2017/5/11.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#import "JPCopyrightFilter.h"
#import <AVFoundation/AVFoundation.h>
NSString *const JPCopyrightVertexShaderString  = SHADER_STRING
(
 precision highp float;
 
 attribute highp vec4 position;
 attribute highp vec4 inputTextureCoordinate;
 varying highp vec2 textureCoordinate;
 varying highp vec2 varyOtherPostion;
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
     varyOtherPostion = position.xy;
 }
 );

NSString *const kIFCopyrightShaderString = SHADER_STRING
(
 precision highp float;
 varying highp vec2 textureCoordinate;
 varying highp vec2 varyOtherPostion;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture5; //水印;
 uniform  highp vec2 videoSize;
 uniform  highp vec2 inputImageTexture5Size;
 uniform int isWaterMark;
 void main()
 {
     highp  vec4 sum = texture2D(inputImageTexture, textureCoordinate);
     if (isWaterMark == 1)
     {
         highp vec4 waterMarkFrame = vec4((videoSize.x - inputImageTexture5Size.x - 30.0) / videoSize.x, (videoSize.y - inputImageTexture5Size.y - 30.0) / videoSize.y, inputImageTexture5Size.x / videoSize.x,  inputImageTexture5Size.y / videoSize.y);
         if (textureCoordinate.x >= waterMarkFrame.x && textureCoordinate.x <= waterMarkFrame.x + waterMarkFrame.z && textureCoordinate.y >= waterMarkFrame.y && textureCoordinate.y <= waterMarkFrame.y + waterMarkFrame.w)
         {
             highp vec2 inputText5Coord = vec2((textureCoordinate.x - waterMarkFrame.x) / waterMarkFrame.z, (textureCoordinate.y - waterMarkFrame.y) /waterMarkFrame.w);
             highp vec4 otherColor = texture2D(inputImageTexture5, inputText5Coord);
             sum =  sum * (1.0 - otherColor.a) + otherColor;
         }
     }
     gl_FragColor = sum;
 }
 
 
 );


@interface JPCopyrightFilter ()
{
    GPUImageFramebuffer *secondInputFramebuffer, *thirdInputFramebuffer, *forthInputFramebuffer,*fifthInputFramebuffer;
    GLint  filterInputTextureUniform5;
    GLint  videoSizeUniform,
    filterInputTextureUniform5Size;
    GLint isWaterMarkUniform;
}

@property (nonatomic, strong) NSMutableArray *timesArr;
@end


@implementation JPCopyrightFilter



- (instancetype)init
{
    if (self = [super initWithVertexShaderFromString:JPCopyrightVertexShaderString fragmentShaderFromString:kIFCopyrightShaderString]) {
        _timesArr = [NSMutableArray array];
        runSynchronouslyOnVideoProcessingQueue(^{
            [GPUImageContext useImageProcessingContext];
            filterInputTextureUniform5 = [filterProgram uniformIndex:@"inputImageTexture5"];             videoSizeUniform = [filterProgram uniformIndex:@"videoSize"];
            filterInputTextureUniform5Size = [filterProgram uniformIndex:@"inputImageTexture5Size"];
            isWaterMarkUniform = [filterProgram uniformIndex:@"isWaterMark"];
            
        });
        
    }
    return self;
}


- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates
{
    
    NSValue *timeValue = [_timesArr firstObject];
    if (timeValue) {
        [_timesArr removeObject:timeValue];
    }
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        [secondInputFramebuffer unlock];
        [thirdInputFramebuffer unlock];
        [forthInputFramebuffer unlock];
        [fifthInputFramebuffer unlock];
        
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
    //    if (secondInputFramebuffer != nil) {
    //        glActiveTexture(GL_TEXTURE3);
    //        glBindTexture(GL_TEXTURE_2D, [secondInputFramebuffer texture]);
    //        glUniform1i(filterInputTextureUniform2, 3);
    //    }
    //
    //    if (thirdInputFramebuffer != nil) {
    //        glActiveTexture(GL_TEXTURE4);
    //        glBindTexture(GL_TEXTURE_2D, [thirdInputFramebuffer texture]);
    //        glUniform1i(filterInputTextureUniform3, 4);
    //    }
    //
    //    if (forthInputFramebuffer != nil) {
    //        glActiveTexture(GL_TEXTURE5);
    //        glBindTexture(GL_TEXTURE_2D, [forthInputFramebuffer texture]);
    //        glUniform1i(filterInputTextureUniform4, 5);
    //    }
    //
    if (fifthInputFramebuffer != nil) {
        glActiveTexture(GL_TEXTURE3);
        glBindTexture(GL_TEXTURE_2D, [fifthInputFramebuffer texture]);
        glUniform1i(filterInputTextureUniform5, 3);
    }
    
    CMTime currentTime = [timeValue CMTimeValue];
    //    CMTime duration = CMTimeSubtract(_totalDuration, currentTime);
    //    Float64 time = CMTimeGetSeconds(duration);
    //    Float64 progress = 0;
    int isWaterMask = 0;
    
    //    if (time <= 2.0) {
    //        isCopyright = 1;
    //        progress = 1.0 - time / 2.0;
    //    }
    //    if (progress > 0) {
    //
    //    }
    
    Float64 currentTimeDurarion = CMTimeGetSeconds(currentTime);
    if (((NSInteger)floor(currentTimeDurarion)) % 20 < 10 && CMTimeCompare(_totalDuration, currentTime) > 0) {
        isWaterMask = 1;
    }
    glUniform1i(isWaterMarkUniform,isWaterMask);
    //    glUniform1f(progressUniform, progress);
    CGSize size =_videoSize;
    
    glUniform2f(videoSizeUniform, size.width, size.height);
    glUniform2f(filterInputTextureUniform5Size, 104, 42);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [firstInputFramebuffer unlock];
    [secondInputFramebuffer unlock];
    [thirdInputFramebuffer unlock];
    [forthInputFramebuffer unlock];
    [fifthInputFramebuffer unlock];
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex
{
    [_timesArr addObject:[NSValue valueWithCMTime:frameTime]];
    [super newFrameReadyAtTime:frameTime atIndex:textureIndex];
}

- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex
{
    if (textureIndex == 0)
    {
        firstInputFramebuffer = newInputFramebuffer;
        [firstInputFramebuffer lock];
    }
    else if (fifthInputFramebuffer == nil)
    {
        fifthInputFramebuffer = newInputFramebuffer;
        [fifthInputFramebuffer lock];
        
    }
    //    else if (thirdInputFramebuffer == nil) {
    //        thirdInputFramebuffer = newInputFramebuffer;
    //        [thirdInputFramebuffer lock];
    //    }
    //    else if (forthInputFramebuffer == nil) {
    //        forthInputFramebuffer = newInputFramebuffer;
    //        [forthInputFramebuffer lock];
    //    }else if (fifthInputFramebuffer == nil)
    //    {
    //        fifthInputFramebuffer = newInputFramebuffer;
    //        [fifthInputFramebuffer lock];
    //
    //    }
    
}

@end
