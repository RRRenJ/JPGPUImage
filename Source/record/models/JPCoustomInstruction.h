//
//  JPCoustomInstruction.h
//  GPUImage
//
//  Created by FoundaoTEST on 2017/8/7.
//  Copyright © 2017年 Brad Larson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "JPTranstionsDefault.h"
#import "GPUImageContext.h"
#import "JPPhotoModel.h"
@interface JPCoustomInstruction : NSObject <AVVideoCompositionInstruction>
@property CMPersistentTrackID foregroundTrackID;
@property CMPersistentTrackID backgroundTrackID;
@property (nonatomic, assign, readwrite) BOOL isTransition;
@property (nonatomic, assign, readwrite) BOOL isEnd;
@property (nonatomic, strong) JPNewTranstionMode *transtionMode;
@property (nonatomic, assign, readonly) CMPersistentTrackID currentTrackId;
@property (nonatomic, assign) BOOL isImage;
@property (nonatomic) JPPhotoModelTranstionType photoTranstionType;
@property (nonatomic) GPUImageRotationMode passthoudMode;
@property (nonatomic) GPUImageRotationMode foregroundMode;
@property (nonatomic) GPUImageRotationMode backgroundMode;
- (id)initPassThroughTrackID:(CMPersistentTrackID)passthroughTrackID forTimeRange:(CMTimeRange)timeRange;
- (id)initTransitionWithSourceTrackIDs:(NSArray*)sourceTrackIDs forTimeRange:(CMTimeRange)timeRange;
@end
