//
//  JPCoustomInstruction.m
//  GPUImage
//
//  Created by FoundaoTEST on 2017/8/7.
//  Copyright © 2017年 Brad Larson. All rights reserved.
//

#import "JPCoustomInstruction.h"

@implementation JPCoustomInstruction

@synthesize timeRange = _timeRange;
@synthesize enablePostProcessing = _enablePostProcessing;
@synthesize containsTweening = _containsTweening;
@synthesize requiredSourceTrackIDs = _requiredSourceTrackIDs;
@synthesize passthroughTrackID = _passthroughTrackID;

- (id)initPassThroughTrackID:(CMPersistentTrackID)passthroughTrackID forTimeRange:(CMTimeRange)timeRange
{
    self = [super init];
    if (self) {
        _passthroughTrackID = kCMPersistentTrackID_Invalid;
        _requiredSourceTrackIDs = @[@(passthroughTrackID)];
        _timeRange = timeRange;
        _containsTweening = FALSE;
        _enablePostProcessing = FALSE;
        _currentTrackId = passthroughTrackID;
    }
    
    return self;
}

- (id)initTransitionWithSourceTrackIDs:(NSArray *)sourceTrackIDs forTimeRange:(CMTimeRange)timeRange
{
    self = [super init];
    if (self) {
        _requiredSourceTrackIDs = sourceTrackIDs;
        _passthroughTrackID = kCMPersistentTrackID_Invalid;
        _timeRange = timeRange;
        _containsTweening = TRUE;
        _enablePostProcessing = FALSE;
    }
    
    return self;
}

@end
