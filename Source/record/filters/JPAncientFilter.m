//
//  JPAncientFilter.m
//  jper
//
//  Created by FoundaoTEST on 2017/3/28.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#import "JPAncientFilter.h"

NSString *const kIF1977ShaderString = SHADER_STRING
(
 precision highp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture; //1977map
 uniform sampler2D inputImageTexture2; //1977blowout
 
 void main()
 {
     
     highp vec3 texel = texture2D(inputImageTexture, textureCoordinate).rgb;
     
     texel = vec3(
                  texture2D(inputImageTexture2, vec2(texel.r, .16666)).r,
                  texture2D(inputImageTexture2, vec2(texel.g, .5)).g,
                  texture2D(inputImageTexture2, vec2(texel.b, .83333)).b);
     
     gl_FragColor = vec4(texel, 1.0);
 }
 );
@implementation JPAncientFilter

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kIF1977ShaderString]))
    {
        return nil;
    }
    
    return self;
}

@end
