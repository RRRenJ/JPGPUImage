//
//  JPStickersFilter.m
//  jper
//
//  Created by FoundaoTEST on 2017/4/11.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#import "JPStickersFilter.h"
#import "JPTransitionFilter.h"
#import "JPPackagePatternAttribute.h"

NSString *const JPStickersFilterVertexShader = SHADER_STRING
(
 attribute highp vec4 position;
 attribute highp vec4 inputTextureCoordinate;
 
 varying highp vec2 textureCoordinate;
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
 }
);

NSString *const JPPassThroughFragmentShader = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
 }
);
    



@interface JPStickersFilter ()
{
    CMTime currentTime;
    
    GLint filterStickersPositionAttribute, filterStickersTextureCoordinateAttribute;
    GLint filterStickersInputTextureUniform;
    GLfloat copiesVertex[8];
}
@property (nonatomic, strong) NSArray *stickersArr;
@property (nonatomic, assign) BOOL isCircular;
@property (nonatomic, strong) GPUImagePicture *circularImagePicture;
@property (nonatomic, strong) GPUImagePicture *copiesImagePicture;

@end

@implementation JPStickersFilter


- (instancetype)initWithNeedCircular:(BOOL)isCircular
{
    if (self = [self init]) {
        _isCircular = isCircular;
        if (_isCircular == YES) {
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"circular" ofType:@"png"];
            GPUImagePicture * picture = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:imagePath]];
            _circularImagePicture = picture;
        }
        NSString *forthImagePath = [[NSBundle mainBundle] pathForResource:@"powered-water-mask" ofType:@"png"];
        _copiesImagePicture = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:forthImagePath]];
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        runSynchronouslyOnVideoProcessingQueue(^{
            [GPUImageContext useImageProcessingContext];
            filterProgram = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:JPStickersFilterVertexShader fragmentShaderString:JPPassThroughFragmentShader];
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
            filterStickersPositionAttribute = [filterProgram attributeIndex:@"position"];
            filterStickersTextureCoordinateAttribute = [filterProgram attributeIndex:@"inputTextureCoordinate"];
            filterStickersInputTextureUniform = [filterProgram uniformIndex:@"inputImageTexture"];
            glEnableVertexAttribArray(filterStickersPositionAttribute);
            glEnableVertexAttribArray(filterStickersTextureCoordinateAttribute);

        });
        
    }
    return self;
}


- (void)setVideoSize:(CGSize)videoSize
{
//    104, 42
//     highp vec4 waterMarkFrame = vec4((videoSize.x - inputImageTexture5Size.x - 30.0) / videoSize.x, (videoSize.y - inputImageTexture5Size.y - 30.0) / videoSize.y, inputImageTexture5Size.x / videoSize.x,  inputImageTexture5Size.y / videoSize.y);
    _videoSize = videoSize;
    CGRect stikersFrame =  CGRectMake((videoSize.width - 104 - 30) / videoSize.width, (videoSize.height - 42.0 - 30.0) / videoSize.height, 104.0 / videoSize.width, 42.0 / videoSize.height);
    GLfloat sticersVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    sticersVertices[0] = -1.0 + stikersFrame.origin.x * 2;
    sticersVertices[1] = -1.0 + stikersFrame.origin.y * 2;
    sticersVertices[2] = 1.0 - (2 - (stikersFrame.origin.x + stikersFrame.size.width) * 2);
    sticersVertices[3] = sticersVertices[1];
    sticersVertices[4] = sticersVertices[0];
    sticersVertices[5] = 1.0 - (2 - (stikersFrame.origin.y + stikersFrame.size.height) * 2);
    sticersVertices[6] = sticersVertices[2];
    sticersVertices[7] = sticersVertices[5];
    for (NSInteger index = 0; index < 8; index++) {
        copiesVertex[index] = sticersVertices[index];
    }

}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates
{
        if (self.preventRendering)
    {
        if (_stickersArr) {
            NSArray *stickerArr = _stickersArr.copy;
            for (JPPackagePatternAttribute *pattrn in stickerArr) {
                [pattrn.imagePicture.framebufferForOutput unlock];
            }
        }
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
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    glUniform1i(filterStickersInputTextureUniform, 0);
    glVertexAttribPointer(filterStickersPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glEnableVertexAttribArray(filterStickersPositionAttribute);
    glVertexAttribPointer(filterStickersTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    glEnableVertexAttribArray(filterStickersTextureCoordinateAttribute);
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ZERO);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    BOOL isvialied = YES;
    if (CMTimeCompare(_totalDuration, currentTime) < 0) {
        isvialied = NO;
    }
 
    if (_stickersArr && _needSticker == YES && isvialied) {
        NSArray *stickerArr = _stickersArr.copy;
        for (NSInteger index = 1; index <= stickerArr.count; index++) {
            JPPackagePatternAttribute *attribute = stickerArr[index - 1];
            GLuint texture = [attribute getCurrentPictureTexureAtTime:currentTime];
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, texture);
            glUniform1i(filterStickersInputTextureUniform, 0);
            glVertexAttribPointer(filterStickersPositionAttribute, 2, GL_FLOAT, 0, 0, [attribute getReallyVertext]);
            glEnableVertexAttribArray(filterStickersPositionAttribute);
            glVertexAttribPointer(filterStickersTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
            glEnableVertexAttribArray(filterStickersTextureCoordinateAttribute);
            glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

        }
    }
    if (_isCircular == YES && _circularImagePicture && isvialied) {
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, [_circularImagePicture.framebufferForOutput texture]);
        glUniform1i(filterStickersInputTextureUniform, 0);
        glVertexAttribPointer(filterStickersPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
        glEnableVertexAttribArray(filterStickersPositionAttribute);
        glVertexAttribPointer(filterStickersTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
        glEnableVertexAttribArray(filterStickersTextureCoordinateAttribute);
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    }
    BOOL isWaterMask = NO;
    Float64 currentTimeDurarion = CMTimeGetSeconds(currentTime);
    if (((NSInteger)floor(currentTimeDurarion)) % 20 < 10 && isvialied) {
        isWaterMask = YES;
    }
    if (isWaterMask) {
//        glActiveTexture(GL_TEXTURE0);
//        glBindTexture(GL_TEXTURE_2D, [_copiesImagePicture.framebufferForOutput texture]);
//        glUniform1i(filterStickersInputTextureUniform, 0);
//        glVertexAttribPointer(filterStickersPositionAttribute, 2, GL_FLOAT, 0, 0, copiesVertex);
//        glEnableVertexAttribArray(filterStickersPositionAttribute);
//        glVertexAttribPointer(filterStickersTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
//        glEnableVertexAttribArray(filterStickersTextureCoordinateAttribute);
//        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
//        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    }

    glDisable(GL_BLEND);
    [firstInputFramebuffer unlock];
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex
{
    currentTime = frameTime;
    [super newFrameReadyAtTime:frameTime atIndex:textureIndex];
}

- (void)setInputStickersArr:(NSArray *)stickersArr andCurrentTime:(CMTime)time
{
    if (stickersArr.count <= 0) {
        _stickersArr = nil;
        return;
    }
    _stickersArr = stickersArr;
}

- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex
{
    if (textureIndex == 0) {
        firstInputFramebuffer = newInputFramebuffer;
        [firstInputFramebuffer lock];
    }else{
        [newInputFramebuffer lock];
    }
}

- (void)filterStikersShouldBeNone
{
    _stickersArr = nil;
}

- (void)dealloc
{
}
@end
