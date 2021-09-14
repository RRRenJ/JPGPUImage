//
//  JPTemplateFilter.m
//  GPUImage
//
//  Created by FoundaoTEST on 2017/9/13.
//  Copyright © 2017年 Brad Larson. All rights reserved.
//

#import "JPTemplateFilter.h"

NSString *const JPTemplateFilterVertexShader = SHADER_STRING
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

NSString *const JPTemplateFilterFragmentShader = SHADER_STRING
(
 precision highp float;
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform int isBlur;
 uniform sampler2D inputBlurTexture;
 uniform int needTranstion;
 uniform float transtionProgress;
 uniform int textIsTranstion;
 uniform sampler2D inputTextTexture;
 uniform float textTranstionProgress;
 uniform vec4 textFrame;
 uniform int textTranstionType;
 vec2 singleStepOffset = vec2(1.0 / 1280.0, 1.0 / 720.0);
 uniform vec4 videoinputBlurframe;

 vec4 getFromColor(vec2 uv)
{
    vec4 forColor = vec4(0.0);
    if (uv.x >= videoinputBlurframe.x && uv.x <= (videoinputBlurframe.x + videoinputBlurframe.z) && uv.y >= videoinputBlurframe.y && uv.y <= (videoinputBlurframe.y + videoinputBlurframe.w) ) {
        vec2 position = vec2((uv.x - videoinputBlurframe.x) / videoinputBlurframe.z, (uv.y - videoinputBlurframe.y) / videoinputBlurframe.w);
        forColor = texture2D(inputBlurTexture, position);
    }
    return forColor;
}

 
 
 vec4 smallToBigTranstion(vec4 color)
 {
     vec4 inVideoFrame = vec4(textFrame.x * singleStepOffset.x ,textFrame.y * singleStepOffset.y, textFrame.z * singleStepOffset.x, textFrame.w * singleStepOffset.y);
     vec4 reallyFrame = inVideoFrame * textTranstionProgress;
     reallyFrame.x = inVideoFrame.x + inVideoFrame.z / 2.0 - reallyFrame.z / 2.0;
     reallyFrame.y = inVideoFrame.y + inVideoFrame.w / 2.0 - reallyFrame.w / 2.0;
     if (textureCoordinate.x >= reallyFrame.x && textureCoordinate.y >= reallyFrame.y && textureCoordinate.x <= (reallyFrame.x + reallyFrame.z) && textureCoordinate.y <= (reallyFrame.y + reallyFrame.w))
     {
         vec2 position = vec2((textureCoordinate.x - reallyFrame.x) / reallyFrame.z, (textureCoordinate.y - reallyFrame.y) / reallyFrame.w);
         vec4 textColor = texture2D(inputTextTexture, position);
         float progress = textTranstionProgress + 0.1;
         if (progress > 1.0)
         {
             progress = 1.0;
         }
         textColor = textColor * progress;
         color = color * (1.0 - textColor.a) + textColor;
     }
     return color;
 }
 
 
 void main()
 {
     vec4 color = vec4(0.0);
     if (isBlur == 1)
     {
         for (int i = -3 ; i < 4; i++)
         {
             for (int j = -3; j < 4; j++)
             {
                 vec2 position = vec2(textureCoordinate.x + singleStepOffset.x * float(i), textureCoordinate.y + singleStepOffset.y * float(j));
                 color += getFromColor(position);
             }
         }
         color = color * (1.0 / 49.0);
     }else
     {
         color = texture2D(inputImageTexture, textureCoordinate);
     }
     if (textIsTranstion == 1 )
     {
         if (textTranstionType == 1)
         {
             color = smallToBigTranstion(color);
         }
     }
     if (needTranstion == 1)
     {
         color = color * (1.0 - transtionProgress);
     }
     gl_FragColor = color;
 }
 );


@interface JPTemplateFilter ()
{
//    precision highp float;
//    varying highp vec2 textureCoordinate;
//    uniform sampler2D inputImageTexture;
//    int isBlur;
//    uniform sampler2D inputBlurTexture;
//    int needTranstion;
//    float transtionProgress;
    
     GLint filterPositionAttribute, filterTextureCoordinateAttribute;
     GLint inputImageTextureUniform;
     GLint inputBlurTextureUniform;
     GLint isBlurUniform;
     GLint needTranstionUniform;
     GLint transtionProgressUniform;
    
    GLint inputTextTextureUniform;
    GLint textIsTranstionUniform;
    GLint textTranstionProgressUniform;
    GLint textTranstionTypeUniform;
    GLint textSizeTypeUniform;
    GLint videoinputBlurframeUniform;
}

@property (nonatomic, assign) CMTime currentTime;

@end


@implementation JPTemplateFilter

