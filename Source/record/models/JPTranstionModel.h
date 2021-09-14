//
//  JPTranstionModel.h
//  jper
//
//  Created by FoundaoTEST on 2017/4/7.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPVideoModel.h"
#import "GPUImageFramebuffer.h"
@interface JPTranstionModel : NSObject
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic) JPVideoTranstionType transtionType;
@property (nonatomic, strong) GPUImageFramebuffer *framebuffer;
@property (nonatomic, assign) CMTimeRange transtionTimeRange;
@end
