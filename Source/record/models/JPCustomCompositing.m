/*
 File: APLCustomVideoCompositor.m
 Abstract: Custom video compositor class implementing the AVVideoCompositing protocol.
 Version: 1.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */





#import "JPCustomCompositing.h"
#import <CoreVideo/CoreVideo.h>
#import <CoreImage/CoreImage.h>
#import "AVMutableVideoCompositionInstruction+JPComposition.h"
#import "GPUImageFramebuffer.h"
#import "GLProgram.h"
#import "GPUImageFilter.h"
#import "JPTranstionsDefault.h"
#import "JPTranstionProgramModel.h"
#import "JPGeneralFilter.h"
#import "JPPublicConstant.h"
#import "JPCoustomInstruction.h"
#import "JPClibVideoSizeProgram.h"
//Float64 factorForTimeInRange(CMTime time, CMTimeRange range) /* 0.0 -> 1.0 */
//{
//    CMTime elapsed = CMTimeSubtract(time, range.start);
//    return CMTimeGetSeconds(elapsed) / CMTimeGetSeconds(range.duration);
//}


@interface JPCustomCompositing()
{
    BOOL								_shouldCancelAllRequests;
    BOOL								_renderContextDidChange;
    dispatch_queue_t					_renderingQueue;
    dispatch_queue_t					_renderContextQueue;
    AVVideoCompositionRenderContext*	_renderContext;
    CVPixelBufferRef					_previousBuffer;
    GLuint movieFramebuffer, movieRenderbuffer;
    CGFloat width;
    CGFloat height;
    JPClibVideoSizeProgram *clibProgramModel;

}

@property (nonatomic, strong) NSMutableDictionary *programDic;
@property (nonatomic, strong) JPGeneralFilter *generalFilter;
@end


@implementation JPCustomCompositing

#pragma mark - AVVideoCompositing protocol

- (id)init
{
    self = [super init];
    if (self)
    {
        _renderingQueue = dispatch_queue_create("com.apple.aplcustomvideocompositor.renderingqueue", DISPATCH_QUEUE_SERIAL);
        _renderContextQueue = dispatch_queue_create("com.apple.aplcustomvideocompositor.rendercontextqueue", DISPATCH_QUEUE_SERIAL);
        _previousBuffer = nil;
        _renderContextDidChange = NO;
        NSArray *transtionArr = [JPTranstionsDefault shareInstance].transtionArr.copy;
        _programDic = [NSMutableDictionary dictionary];
        clibProgramModel = [[JPClibVideoSizeProgram alloc] init];
        for (JPNewTranstionMode *model in transtionArr) {
            JPTranstionProgramModel *programModel = [_programDic objectForKey:@(model.videoTranstionType)];
            if (programModel == nil) {
                
                programModel = [[JPTranstionProgramModel alloc]  initWithTranstionModel:model];
                [_programDic setObject:programModel forKey:@(programModel.transtionType)];
            }
        }
    }
    return self;
}


- (NSDictionary *)sourcePixelBufferAttributes
{
    return @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange],
              (NSString*)kCVPixelBufferOpenGLESCompatibilityKey : [NSNumber numberWithBool:YES]};
}

- (NSDictionary *)requiredPixelBufferAttributesForRenderContext
{
    return @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange],
              (NSString*)kCVPixelBufferOpenGLESCompatibilityKey : [NSNumber numberWithBool:YES]};
}


- (void)renderContextChanged:(AVVideoCompositionRenderContext *)newRenderContext
{
    dispatch_sync(_renderContextQueue, ^() {
        _renderContext = newRenderContext;
        _renderContextDidChange = YES;
    });
}

- (void)startVideoCompositionRequest:(AVAsynchronousVideoCompositionRequest *)request
{
    @autoreleasepool {
        dispatch_async(_renderingQueue,^() {
            
            // Check if all pending requests have been cancelled
            if (_shouldCancelAllRequests) {
                [request finishCancelledRequest];
            } else {
                NSError *err = nil;
                // Get the next rendererd pixel buffer
                CVPixelBufferRef resultPixels = [self newRenderedPixelBufferForRequest:request error:&err];
                
                if (resultPixels) {
                    // The resulting pixelbuffer from OpenGL renderer is passed along to the request
                    [request finishWithComposedVideoFrame:resultPixels];
                    CFRelease(resultPixels);
                } else {
                    [request finishWithError:err];
                }
            }
        });
    }
}

- (void)cancelAllPendingVideoCompositionRequests
{
    // pending requests will call finishCancelledRequest, those already rendering will call finishWithComposedVideoFrame
    _shouldCancelAllRequests = YES;
    
    dispatch_barrier_async(_renderingQueue, ^() {
        // start accepting requests again
        _shouldCancelAllRequests = NO;
    });
}

#pragma mark - Utilities

//Float64 factorForTimeInRange(CMTime time, CMTimeRange range) /* 0.0 -> 1.0 */
//{
//    CMTime elapsed = CMTimeSubtract(time, range.start);
//    return CMTimeGetSeconds(elapsed) / CMTimeGetSeconds(range.duration);
//}

- (Float64)factorForTime:(CMTime)time InRange:(CMTimeRange)range
{
        CMTime elapsed = CMTimeSubtract(time, range.start);
        return CMTimeGetSeconds(elapsed) / CMTimeGetSeconds(range.duration);
}
- (CVPixelBufferRef)newRenderedPixelBufferForRequest:(AVAsynchronousVideoCompositionRequest *)request error:(NSError **)errOut
{
    CVPixelBufferRef newBuffer = [_renderContext newPixelBuffer];
    JPCoustomInstruction *currentInstruction = (JPCoustomInstruction *)request.videoCompositionInstruction;
    if (currentInstruction.isTransition == YES) {
        float tweenFactor = [self factorForTime:request.compositionTime InRange:request.videoCompositionInstruction.timeRange];
        CVPixelBufferRef forepixels = [request sourceFrameByTrackID:currentInstruction.foregroundTrackID];
        CVPixelBufferRef pixelBack = [request sourceFrameByTrackID:currentInstruction.backgroundTrackID];
        JPNewTranstionMode *transtionMode = currentInstruction.transtionMode;
        JPTranstionProgramModel *transProgramModel = [_programDic objectForKey:@(transtionMode.videoTranstionType)];
        [transProgramModel renderPixelBuffer:newBuffer usingForegroundSourceBuffer:forepixels andBackgroundSourceBuffer:pixelBack forTweenFactor:tweenFactor andTranstionModel:transtionMode forInputRotation:currentInstruction.foregroundMode backInputRotation:currentInstruction.backgroundMode];
    }else{
        CVPixelBufferRef pixels = [request sourceFrameByTrackID:currentInstruction.currentTrackId];
        BOOL isImage = (currentInstruction.isImage && currentInstruction.photoTranstionType != 0);
        CGFloat tweenFactor = 0.0;
        if (isImage) {
          tweenFactor = [self factorForTime:request.compositionTime InRange:request.videoCompositionInstruction.timeRange];
        }
        [clibProgramModel renderPixelBuffer:newBuffer usingSourceBuffer:pixels andRotation:currentInstruction.passthoudMode andIsImage:isImage imageProgress:tweenFactor andImageType:currentInstruction.photoTranstionType];
    }
    return newBuffer;
}







@end
