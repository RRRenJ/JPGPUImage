//
//  JPTranstionsDefault.m
//  GPUImage
//
//  Created by FoundaoTEST on 2017/8/4.
//  Copyright © 2017年 Brad Larson. All rights reserved.
//

#import "JPTranstionsDefault.h"
#import "GPUImageFilter.h"




@implementation JPNewTranstionMode

- (instancetype)init
{
    if (self = [super init]) {
        _firstTrackIsImage = 0;
        _firstImageStartProgress = 1.0;
        _secondTrackIsImage = 0;
        _secondImageStartProgress = 1.0;
    }
    return self;
}


@end

@implementation JPTranstionsDefault

+ (instancetype)shareInstance
{
    static JPTranstionsDefault *defaltTranstion = nil;
    if (defaltTranstion == nil) {
        defaltTranstion = [[JPTranstionsDefault alloc] init];
    }
    return defaltTranstion;
}


+ (NSString *)programStrGetWithTranstionModel:(JPVideoTranstionsModel *)transtionsModel
{
    NSString *headerFile = [[NSBundle mainBundle] pathForResource:@"transtionHeader" ofType:@"glsl"];
    NSString *contentFile = [[NSBundle mainBundle] pathForResource:transtionsModel.transtionGlslFileName ofType:@"glsl"];
    NSString *headerStr = [NSString stringWithContentsOfFile:headerFile encoding:NSUTF8StringEncoding error:nil];
    NSString *contentStr = [NSString stringWithContentsOfFile:contentFile encoding:NSUTF8StringEncoding error:nil];
    
    return [NSString stringWithFormat:@"%@\n%@", headerStr, contentStr];
}
@end
