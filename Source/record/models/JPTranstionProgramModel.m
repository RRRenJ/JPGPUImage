//
//  JPTranstionProgramModel.m
//  GPUImage
//
//  Created by FoundaoTEST on 2017/8/4.
//  Copyright © 2017年 Brad Larson. All rights reserved.
//

#import "JPTranstionProgramModel.h"
#import "GPUImageFilter.h"
enum
{
    UNIFORM_Y,
    UNIFORM_UV,
};

enum
{
    ATTRIB_VERTEX_Y,
    ATTRIB_TEXCOORD_Y,
    ATTRIB_VERTEX_UV,
    ATTRIB_TEXCOORD_UV,
   	NUM_ATTRIBUTES
};

NSString *const JPTranstionPassThroughVertexShader = SHADER_STRING
(
   attribute vec4 position;
   attribute vec2 texCoord;
   varying vec2 textureCoordinate;
   void main()
   {
      gl_Position = position;
      textureCoordinate = texCoord;
   }
);

@interface JPTranstionProgramModel ()
{
    GLuint _programY;
    GLuint _programUV;
    EAGLContext *_currentContext;
    GLint colorSwizzlingInputTextureUniformforback[2];
    GLint colorSwizzlingInputTextureUniformback[2];
    GLint colorSwizzlingInputTextureUniformProgress[2];
    GLint colorSwizzlingFisrtBufferIsImage[2];
    GLint colorSwizzlingSecondBufferIsImage[2];
    GLint colorSwizzlingFisrtBufferStartProgress[2];
    GLint colorSwizzlingSecondBufferStartProgress[2];
    GLint colorSwizzlingIsY[2];
    GLint colorRatio[2];
    GLint forRotation[2];
    GLint backRotation[2];
    GLint colorSwizzlingForVideoFrameform[2];
    GLint colorSwizzlingBackVideoFrameform[2];
    JPNewTranstionMode *_transModel;
    CVOpenGLESTextureCacheRef _videoTextureCache;
    GLuint _offscreenBufferHandle;
}
@end

@implementation JPTranstionProgramModel




- (instancetype)initWithTranstionModel:(JPNewTranstionMode *)transtionModel
{
    if (self = [self init]) {
        _transModel = transtionModel;
        _transtionType = _transModel.videoTranstionType;
        _currentContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        [EAGLContext setCurrentContext:_currentContext];
        
        [self setupOffscreenRenderContext];
        [self loadShaders];
        
        [EAGLContext setCurrentContext:nil];

    }
    return self;
}

- (void)setupOffscreenRenderContext
{
    //-- Create CVOpenGLESTextureCacheRef for optimal CVPixelBufferRef to GLES texture conversion.
    if (_videoTextureCache) {
        CFRelease(_videoTextureCache);
        _videoTextureCache = NULL;
    }
    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _currentContext, NULL, &_videoTextureCache);
    if (err != noErr) {
        NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", err);
    }
    
    glDisable(GL_DEPTH_TEST);
    glActiveTexture(GL_TEXTURE1);
    glGenFramebuffers(1, &_offscreenBufferHandle);
    glBindFramebuffer(GL_FRAMEBUFFER, _offscreenBufferHandle);

//    glGenFramebuffers(1, &_offscreenBufferHandle);
//    glBindFramebuffer(GL_FRAMEBUFFER, _offscreenBufferHandle);
}
- (void)dealloc
{
    [EAGLContext setCurrentContext:_currentContext];
    if (_videoTextureCache) {
        CFRelease(_videoTextureCache);
    }
    if (_offscreenBufferHandle) {
        glDeleteFramebuffers(1, &_offscreenBufferHandle);
        _offscreenBufferHandle = 0;
    }
    [EAGLContext setCurrentContext:nil];
}


- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderSource, *fragShaderSource;
    
    // Create the shader program.
    _programY = glCreateProgram();
    _programUV = glCreateProgram();
    
    // Create and compile the vertex shader.
    vertShaderSource = JPTranstionPassThroughVertexShader;
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER source:vertShaderSource]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile Y fragment shader.
    fragShaderSource = _transModel.programStr;
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER source:fragShaderSource]) {
        NSLog(@"Failed to compile Y fragment shader");
        return NO;
    }
    
    // Create and compile UV fragment shader.
    // Attach vertex shader to programY.
    glAttachShader(_programY, vertShader);
    
    // Attach fragment shader to programY.
    glAttachShader(_programY, fragShader);
    
    // Attach vertex shader to programY.
    glAttachShader(_programUV, vertShader);
    
    // Attach fragment shader to programY.
    glAttachShader(_programUV, fragShader);
    
    
    // Bind attribute locations. This needs to be done prior to linking.
    
    glBindAttribLocation(_programY, ATTRIB_VERTEX_Y, "position");
    glBindAttribLocation(_programY, ATTRIB_TEXCOORD_Y, "texCoord");
    glBindAttribLocation(_programUV, ATTRIB_VERTEX_UV, "position");
    glBindAttribLocation(_programUV, ATTRIB_TEXCOORD_UV, "texCoord");
    
    // Link the program.
    if (![self linkProgram:_programY] || ![self linkProgram:_programUV]) {
        NSLog(@"Failed to link program: %d and %d", _programY, _programUV);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_programY) {
            glDeleteProgram(_programY);
            _programY = 0;
        }
        if (_programUV) {
            glDeleteProgram(_programUV);
            _programUV = 0;
        }
        return NO;
    }

    colorSwizzlingInputTextureUniformforback[UNIFORM_Y] = glGetUniformLocation(_programY, "inputImageTextureforback");
    colorSwizzlingInputTextureUniformforback[UNIFORM_UV] = glGetUniformLocation(_programUV, "inputImageTextureforback");
    
    colorSwizzlingInputTextureUniformback[UNIFORM_Y] = glGetUniformLocation(_programY, "inputImageTextureback");
    colorSwizzlingInputTextureUniformback[UNIFORM_UV] = glGetUniformLocation(_programUV, "inputImageTextureback");
    
    colorSwizzlingInputTextureUniformProgress[UNIFORM_Y] = glGetUniformLocation(_programY, "progress");
    colorSwizzlingInputTextureUniformProgress[UNIFORM_UV] = glGetUniformLocation(_programUV, "progress");
    
    colorSwizzlingFisrtBufferIsImage[UNIFORM_Y] = glGetUniformLocation(_programY, "firstIsImage");
    colorSwizzlingFisrtBufferIsImage[UNIFORM_UV] = glGetUniformLocation(_programUV, "firstIsImage");
    
    colorSwizzlingSecondBufferIsImage[UNIFORM_Y] = glGetUniformLocation(_programY, "secondIsImage");
    colorSwizzlingSecondBufferIsImage[UNIFORM_UV] = glGetUniformLocation(_programUV, "secondIsImage");
    
    colorSwizzlingFisrtBufferStartProgress[UNIFORM_Y] = glGetUniformLocation(_programY, "firstImageProgress");
    colorSwizzlingFisrtBufferStartProgress[UNIFORM_UV] = glGetUniformLocation(_programUV, "firstImageProgress");

    colorSwizzlingSecondBufferStartProgress[UNIFORM_Y] = glGetUniformLocation(_programY, "secondImageProgress");
    colorSwizzlingSecondBufferStartProgress[UNIFORM_UV] = glGetUniformLocation(_programUV, "secondImageProgress");
    
    colorSwizzlingIsY[UNIFORM_Y] = glGetUniformLocation(_programY, "isY");
    colorSwizzlingIsY[UNIFORM_UV] = glGetUniformLocation(_programUV, "isY");
    
    colorRatio[UNIFORM_Y] = glGetUniformLocation(_programY, "ratio");
    colorRatio[UNIFORM_UV] = glGetUniformLocation(_programUV, "ratio");
    forRotation[UNIFORM_Y] = glGetUniformLocation(_programY, "forRotation");
    forRotation[UNIFORM_UV] = glGetUniformLocation(_programUV, "forRotation");
    backRotation[UNIFORM_Y] = glGetUniformLocation(_programY, "backRotation");
    backRotation[UNIFORM_UV] = glGetUniformLocation(_programUV, "backRotation");
    
    //    uniform vec4 forVideoframe;
//    uniform vec4 backVideoframe;
//    uniform vec4 videoForframe;
//    uniform vec4 videoBackframe;
    colorSwizzlingForVideoFrameform[UNIFORM_Y] = glGetUniformLocation(_programY, "videoForframe");
    colorSwizzlingForVideoFrameform[UNIFORM_UV] = glGetUniformLocation(_programUV, "videoForframe");
    colorSwizzlingBackVideoFrameform[UNIFORM_Y] = glGetUniformLocation(_programY, "videoBackframe");
    colorSwizzlingBackVideoFrameform[UNIFORM_UV] = glGetUniformLocation(_programUV, "videoBackframe");
    if (vertShader) {
        glDetachShader(_programY, vertShader);
        glDetachShader(_programUV, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_programY, fragShader);
        glDeleteShader(fragShader);
    }
    if (fragShader) {
        glDetachShader(_programUV, fragShader);
        glDeleteShader(fragShader);
    }
    return YES;
}




- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type source:(NSString *)sourceString
{
    if (sourceString == nil) {
        NSLog(@"Failed to load vertex shader: Empty source string");
        return NO;
    }
    
    GLint status;
    const GLchar *source;
    source = (GLchar *)[sourceString UTF8String];
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

#if defined(DEBUG)

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

#endif

- (CVOpenGLESTextureRef)lumaTextureForPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    CVOpenGLESTextureRef lumaTexture = NULL;
    CVReturn err;
    
    if (!_videoTextureCache) {
        NSLog(@"No video texture cache");
        goto bail;
    }
    
    // Periodic texture cache flush every frame
    CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
    
    // CVOpenGLTextureCacheCreateTextureFromImage will create GL texture optimally from CVPixelBufferRef.
    // Y
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                       _videoTextureCache,
                                                       pixelBuffer,
                                                       NULL,
                                                       GL_TEXTURE_2D,
                                                       GL_RED_EXT,
                                                       (int)CVPixelBufferGetWidth(pixelBuffer),
                                                       (int)CVPixelBufferGetHeight(pixelBuffer),
                                                       GL_RED_EXT,
                                                       GL_UNSIGNED_BYTE,
                                                       0,
                                                       &lumaTexture);
    
    if (!lumaTexture || err) {
        NSLog(@"Error at creating luma texture using CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
    }
    
bail:
    return lumaTexture;
}

- (CVOpenGLESTextureRef)chromaTextureForPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    CVOpenGLESTextureRef chromaTexture = NULL;
    CVReturn err;
    
    if (!_videoTextureCache) {
        NSLog(@"No video texture cache");
        goto bail;
    }
    
    // Periodic texture cache flush every frame
    CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
    
    // CVOpenGLTextureCacheCreateTextureFromImage will create GL texture optimally from CVPixelBufferRef.
    // UV
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                       _videoTextureCache,
                                                       pixelBuffer,
                                                       NULL,
                                                       GL_TEXTURE_2D,
                                                       GL_RG_EXT,
                                                       (int)CVPixelBufferGetWidthOfPlane(pixelBuffer, 1),
                                                       (int)CVPixelBufferGetHeightOfPlane(pixelBuffer, 1),
                                                       GL_RG_EXT,
                                                       GL_UNSIGNED_BYTE,
                                                       1,
                                                       &chromaTexture);
    
    if (!chromaTexture || err) {
        NSLog(@"Error at creating chroma texture using CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
    }
    
bail:
    return chromaTexture;
}


