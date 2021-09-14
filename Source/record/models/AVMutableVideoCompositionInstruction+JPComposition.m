//
//  AVMutableVideoCompositionInstruction+JPComposition.m
//  GPUImage
//
//  Created by FoundaoTEST on 2017/8/4.
//  Copyright © 2017年 Brad Larson. All rights reserved.
//

#import "AVMutableVideoCompositionInstruction+JPComposition.h"
#import <objc/runtime.h>

//@property (nonatomic, assign, readwrite) BOOL isTransition;
//@property (nonatomic, assign, readwrite) BOOL isEnd;
//@property (nonatomic, assign, readwrite) CMPersistentTrackID foregroundTrackIDs;
//@property (nonatomic, assign, readwrite) CMPersistentTrackID backgroundTrackIDs;
//@property (nonatomic, assign, readwrite) CMPersistentTrackID passthroughTrackIDs;

static char const * const AVMutableVideoCompositionInstructionIsTransitionKey = "AVMutableVideoCompositionInstructionIsTransitionKey";
static char const * const AVMutableVideoCompositionInstructionIsEndKey = "AVMutableVideoCompositionInstructionIsEndKey";
static char const * const AVMutableVideoCompositionInstructionForegroundTrackIDsKey = "AVMutableVideoCompositionInstructionForegroundTrackIDsKey";
static char const * const AVMutableVideoCompositionInstructionBackgroundTrackIDsKey = "AVMutableVideoCompositionInstructionBackgroundTrackIDsKey";
static char const * const AVMutableVideoCompositionInstructionPassthroughTrackIDsKey = "AVMutableVideoCompositionInstructionPassthroughTrackIDsKey";
static char const * const AVMutableVideoCompositionInstructionTranstionModeKey = "AVMutableVideoCompositionInstructionTranstionModeKey";
//static char const * const AVMutableVideoCompositionInstructionIsImageKey = "AVMutableVideoCompositionInstructionIsImageKey";
//static char const * const AVMutableVideoCompositionInstructionStartProgressKey = "AVMutableVideoCompositionInstructionStartProgressKey";


@implementation AVMutableVideoCompositionInstruction (JPComposition)

//- (JPIndicatorAnimationView *)indicatorAnimationViewtton
//{
//    return objc_getAssociatedObject(self, UIViewControllerHUDKey);
//}
//
//- (void)setIndicatorAnimationViewtton:(JPIndicatorAnimationView *)indicatorAnimationViewtton
//{
//    objc_setAssociatedObject(self, UIViewControllerHUDKey,indicatorAnimationViewtton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}

- (void)setIsEnd:(BOOL)isEnd
{
    objc_setAssociatedObject(self, AVMutableVideoCompositionInstructionIsEndKey,[NSNumber numberWithBool:isEnd], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isEnd
{
    return [objc_getAssociatedObject(self, AVMutableVideoCompositionInstructionIsEndKey) boolValue];
}


- (void)setIsTransition:(BOOL)isTransition
{
    objc_setAssociatedObject(self, AVMutableVideoCompositionInstructionIsTransitionKey,[NSNumber numberWithBool:isTransition], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
 
}

- (BOOL)isTransition
{
    return [objc_getAssociatedObject(self, AVMutableVideoCompositionInstructionIsTransitionKey) boolValue];

}

- (CMPersistentTrackID)foregroundTrackIDs
{
    return (CMPersistentTrackID)[objc_getAssociatedObject(self, AVMutableVideoCompositionInstructionForegroundTrackIDsKey) integerValue];
}

- (void)setForegroundTrackIDs:(CMPersistentTrackID)foregroundTrackIDs
{
    objc_setAssociatedObject(self, AVMutableVideoCompositionInstructionForegroundTrackIDsKey,[NSNumber numberWithInteger:foregroundTrackIDs], OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

- (CMPersistentTrackID)backgroundTrackIDs
{
    return (CMPersistentTrackID)[objc_getAssociatedObject(self, AVMutableVideoCompositionInstructionBackgroundTrackIDsKey) integerValue];

}

- (void)setBackgroundTrackIDs:(CMPersistentTrackID)backgroundTrackIDs
{
    objc_setAssociatedObject(self, AVMutableVideoCompositionInstructionBackgroundTrackIDsKey,[NSNumber numberWithInteger:backgroundTrackIDs], OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}


- (void)setPassthroughTrackIDs:(CMPersistentTrackID)passthroughTrackIDs
{
    objc_setAssociatedObject(self, AVMutableVideoCompositionInstructionPassthroughTrackIDsKey,[NSNumber numberWithInteger:passthroughTrackIDs], OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

- (CMPersistentTrackID)passthroughTrackIDs
{
    return (CMPersistentTrackID)[objc_getAssociatedObject(self, AVMutableVideoCompositionInstructionPassthroughTrackIDsKey) integerValue];

}


- (void)setTranstionMode:(JPNewTranstionMode *)transtionMode
{
    objc_setAssociatedObject(self, AVMutableVideoCompositionInstructionTranstionModeKey,transtionMode, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

- (JPNewTranstionMode *)transtionMode
{
    return objc_getAssociatedObject(self, AVMutableVideoCompositionInstructionTranstionModeKey);
}

//- (void)setIsImage:(BOOL)isImage
//{
//     objc_setAssociatedObject(self, AVMutableVideoCompositionInstructionIsImageKey,[NSNumber numberWithBool:isImage], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (BOOL)isImage
//{
//    return [objc_getAssociatedObject(self, AVMutableVideoCompositionInstructionIsImageKey) boolValue];
//
//}

//- (void)setProgress:(CGFloat)progress
//{
//    objc_setAssociatedObject(self, AVMutableVideoCompositionInstructionStartProgressKey,[NSNumber numberWithFloat:progress], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (CGFloat)progress
//{
//    return [objc_getAssociatedObject(self, AVMutableVideoCompositionInstructionStartProgressKey) floatValue];
//
//}
@end
