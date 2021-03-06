//
//  JPHudsonFilter.m
//  jper
//
//  Created by FoundaoTEST on 2017/3/28.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#import "JPHudsonFilter.h"

NSString *const kIFHudsonShaderString = SHADER_STRING
(
 precision highp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2; //hudsonBackground;
 uniform sampler2D inputImageTexture3; //overlayMap;
 uniform sampler2D inputImageTexture4; //hudsonMap
 
 void main()
 {
     
    highp vec4 texel = texture2D(inputImageTexture, textureCoordinate);
     
    highp vec3 bbTexel = texture2D(inputImageTexture2, textureCoordinate).rgb;
     
     texel.r = texture2D(inputImageTexture3, vec2(bbTexel.r, texel.r)).r;
     texel.g = texture2D(inputImageTexture3, vec2(bbTexel.g, texel.g)).g;
     texel.b = texture2D(inputImageTexture3, vec2(bbTexel.b, texel.b)).b;
     
    highp vec4 mapped;
     mapped.r = texture2D(inputImageTexture4, vec2(texel.r, .16666)).r;
     mapped.g = texture2D(inputImageTexture4, vec2(texel.g, .5)).g;
     mapped.b = texture2D(inputImageTexture4, vec2(texel.b, .83333)).b;
     mapped.a = 1.0;
     gl_FragColor = mapped;
 }
);

@implementation JPHudsonFilter

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kIFHudsonShaderString]))
    {
        return nil;
    }
    
    return self;
}
@end