- (void)renderPixelBuffer:(CVPixelBufferRef)destinationPixelBuffer usingForegroundSourceBuffer:(CVPixelBufferRef)foregroundPixelBuffer andBackgroundSourceBuffer:(CVPixelBufferRef)backgroundPixelBuffer forTweenFactor:(float)tween andTranstionModel:(JPNewTranstionMode *)transtionModel forInputRotation:(GPUImageRotationMode)forRotat backInputRotation:(GPUImageRotationMode)backRat
{
    [EAGLContext setCurrentContext:_currentContext];
    if (foregroundPixelBuffer != NULL && backgroundPixelBuffer != NULL) {
        CVOpenGLESTextureRef foregroundLumaTexture  = [self lumaTextureForPixelBuffer:foregroundPixelBuffer];
        CVOpenGLESTextureRef foregroundChromaTexture = [self chromaTextureForPixelBuffer:foregroundPixelBuffer];
        
        CVOpenGLESTextureRef backgroundLumaTexture = [self lumaTextureForPixelBuffer:backgroundPixelBuffer];
        CVOpenGLESTextureRef backgroundChromaTexture = [self chromaTextureForPixelBuffer:backgroundPixelBuffer];
        
        CVOpenGLESTextureRef destLumaTexture = [self lumaTextureForPixelBuffer:destinationPixelBuffer];
        CVOpenGLESTextureRef destChromaTexture = [self chromaTextureForPixelBuffer:destinationPixelBuffer];
        CGFloat videoWidth =  CVPixelBufferGetWidthOfPlane(destinationPixelBuffer, 0);
        CGFloat videoHeight = CVPixelBufferGetHeightOfPlane(destinationPixelBuffer, 0);
        
        CGFloat forvideoWidth =  CVPixelBufferGetWidthOfPlane(foregroundPixelBuffer, 0);
        CGFloat forvideoHeight = CVPixelBufferGetHeightOfPlane(foregroundPixelBuffer, 0);
        if (forRotat == kGPUImageRotateRight || forRotat == kGPUImageRotateLeft) {
            CGFloat contant = forvideoWidth;
            forvideoWidth = forvideoHeight;
            forvideoHeight = contant;
        }

        
        CGFloat backvideoWidth =  CVPixelBufferGetWidthOfPlane(backgroundPixelBuffer, 0);
        CGFloat backvideoHeight = CVPixelBufferGetHeightOfPlane(backgroundPixelBuffer, 0);
        if (backRat == kGPUImageRotateRight || backRat == kGPUImageRotateLeft) {
            CGFloat contant = backvideoWidth;
            backvideoWidth = backvideoHeight;
            backvideoHeight = contant;
        }
        
        
        CGRect forFrame = [self getLocalVideoCropSizeWithOriginSize:CGSizeMake(forvideoWidth, forvideoHeight) desSize:CGSizeMake(videoWidth, videoHeight)];
        
        CGRect backFrame = [self getLocalVideoCropSizeWithOriginSize:CGSizeMake(backvideoWidth, backvideoHeight) desSize:CGSizeMake(videoWidth, videoHeight)];
        
        
        NSInteger forangleRa = 0;
        switch (forRotat) {
            case kGPUImageRotateRight:
                forangleRa = 2;
                break;
            case kGPUImageRotateLeft:
                forangleRa = 1;
                break;
            case kGPUImageRotate180:
                forangleRa = 3;
                break;
            default:
                break;
        }

        NSInteger backangleRa = 0;
        switch (backRat) {
            case kGPUImageRotateRight:
                backangleRa = 2;
                break;
            case kGPUImageRotateLeft:
                backangleRa = 1;
                break;
            case kGPUImageRotate180:
                backangleRa = 3;
                break;
            default:
                break;
        }

        
        glUseProgram(_programY);
        glBindFramebuffer(GL_FRAMEBUFFER, _offscreenBufferHandle);
        glViewport(0, 0, (int)videoWidth, (int)videoHeight);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(CVOpenGLESTextureGetTarget(foregroundLumaTexture), CVOpenGLESTextureGetName(foregroundLumaTexture));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(CVOpenGLESTextureGetTarget(backgroundLumaTexture), CVOpenGLESTextureGetName(backgroundLumaTexture));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, CVOpenGLESTextureGetTarget(destLumaTexture), CVOpenGLESTextureGetName(destLumaTexture), 0);
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
            goto bail;
        }
        
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        GLfloat quadVertexData1 [] = {
            -1.0, 1.0,
            1.0, 1.0,
            -1.0, -1.0,
            1.0, -1.0,
        };
        GLfloat quadTextureData1 [] = {
            0.5 + quadVertexData1[0]/2, 0.5 + quadVertexData1[1]/2,
            0.5 + quadVertexData1[2]/2, 0.5 + quadVertexData1[3]/2,
            0.5 + quadVertexData1[4]/2, 0.5 + quadVertexData1[5]/2,
            0.5 + quadVertexData1[6]/2, 0.5 + quadVertexData1[7]/2,
        };
        
        glUniform1i(colorSwizzlingInputTextureUniformforback[UNIFORM_Y], 0);
        glUniform1i(colorSwizzlingInputTextureUniformback[UNIFORM_Y], 1);
        
        glUniform1i(forRotation[UNIFORM_Y], (GLint)forangleRa);
        glUniform1i(backRotation[UNIFORM_Y], (GLint)backangleRa);

        glUniform1f(colorSwizzlingInputTextureUniformProgress[UNIFORM_Y], tween);
        glUniform1i(colorSwizzlingFisrtBufferIsImage[UNIFORM_Y], (GLint)transtionModel.firstTrackIsImage);
        glUniform1i(colorSwizzlingSecondBufferIsImage[UNIFORM_Y], (GLint)transtionModel.secondTrackIsImage);
        glUniform1i(colorSwizzlingIsY[UNIFORM_Y], 1);
        glUniform1f(colorSwizzlingFisrtBufferStartProgress[UNIFORM_Y], transtionModel.firstImageStartProgress);
        glUniform1f(colorSwizzlingSecondBufferStartProgress[UNIFORM_Y], transtionModel.secondImageStartProgress);
        glUniform4f(colorSwizzlingBackVideoFrameform[UNIFORM_Y], backFrame.origin.x, backFrame.origin.y, backFrame.size.width, backFrame.size.height);
        glUniform4f(colorSwizzlingForVideoFrameform[UNIFORM_Y], forFrame.origin.x, forFrame.origin.y, forFrame.size.width, forFrame.size.height);

        glUniform1f(colorRatio[UNIFORM_Y], videoWidth / videoHeight);
        glVertexAttribPointer(ATTRIB_VERTEX_Y, 2, GL_FLOAT, 0, 0, quadVertexData1);
        glEnableVertexAttribArray(ATTRIB_VERTEX_Y);
        
        glVertexAttribPointer(ATTRIB_TEXCOORD_Y, 2, GL_FLOAT, 0, 0, quadTextureData1);
        glEnableVertexAttribArray(ATTRIB_TEXCOORD_Y);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

        glUseProgram(_programUV);
        
        glActiveTexture(GL_TEXTURE2);
        glBindTexture(CVOpenGLESTextureGetTarget(foregroundChromaTexture), CVOpenGLESTextureGetName(foregroundChromaTexture));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        glActiveTexture(GL_TEXTURE3);
        glBindTexture(CVOpenGLESTextureGetTarget(backgroundChromaTexture), CVOpenGLESTextureGetName(backgroundChromaTexture));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        videoWidth =  CVPixelBufferGetWidthOfPlane(destinationPixelBuffer, 1);
        videoHeight = CVPixelBufferGetHeightOfPlane(destinationPixelBuffer, 1);
        glViewport(0, 0, (int)videoWidth, (int)videoHeight);
        
        // Attach the destination texture as a color attachment to the off screen frame buffer
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, CVOpenGLESTextureGetTarget(destChromaTexture), CVOpenGLESTextureGetName(destChromaTexture), 0);
        
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
            goto bail;
        }
        
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        glUniform1i(colorSwizzlingInputTextureUniformforback[UNIFORM_UV], 2);
        glUniform1i(forRotation[UNIFORM_UV], (GLint)forangleRa);
        glUniform1i(backRotation[UNIFORM_UV], (GLint)backangleRa);
        glUniform1i(colorSwizzlingInputTextureUniformback[UNIFORM_UV], 3);
        glUniform1f(colorSwizzlingInputTextureUniformProgress[UNIFORM_UV], tween);
        glUniform1i(colorSwizzlingFisrtBufferIsImage[UNIFORM_UV], (GLint)transtionModel.firstTrackIsImage);
        glUniform1i(colorSwizzlingSecondBufferIsImage[UNIFORM_UV], (GLint)transtionModel.secondTrackIsImage);
        glUniform1i(colorSwizzlingIsY[UNIFORM_UV], 0);
        glUniform4f(colorSwizzlingBackVideoFrameform[UNIFORM_UV], backFrame.origin.x, backFrame.origin.y, backFrame.size.width, backFrame.size.height);
        glUniform4f(colorSwizzlingForVideoFrameform[UNIFORM_UV], forFrame.origin.x, forFrame.origin.y, forFrame.size.width, forFrame.size.height);
        glUniform1f(colorSwizzlingFisrtBufferStartProgress[UNIFORM_UV], transtionModel.firstImageStartProgress);
        glUniform1f(colorSwizzlingSecondBufferStartProgress[UNIFORM_UV], transtionModel.secondImageStartProgress);
        glUniform1f(colorRatio[UNIFORM_UV], videoWidth / videoHeight);
        glVertexAttribPointer(ATTRIB_VERTEX_UV, 2, GL_FLOAT, 0, 0, quadVertexData1);
        glEnableVertexAttribArray(ATTRIB_VERTEX_UV);
        
        glVertexAttribPointer(ATTRIB_TEXCOORD_UV, 2, GL_FLOAT, 0, 0, quadTextureData1);
        glEnableVertexAttribArray(ATTRIB_TEXCOORD_UV);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        glFlush();

    bail:
        CFRelease(foregroundLumaTexture);
        CFRelease(foregroundChromaTexture);
        CFRelease(backgroundLumaTexture);
        CFRelease(backgroundChromaTexture);
        CFRelease(destLumaTexture);
        CFRelease(destChromaTexture);
        
        // Periodic texture cache flush every frame
        CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
        
        [EAGLContext setCurrentContext:nil];

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

@end
