//
//  JPCircularFilter.m
//  GPUImage
//
//  Created by FoundaoTEST on 2017/7/13.
//  Copyright © 2017年 Brad Larson. All rights reserved.
//

#import "JPCircularFilter.h"
#import "GPUImagePicture.h"
#import "JPPublicConstant.h"
NSString *const JPCircularFragmentShaderString = SHADER_STRING
(
 precision highp float;
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputCircularImageTexture;
 uniform highp vec4 circularFrame;

 void main()
 {
     highp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     if (textureCoordinate.x >= circularFrame.x && textureCoordinate.x <= circularFrame.x + circularFrame.z && textureCoordinate.y >= circularFrame.y && textureCoordinate.y <= circularFrame.y + circularFrame.w){
         highp vec2 point = vec2((textureCoordinate.x - circularFrame.x) / circularFrame.z, (textureCoordinate.y - circularFrame.y) / circularFrame.w);
         vec4 color = texture2D(inputCircularImageTexture, point);
         textureColor = textureColor * (1.0 - color.a) + color;
     }
     gl_FragColor = textureColor;
 }
 );


@interface JPCircularFilter ()

{
    GLint inputCircularImageTextureUniform;
    GLint circularFrameUniform;
    GPUImageFramebuffer *pictureBuffer;

}

@end

@implementation JPCircularFilter

- (instancetype)init
{
    if (self = [super initWithFragmentShaderFromString:JPCircularFragmentShaderString]) {
        inputCircularImageTextureUniform = [filterProgram uniformIndex:@"inputCircularImageTexture"];
        circularFrameUniform = [filterProgram uniformIndex:@"circularFrame"];
//        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"circular" ofType:@"png"];
        UIImage * image = [UIImage imageNamed:@"circular" inBundle:JP_Resource_bundle compatibleWithTraitCollection:nil];
        GPUImagePicture * picture = [[GPUImagePicture alloc] initWithImage:image];
        pictureBuffer = [picture framebufferForOutput];
        [pictureBuffer lock];
    }
    return self;
}


- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates
{
    
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        [pictureBuffer unlock];
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
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, [pictureBuffer texture]);
    glUniform1i(inputCircularImageTextureUniform, 3);
    CGSize size = [self sizeOfFBO];
    CGRect frame = [self getLocalVideoCropSizeWithOriginSize:size];
    glUniform4f(circularFrameUniform, frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [firstInputFramebuffer unlock];
    [pictureBuffer unlock];
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }

}

- (CGRect)getLocalVideoCropSizeWithOriginSize:(CGSize)originSize
{
    CGRect videoCropRect = CGRectZero;
    CGFloat ratio = 1.0;
    CGFloat width = 1.0;
    CGFloat height = 1.0;
    if (originSize.width / originSize.height <= ratio) {
        height = (originSize.width / ratio) / originSize.height;
    }else{
        width = (originSize.height * ratio) / originSize.width;
    }
    videoCropRect = CGRectMake((1.0 - width) / 2.0, (1.0 - height) / 2.0, width, height);
    return videoCropRect;
}

@end