- (instancetype)init
{
    self = [super init];
    if (self == nil) {
        return nil;
    }
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        filterProgram = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:JPTemplateFilterVertexShader fragmentShaderString:JPTemplateFilterFragmentShader];
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
        inputBlurTextureUniform = [filterProgram uniformIndex:@"inputBlurTexture"];
        inputImageTextureUniform = [filterProgram uniformIndex:@"inputImageTexture"];
        isBlurUniform = [filterProgram uniformIndex:@"isBlur"];
        needTranstionUniform = [filterProgram uniformIndex:@"needTranstion"];
        transtionProgressUniform = [filterProgram uniformIndex:@"transtionProgress"];
        inputTextTextureUniform = [filterProgram uniformIndex:@"inputTextTexture"];
        textIsTranstionUniform = [filterProgram uniformIndex:@"textIsTranstion"];
        textTranstionProgressUniform = [filterProgram uniformIndex:@"textTranstionProgress"];
        textTranstionTypeUniform = [filterProgram uniformIndex:@"textTranstionType"];
        textSizeTypeUniform = [filterProgram uniformIndex:@"textFrame"];
        videoinputBlurframeUniform = [filterProgram uniformIndex:@"videoinputBlurframe"];
        glEnableVertexAttribArray(filterPositionAttribute);
        glEnableVertexAttribArray(filterTextureCoordinateAttribute);
        
    });
    return self;
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
    glUniform1i(inputImageTextureUniform, 2);
    
    BOOL isBlur = NO;
    GPUImagePicture *blurPictur = nil;
    BOOL needTranstion = NO;
    CGFloat transtionProgress = 0.0;
    
    
    GPUImagePicture *textPicture = nil;
    BOOL textIsTranstion = NO;
    CGRect textSize = CGRectZero;
    NSInteger textTranstionType = 0;
    CGFloat textTranstionProgress = 0.0;
    
    if (CMTimeRangeContainsTime(_compostionInfo.header.appearTimeRange, _currentTime)) {
        if ([_compostionInfo.header isEnding:_currentTime]) {
            needTranstion = YES;
            transtionProgress = [_compostionInfo.header endTranstionProgressWithTime:_currentTime];
        }
        if ([_compostionInfo.header canAddOpening:_currentTime]) {
            textIsTranstion = YES;
            textSize = _compostionInfo.header.openingFrame;
            textTranstionType = _compostionInfo.header.openingTranstionType;
            textTranstionProgress = [_compostionInfo.header openTranstionProgressWithTime:_currentTime];
            textPicture = _compostionInfo.header.startPicture;
        }
    }else if (CMTimeRangeContainsTime(_compostionInfo.footer.aprearTimeRange, _currentTime))
    {
        if ([_compostionInfo.footer isStart:_currentTime]) {
            needTranstion = YES;
            transtionProgress = [_compostionInfo.footer startTranstionProgressWithTime:_currentTime];
        }
        if ([_compostionInfo.footer canAddOpening:_currentTime]) {
            textIsTranstion = YES;
            textSize = _compostionInfo.footer.openingFrame;
            textTranstionType = _compostionInfo.footer.openingTranstionType;
            textTranstionProgress = [_compostionInfo.footer openTranstionProgressWithTime:_currentTime];
            textPicture = _compostionInfo.footer.startPicture;
        }
    }else{
        for (JPContentVideoInfo *simpleInfo in _compostionInfo.contentVideos) {
            if (CMTimeRangeContainsTime(simpleInfo.totalApearTimeRange, _currentTime)) {
                if ([simpleInfo isInTranstionWithTime:_currentTime]) {
                    needTranstion = YES;
                    transtionProgress = [simpleInfo transtionProgressWithTime:_currentTime];
                }
                if ([simpleInfo canAddOpening:_currentTime]) {
                    isBlur = YES;
                    blurPictur = simpleInfo.beginPicture;
                    if (simpleInfo.startPicture) {
                        textIsTranstion = YES;
                        textSize = simpleInfo.beginOpeningFrame;
                        textTranstionType = simpleInfo.openingTranstionType;
                        textTranstionProgress = [simpleInfo openTranstionProgressWithTime:_currentTime];
                        textPicture = simpleInfo.startPicture;
                    }
                }
                break;
            }
        }
    }
//    NSLog(@"-是否转场-%d --%.2f-时间-%.4f", needTranstion, transtionProgress, CMTimeGetSeconds(_currentTime));
    glUniform1i(isBlurUniform, isBlur ? 1 : 0);
    glUniform1i(needTranstionUniform, needTranstion ? 1 : 0);
    glUniform1i(textIsTranstionUniform, textIsTranstion ? 1 : 0);
    if (isBlur) {
        glActiveTexture(GL_TEXTURE3);
        glBindTexture(GL_TEXTURE_2D, [[blurPictur framebufferForOutput] texture]);
        glUniform1i(inputBlurTextureUniform, 3);
        CGRect corpRect = [self getLocalVideoCropSizeWithOriginSize:[blurPictur outputImageSize] desSize:CGSizeMake(1280, 720)];
        glUniform4f(videoinputBlurframeUniform, corpRect.origin.x, corpRect.origin.y, corpRect.size.width, corpRect.size.height);
        
    }
    if (textIsTranstion) {
        glUniform4f(textSizeTypeUniform, textSize.origin.x, textSize.origin.y, textSize.size.width, textSize.size.height);
        glUniform1i(textTranstionTypeUniform, (GLint)textTranstionType);
        glUniform1f(textTranstionProgressUniform, textTranstionProgress);
        glActiveTexture(GL_TEXTURE4);
        glBindTexture(GL_TEXTURE_2D, [[textPicture framebufferForOutput] texture]);
        glUniform1i(inputTextTextureUniform, 4);
    }

    glUniform1f(transtionProgressUniform, transtionProgress);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [firstInputFramebuffer unlock];
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }

}


- (CGRect)getLocalVideoCropSizeWithOriginSize:(CGSize)originSize desSize:(CGSize)desSize
{
    CGRect videoCropRect = CGRectZero;
    CGFloat ratio = desSize.width / desSize.height;
    CGFloat ratio1 = originSize.width / originSize.height;
    CGFloat width = 1.0;
    CGFloat height = 1.0;
    if (ratio1 >= ratio) {
        height = (desSize.width / ratio1) / desSize.height;
    }else{
        width = (desSize.height * ratio1) / desSize.width;
    }
    videoCropRect = CGRectMake((1.0 - width) / 2.0, (1.0 - height) / 2.0, width, height);
    return videoCropRect;
}


- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex
{
    _currentTime = frameTime;
    [super newFrameReadyAtTime:frameTime atIndex:textureIndex];
}
@end
