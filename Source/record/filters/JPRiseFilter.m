//
//  JPRiseFilter.m
//  jper
//
//  Created by FoundaoTEST on 2017/3/27.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#import "JPRiseFilter.h"
NSString *const kIFRiseShaderString = SHADER_STRING
(
 precision highp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2; //blackboard1024;
 uniform sampler2D inputImageTexture3; //overlayMap;
 uniform sampler2D inputImageTexture4; //riseMap
 
 void main()
 {
     
    highp vec4 texel = texture2D(inputImageTexture, textureCoordinate); //原始图片的rgb值
    highp vec3 bbTexel = texture2D(inputImageTexture2, textureCoordinate).rgb; //blackboard1024对应的rgb
     
     texel.r = texture2D(inputImageTexture3, vec2(bbTexel.r, texel.r)).r; //
     texel.g = texture2D(inputImageTexture3, vec2(bbTexel.g, texel.g)).g;
     texel.b = texture2D(inputImageTexture3, vec2(bbTexel.b, texel.b)).b;
     
     vec4 mapped;
     mapped.r = texture2D(inputImageTexture4, vec2(texel.r, .16666)).r;
     mapped.g = texture2D(inputImageTexture4, vec2(texel.g, .5)).g;
     mapped.b = texture2D(inputImageTexture4, vec2(texel.b, .83333)).b;
     mapped.a = 1.0;
     
     gl_FragColor = mapped;
 }
 );

@implementation JPRiseFilter
- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kIFRiseShaderString]))
    {
        return nil;
    }
    
    return self;
}

@end
