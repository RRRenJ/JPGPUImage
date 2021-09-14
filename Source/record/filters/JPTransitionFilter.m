//
//  JPTransitionFilter.m
//  jper
//
//  Created by FoundaoTEST on 2017/4/6.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#import "JPTransitionFilter.h"

// Set up texture sampling offset storage

NSString *const JPTransitionNormalFragmentShaderString = SHADER_STRING
(
 precision highp float;
 varying highp vec2 textureCoordinate;
 varying highp vec2 varyOtherPostion;
 uniform sampler2D inputImageTexture;
 uniform int imageType;
 uniform float imageProgress;
 void main()
 {
     if (imageType == 0)
     {
         gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
     }else{
         float reallyProgress = 0.7 + imageProgress * 0.3;
         if (imageType == 2)
         {
             reallyProgress = 0.7 + (1.0 - imageProgress) * 0.3;
         }
         float originX = (1.0 - reallyProgress) / 2.0;
         gl_FragColor = texture2D(inputImageTexture, vec2(originX +textureCoordinate.x * reallyProgress, originX + textureCoordinate.y * reallyProgress));

     }
 }
 );


@interface JPTransitionFilter ()
{
    
    GLint filterNormalImageTypeUniform ,filterImageProgressUniform;

}
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, assign) CMTime crurrentTime;

@end

@implementation JPTransitionFilter



- (instancetype)init
{
    if (self = [super init]) {
        _dataArr = [NSMutableArray array];
        runSynchronouslyOnVideoProcessingQueue(^{
            [self configueNormalProgram];
        });
 
    }
    return self;
}

- (void)configueNormalProgram
{
    [GPUImageContext useImageProcessingContext];
    filterProgram = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:JPTransitionNormalFragmentShaderString];
    
    if (!filterProgram.initialized)
    {
        [filterProgram addAttribute:@"position"];
        [filterProgram addAttribute:@"inputTextureCoordinate"];
        
        if (![filterProgram link])
        {
            NSString *progLog = [filterProgram programLog];
            NSLog(@"Program link log: %@", progLog);
            NSString *fragLog = [filterProgram fragmentShaderLog];
            NSLog(@"Fragment shader compile log: %@", fragLog);
            NSString *vertLog = [filterProgram vertexShaderLog];
            NSLog(@"Vertex shader compile log: %@", vertLog);
            filterProgram = nil;
            NSAssert(NO, @"Filter shader link failed");
        }
    }
    
    filterPositionAttribute = [filterProgram attributeIndex:@"position"];
    filterTextureCoordinateAttribute = [filterProgram attributeIndex:@"inputTextureCoordinate"];
    filterInputTextureUniform = [filterProgram uniformIndex:@"inputImageTexture"]; // This does assume a name of "inputImageTexture" for the fragment shader
    filterNormalImageTypeUniform = [filterProgram uniformIndex:@"imageType"]; // This does assume a name of "inputImageTexture" for the fragment shader
    filterImageProgressUniform = [filterProgram uniformIndex:@"imageProgress"];
    
    glEnableVertexAttribArray(filterPositionAttribute);
    glEnableVertexAttribArray(filterTextureCoordinateAttribute);

}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates
{
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
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
    JPPhotoModel *photoModel = nil;
    for (JPPhotoModel *model in _imageArr) {
        if (CMTimeRangeContainsTime(model.timeRange, self.crurrentTime)) {
            photoModel = model;
            break;
        }
    }
    if (photoModel) {
        CMTime duration = CMTimeSubtract(_crurrentTime, photoModel.timeRange.start);
        
        double progress = CMTimeGetSeconds(duration) / CMTimeGetSeconds(photoModel.timeRange.duration);
        glUniform1f(filterImageProgressUniform, progress);
        glUniform1i(filterNormalImageTypeUniform, photoModel.transtionType);

    }else{
        glUniform1f(filterImageProgressUniform, 0);
        glUniform1i(filterNormalImageTypeUniform, 0);
    }
   

    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
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

- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex
{
    firstInputFramebuffer = newInputFramebuffer;
    [firstInputFramebuffer lock];
}
@end
