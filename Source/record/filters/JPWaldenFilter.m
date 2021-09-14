//
//  JPWaldenFilter.m
//  jper
//
//  Created by FoundaoTEST on 2017/3/28.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#import "JPWaldenFilter.h"
NSString *const kIFWaldenShaderString = SHADER_STRING
(
 precision highp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2; //waldenMap
 uniform sampler2D inputImageTexture3; //vignetteMap
 
 void main()
 {
     
    highp vec3 texel = texture2D(inputImageTexture, textureCoordinate).rgb;
     
     texel = vec3(
                  texture2D(inputImageTexture2, vec2(texel.r, .16666)).r,
                  texture2D(inputImageTexture2, vec2(texel.g, .5)).g,
                  texture2D(inputImageTexture2, vec2(texel.b, .83333)).b);
     
    highp vec2 tc = (2.0 * textureCoordinate) - 1.0;
     float d = dot(tc, tc);
    highp vec2 lookup = vec2(d, texel.r);
     texel.r = texture2D(inputImageTexture3, lookup).r;
     lookup.y = texel.g;
     texel.g = texture2D(inputImageTexture3, lookup).g;
     lookup.y = texel.b;
     texel.b	= texture2D(inputImageTexture3, lookup).b;
     
     gl_FragColor = vec4(texel, 1.0);
 }
 );

@implementation JPWaldenFilter
- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kIFWaldenShaderString]))
    {
        return nil;
    }
    
    return self;
}

@end
