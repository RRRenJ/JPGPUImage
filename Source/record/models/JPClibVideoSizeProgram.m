//
//  JPClibVideoSizeProgram.m
//  GPUImage
//
//  Created by FoundaoTEST on 2017/9/4.
//  Copyright © 2017年 Brad Larson. All rights reserved.
//

#import "JPClibVideoSizeProgram.h"
#import "GPUImageFilter.h"
NSString *const JPTranstionPassThroughClibVertexShader = SHADER_STRING
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


NSString *const JPTranstionPassThroughClibFramgrantShader = SHADER_STRING
(
 precision highp float;
 varying vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform vec4 forVideoframe;
 uniform int firstIsImage;
 uniform float firstImageProgress;
 uniform int isY;
 uniform int imageType;
 uniform int rotationAngle;
 void main()
 {
     vec4 forColor = vec4(0.0);
     if (isY == 1)
     {
         forColor = vec4(0.0, 0.0, 0.0, 1.0);
     }else{
         forColor = vec4(0.5, 0.5, 0.0, 1.0);
     }
     if (textureCoordinate.x >= forVideoframe.x && textureCoordinate.x <= (forVideoframe.x + forVideoframe.z) && textureCoordinate.y >= forVideoframe.y && textureCoordinate.y <= (forVideoframe.y + forVideoframe.w) ) {
         vec2 position = vec2((textureCoordinate.x - forVideoframe.x) / forVideoframe.z, (textureCoordinate.y - forVideoframe.y) / forVideoframe.w);
         if (rotationAngle == 1)
         {
             position = vec2(1.0 - position.y, position.x);
         }else if (rotationAngle == 2)
         {
             position = vec2(position.y,1.0 - position.x);
         }else if (rotationAngle ==3)
         {
             position = vec2(1.0 - position.x,1.0 - position.y);

         }
         if (firstIsImage != 1)
         {
             forColor = texture2D(inputImageTexture, position);
         }else{
             float reallyProgress = 0.7 + firstImageProgress * 0.3;
             if (imageType == 2)
             {
                 reallyProgress = 0.7 + (1.0 - firstImageProgress) * 0.3;
             }
             float originX = (1.0 - reallyProgress) / 2.0;
             forColor = texture2D(inputImageTexture, vec2(originX +position.x * reallyProgress, originX + position.y * reallyProgress));
         }
     }
     gl_FragColor = forColor;
 }
 );


enum
{
    CLIB_UNIFORM_Y,
    CLIB_UNIFORM_UV,
};

enum
{
    CLIB_ATTRIB_VERTEX_Y,
    CLIB_ATTRIB_TEXCOORD_Y,
    CLIB_ATTRIB_VERTEX_UV,
    CLIB_ATTRIB_TEXCOORD_UV,
   	CLIB_NUM_ATTRIBUTES
};

@interface JPClibVideoSizeProgram ()
{
    GLuint _programY;
    GLuint _programUV;
    EAGLContext *_currentContext;
    GLint colorSwizzlingInputTextureUniform[2];
    CVOpenGLESTextureCacheRef _videoTextureCache;
    GLuint _offscreenBufferHandle;
    GLuint firstIsImage[2];
    GLuint firstImageProgress[2];
    GLuint forVideoframe[2];
    GLuint isY[2];
    GLuint imageTypes[2];
    GLuint rotationAngle[2];
}

