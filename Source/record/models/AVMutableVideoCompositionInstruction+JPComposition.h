//
//  AVMutableVideoCompositionInstruction+JPComposition.h
//  GPUImage
//
//  Created by FoundaoTEST on 2017/8/4.
//  Copyright © 2017年 Brad Larson. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "JPVideoModel.h"
#import "JPTranstionsDefault.h"
@interface AVMutableVideoCompositionInstruction (JPComposition)

@property (nonatomic, assign, readwrite) BOOL isTransition;
@property (nonatomic, assign, readwrite) BOOL isEnd;
@property (nonatomic, assign, readwrite) CMPersistentTrackID foregroundTrackIDs;
@property (nonatomic, assign, readwrite) CMPersistentTrackID backgroundTrackIDs;
@property (nonatomic, assign, readwrite) CMPersistentTrackID passthroughTrackIDs;
@property (nonatomic, strong) JPNewTranstionMode *transtionMode;

@end