@end
@implementation JPClibVideoSizeProgram
- (instancetype)init{
    if (self = [super init]) {
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
    vertShaderSource = JPTranstionPassThroughClibVertexShader;
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER source:vertShaderSource]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile Y fragment shader.
    fragShaderSource = JPTranstionPassThroughClibFramgrantShader;
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
    
    glBindAttribLocation(_programY, CLIB_ATTRIB_VERTEX_Y, "position");
    glBindAttribLocation(_programY, CLIB_ATTRIB_TEXCOORD_Y, "texCoord");
    glBindAttribLocation(_programUV, CLIB_ATTRIB_VERTEX_UV, "position");
    glBindAttribLocation(_programUV, CLIB_ATTRIB_TEXCOORD_UV, "texCoord");
    
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
    
    colorSwizzlingInputTextureUniform[CLIB_UNIFORM_Y] = glGetUniformLocation(_programY, "inputImageTexture");
    colorSwizzlingInputTextureUniform[CLIB_UNIFORM_UV] = glGetUniformLocation(_programUV, "inputImageTexture");
    forVideoframe[CLIB_UNIFORM_Y] = glGetUniformLocation(_programY, "forVideoframe");
    forVideoframe[CLIB_UNIFORM_UV] = glGetUniformLocation(_programUV, "forVideoframe");
    firstIsImage[CLIB_UNIFORM_Y] = glGetUniformLocation(_programY, "firstIsImage");
    firstIsImage[CLIB_UNIFORM_UV] = glGetUniformLocation(_programUV, "firstIsImage");
    firstImageProgress[CLIB_UNIFORM_Y] = glGetUniformLocation(_programY, "firstImageProgress");
    firstImageProgress[CLIB_UNIFORM_UV] = glGetUniformLocation(_programUV, "firstImageProgress");
    isY[CLIB_UNIFORM_Y] = glGetUniformLocation(_programY, "isY");
    isY[CLIB_UNIFORM_UV] = glGetUniformLocation(_programUV, "isY");
    imageTypes[CLIB_UNIFORM_Y] = glGetUniformLocation(_programY, "imageType");
    imageTypes[CLIB_UNIFORM_UV] = glGetUniformLocation(_programUV, "imageType");
    
    rotationAngle[CLIB_UNIFORM_Y] = glGetUniformLocation(_programY, "rotationAngle");
    rotationAngle[CLIB_UNIFORM_UV] = glGetUniformLocation(_programUV, "rotationAngle");

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


- (void)renderPixelBuffer:(CVPixelBufferRef)destinationPixelBuffer usingSourceBuffer:(CVPixelBufferRef)pixelBuffer andRotation:(GPUImageRotationMode)rotationMode andIsImage:(BOOL)isImage imageProgress:(CGFloat)imageProgress andImageType:(NSInteger)imageType
{
    [EAGLContext setCurrentContext:_currentContext];
    if (pixelBuffer != NULL) {
        CVOpenGLESTextureRef foregroundLumaTexture  = [self lumaTextureForPixelBuffer:pixelBuffer];
        CVOpenGLESTextureRef foregroundChromaTexture = [self chromaTextureForPixelBuffer:pixelBuffer];
        CVOpenGLESTextureRef destLumaTexture = [self lumaTextureForPixelBuffer:destinationPixelBuffer];
        CVOpenGLESTextureRef destChromaTexture = [self chromaTextureForPixelBuffer:destinationPixelBuffer];
        CGFloat videoWidth =  CVPixelBufferGetWidthOfPlane(destinationPixelBuffer, 0);
        CGFloat videoHeight = CVPixelBufferGetHeightOfPlane(destinationPixelBuffer, 0);
        CGFloat fillWidth =  CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
        CGFloat fillHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
        if (rotationMode == kGPUImageRotateRight || rotationMode == kGPUImageRotateLeft) {
            CGFloat contant = fillWidth;
            fillWidth = fillHeight;
            fillHeight = contant;
        }
        NSInteger angleRa = 0;
        switch (rotationMode) {
            case kGPUImageRotateRight:
                angleRa = 2;
                break;
            case kGPUImageRotateLeft:
                angleRa = 1;
                break;
            case kGPUImageRotate180:
                angleRa = 3;
                break;
            default:
                break;
        }
        CGRect forFrame = [self getLocalVideoCropSizeWithOriginSize:CGSizeMake(fillWidth, fillHeight) desSize:CGSizeMake(videoWidth, videoHeight)];
        glUseProgram(_programY);
        glBindFramebuffer(GL_FRAMEBUFFER, _offscreenBufferHandle);
        glViewport(0, 0, (int)videoWidth, (int)videoHeight);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(CVOpenGLESTextureGetTarget(foregroundLumaTexture), CVOpenGLESTextureGetName(foregroundLumaTexture));
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
        glUniform4f(forVideoframe[CLIB_UNIFORM_Y], forFrame.origin.x, forFrame.origin.y, forFrame.size.width, forFrame.size.height);
        glUniform1i(isY[CLIB_UNIFORM_Y], 1);
        glUniform1i(firstIsImage[CLIB_UNIFORM_Y], (isImage == YES ? 1 : 0));
        glUniform1i(rotationAngle[CLIB_UNIFORM_Y], (GLint)angleRa);

        glUniform1f(firstImageProgress[CLIB_UNIFORM_Y], imageProgress);
        glUniform1i(imageTypes[CLIB_UNIFORM_Y], (GLint)imageType);
        glUniform1i(colorSwizzlingInputTextureUniform[CLIB_UNIFORM_Y], 0);
        glVertexAttribPointer(CLIB_ATTRIB_VERTEX_Y, 2, GL_FLOAT, 0, 0, quadVertexData1);
        glEnableVertexAttribArray(CLIB_ATTRIB_VERTEX_Y);
        glVertexAttribPointer(CLIB_ATTRIB_TEXCOORD_Y, 2, GL_FLOAT, 0, 0, quadTextureData1);
        glEnableVertexAttribArray(CLIB_ATTRIB_TEXCOORD_Y);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        glUseProgram(_programUV);
        glActiveTexture(GL_TEXTURE2);
        glBindTexture(CVOpenGLESTextureGetTarget(foregroundChromaTexture), CVOpenGLESTextureGetName(foregroundChromaTexture));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        videoWidth =  CVPixelBufferGetWidthOfPlane(destinationPixelBuffer, 1);
        videoHeight = CVPixelBufferGetHeightOfPlane(destinationPixelBuffer, 1);
        glViewport(0, 0, (int)videoWidth, (int)videoHeight);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, CVOpenGLESTextureGetTarget(destChromaTexture), CVOpenGLESTextureGetName(destChromaTexture), 0);
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
            goto bail;
        }
        glClearColor(0.5f, 0.5f, 0.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        glUniform4f(forVideoframe[CLIB_UNIFORM_UV], forFrame.origin.x, forFrame.origin.y, forFrame.size.width, forFrame.size.height);
        glUniform1i(isY[CLIB_UNIFORM_UV], 0);
        glUniform1i(firstIsImage[CLIB_UNIFORM_UV], (isImage == YES ? 1 : 0));
        glUniform1f(firstImageProgress[CLIB_UNIFORM_UV], imageProgress);
        glUniform1i(imageTypes[CLIB_UNIFORM_UV], (GLint)imageType);
        glUniform1i(colorSwizzlingInputTextureUniform[CLIB_UNIFORM_UV], 2);
        glUniform1i(rotationAngle[CLIB_UNIFORM_UV], (GLint)angleRa);
        glVertexAttribPointer(CLIB_ATTRIB_VERTEX_UV, 2, GL_FLOAT, 0, 0, quadVertexData1);
        glEnableVertexAttribArray(CLIB_ATTRIB_VERTEX_UV);
        glVertexAttribPointer(CLIB_ATTRIB_TEXCOORD_UV, 2, GL_FLOAT, 0, 0, quadTextureData1);
        glEnableVertexAttribArray(CLIB_ATTRIB_TEXCOORD_UV);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        glFlush();
    bail:
        CFRelease(foregroundLumaTexture);
        CFRelease(foregroundChromaTexture);
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
