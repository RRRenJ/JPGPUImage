//
//  JPBaseCompositionPlayer.m
//  GPUImage
//
//  Created by FoundaoTEST on 2017/10/17.
//  Copyright © 2017年 Brad Larson. All rights reserved.
//

#import "JPBaseCompositionPlayer.h"
#import "GPUImageMovieWriter.h"
@interface JPBaseCompositionPlayer ()
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CADisplayLink *displayLink;
#else
    CVDisplayLinkRef displayLink;
#endif
    AVPlayerItemVideoOutput *playerItemOutput;
    const GLfloat *_preferredConversion;
    BOOL isFullYUVRange;
    GLProgram *yuvConversionProgram;
    GLint yuvConversionPositionAttribute, yuvConversionTextureCoordinateAttribute;
    GLint yuvConversionLuminanceTextureUniform, yuvConversionChrominanceTextureUniform;
    GLint yuvIsAnotherUniform;
    GLint yuvConversionMatrixUniform;
    CMTime previousFrameTime, processingFrameTime;
    CFAbsoluteTime previousActualFrameTime;
    BOOL audioEncodingIsFinished, videoEncodingIsFinished;
    int imageBufferWidth, imageBufferHeight;
    BOOL willStop;
    GLuint luminanceTexture, chrominanceTexture;
    GPUImageMovieWriter *synchronizedMovieWriter;
    dispatch_queue_t _myVideoOutputQueue;
    
}
@property (strong, readwrite) GPUImageView *renderView;
@property (nonatomic, strong) GPUImageMovieWriter *originMovieWriter;
@property (nonatomic, strong) NSString *originMoiveName;
@property (nonatomic, assign) BOOL isCompsitiom;
@property (nonatomic, strong) AVPlayer *audioPlayer;
@property (nonatomic, strong) AVPlayerItem *avplayerItem;
@property (nonatomic, strong) NSMutableArray *filters;
@property (nonatomic, strong) AVAssetReader *playReader;
@property (nonatomic, strong) AVMutableAudioMix *audioMix;

@end


@implementation JPBaseCompositionPlayer

- (instancetype)initWithIsComposition:(BOOL)isComposition andRecordInfo:(JPBaseVideoRecordInfo *)recordInfo
{
    if (self = [self init])
    {
        _recordInfo = recordInfo;
        _compositon = recordInfo.composition;
        _videoComposition = recordInfo.videoComposition;
        _audioMute = NO;
        _isCompsitiom = isComposition;
        _myVideoOutputQueue = dispatch_queue_create("myVideoOutputQueue", DISPATCH_QUEUE_SERIAL);
        [self yuvConversionSetup];
        _isPlaying = NO;
        self.playAtActualSpeed = YES;
        self.runBenchmark = YES;
        _renderView = [[GPUImageView alloc] init];
        [self addTarget:_renderView];
        if (_isCompsitiom == NO) {
            _audioPlayer = [[AVPlayer alloc] init];
        }
    }
    return self;
}


- (GPUImageView *)gpuImageView
{
    return _renderView;
}

-(BOOL)startPlaying
{
    if (self.compositon == nil)
    {
        return NO;
    }
    self.stickersFilter.needSticker = YES;
    if (_isCompsitiom == NO) {
        _isPlaying = YES;
        if (_avplayerItem.status == AVPlayerItemStatusReadyToPlay) {
            [self.audioPlayer play];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(videoCompositionPlayerWillPlaying)]) {
            [self.delegate videoCompositionPlayerWillPlaying];
        }
        return YES;
    };
    if (_playReader == nil || _playReader.status != AVAssetReaderStatusReading) {
        [self clearLastPlayResourse];
        _playReader = [self createAssetReader];
    }
    if (_playReader.status != AVAssetReaderStatusReading) {
        previousActualFrameTime = CFAbsoluteTimeGetCurrent();
        previousFrameTime = kCMTimeZero;
        if ([_playReader startReading] == NO) {
            _isPlaying = NO;
            [self clearLastPlayResourse];
            return NO;
        }
    }
    _isPlaying = YES;
   
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self processAsset];
    });
    return YES;
}


- (AVAssetReader*)createAssetReader
{
    if (self.compositon == nil) {
        return nil;
    }
    NSError *error = nil;
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:self.compositon error:&error];
    
    NSDictionary *outputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
    AVAssetReaderVideoCompositionOutput *readerVideoOutput = [AVAssetReaderVideoCompositionOutput assetReaderVideoCompositionOutputWithVideoTracks:[_compositon tracksWithMediaType:AVMediaTypeVideo]
                                                                                                                                     videoSettings:outputSettings];
    readerVideoOutput.videoComposition = _videoComposition;
    readerVideoOutput.alwaysCopiesSampleData = NO;
    [assetReader addOutput:readerVideoOutput];
    return assetReader;
}


- (void)processAsset
{
    AVAssetReaderOutput *readerVideoTrackOutput = nil;
    audioEncodingIsFinished = YES;
    videoEncodingIsFinished = YES;
    for( AVAssetReaderOutput *output in _playReader.outputs ) {
        if( [output.mediaType isEqualToString:AVMediaTypeVideo] ) {
            videoEncodingIsFinished = NO;
            readerVideoTrackOutput = output;
        }
    }
    [self.stickersFilter filterStikersShouldBeNone];
    __weak typeof(self) weakSelf = self;
    if (synchronizedMovieWriter != nil)
    {
        
        [synchronizedMovieWriter setVideoInputReadyCallback:^{
            BOOL success =  [weakSelf readNextVideoFrameFromOutput:readerVideoTrackOutput withReader:weakSelf.playReader];
            ;
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
            return success;
#endif
        }];
        [synchronizedMovieWriter enableSynchronizationCallbacks];
    }
}


- (BOOL)readNextVideoFrameFromOutput:(AVAssetReaderOutput *)readerVideoTrackOutput withReader:(AVAssetReader *)reader;
{
    
    if (reader.status == AVAssetReaderStatusReading && videoEncodingIsFinished == NO)
    {
        
        CMSampleBufferRef sampleBufferRef = [readerVideoTrackOutput copyNextSampleBuffer];
        if (sampleBufferRef)
        {
            __unsafe_unretained typeof(self) weakSelf = self;
            runSynchronouslyOnVideoProcessingQueue(^{
                [weakSelf processMovieFrame:sampleBufferRef];
                CMSampleBufferInvalidate(sampleBufferRef);
                CFRelease(sampleBufferRef);
            });
            return YES;
        }else{
            videoEncodingIsFinished = YES;
            if (videoEncodingIsFinished && audioEncodingIsFinished) {
                [self endProcessing];
            }
        }
    }
    else if (synchronizedMovieWriter != nil)
    {
        if (reader.status == AVAssetReaderStatusCompleted || reader.status == AVAssetReaderStatusFailed ||
            reader.status == AVAssetReaderStatusCancelled)
        {
            [self endProcessing];
        }else{
            if (videoEncodingIsFinished && audioEncodingIsFinished) {
                [self endProcessing];
            }
        }
    }
    return NO;
}


- (void)processMovieFrame:(CMSampleBufferRef)movieSampleBuffer;
{
    //    CMTimeGetSeconds
    //    CMTimeSubtract
    
    CMTime currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(movieSampleBuffer);
    Float64 currentTime = CMTimeGetSeconds(currentSampleTime);
    Float64 totalTime = CMTimeGetSeconds(_compositon.duration);
    if (self.updateProgressBlock) {
        CGFloat progress = currentTime / totalTime;
        if ((NSInteger)(progress * 1000) % 20 == 0 || (NSInteger)(progress * 1000) % 25 == 0 ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.updateProgressBlock) {
                    self.updateProgressBlock(progress);
                }
            });
        }
    }
    
    CVImageBufferRef movieFrame = CMSampleBufferGetImageBuffer(movieSampleBuffer);
    processingFrameTime = currentSampleTime;
    [self processMovieFrame:movieFrame withSampleTime:currentSampleTime];
}


- (void)startToRenderFrameAtTime:(CMTime)currentSampleTime
{
    NSLog(@"自己去实现逻辑的地方");
}

- (void)processMovieFrame:(CVPixelBufferRef)movieFrame withSampleTime:(CMTime)currentSampleTime
{
    [self startToRenderFrameAtTime:currentSampleTime];
    int bufferHeight = (int) CVPixelBufferGetHeight(movieFrame);
    int bufferWidth = (int) CVPixelBufferGetWidth(movieFrame);
    CFTypeRef colorAttachments = CVBufferGetAttachment(movieFrame, kCVImageBufferYCbCrMatrixKey, NULL);
    if (colorAttachments != NULL)
    {
        if(CFStringCompare(colorAttachments, kCVImageBufferYCbCrMatrix_ITU_R_601_4, 0) == kCFCompareEqualTo)
        {
            if (isFullYUVRange)
            {
                _preferredConversion = kColorConversion601FullRange;
            }
            else
            {
                _preferredConversion = kColorConversion601;
            }
        }
        else
        {
            _preferredConversion = kColorConversion709;
        }
    }
    else
    {
        if (isFullYUVRange)
        {
            _preferredConversion = kColorConversion601FullRange;
        }
        else
        {
            _preferredConversion = kColorConversion601;
        }
        
    }
    
    
    // Fix issue 1580
    [GPUImageContext useImageProcessingContext];
    
    if ([GPUImageContext supportsFastTextureUpload])
    {
        
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        CVOpenGLESTextureRef luminanceTextureRef = NULL;
        CVOpenGLESTextureRef chrominanceTextureRef = NULL;
#else
        CVOpenGLTextureRef luminanceTextureRef = NULL;
        CVOpenGLTextureRef chrominanceTextureRef = NULL;
#endif
        
        //        if (captureAsYUV && [GPUImageContext deviceSupportsRedTextures])
        if (CVPixelBufferGetPlaneCount(movieFrame) > 0) // Check for YUV planar inputs to do RGB conversion
        {
            
            // fix issue 2221
            CVPixelBufferLockBaseAddress(movieFrame,0);
            
            
            if ( (imageBufferWidth != bufferWidth) && (imageBufferHeight != bufferHeight) )
            {
                imageBufferWidth = bufferWidth;
                imageBufferHeight = bufferHeight;
            }
            
            CVReturn err;
            // Y-plane
            glActiveTexture(GL_TEXTURE4);
            if ([GPUImageContext deviceSupportsRedTextures])
            {
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
                err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [[GPUImageContext sharedImageProcessingContext] coreVideoTextureCache], movieFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE, bufferWidth, bufferHeight, GL_LUMINANCE, GL_UNSIGNED_BYTE, 0, &luminanceTextureRef);
#else
                err = CVOpenGLTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [[GPUImageContext sharedImageProcessingContext] coreVideoTextureCache], movieFrame, NULL, &luminanceTextureRef);
#endif
            }
            else
            {
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
                err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [[GPUImageContext sharedImageProcessingContext] coreVideoTextureCache], movieFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE, bufferWidth, bufferHeight, GL_LUMINANCE, GL_UNSIGNED_BYTE, 0, &luminanceTextureRef);
#else
                err = CVOpenGLTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [[GPUImageContext sharedImageProcessingContext] coreVideoTextureCache], movieFrame, NULL, &luminanceTextureRef);
#endif
            }
            if (err)
            {
                NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
            }
            
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
            luminanceTexture = CVOpenGLESTextureGetName(luminanceTextureRef);
#else
            luminanceTexture = CVOpenGLTextureGetName(luminanceTextureRef);
#endif
            glBindTexture(GL_TEXTURE_2D, luminanceTexture);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            
            // UV-plane
            glActiveTexture(GL_TEXTURE5);
            if ([GPUImageContext deviceSupportsRedTextures])
            {
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
                err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [[GPUImageContext sharedImageProcessingContext] coreVideoTextureCache], movieFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE_ALPHA, bufferWidth/2, bufferHeight/2, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, 1, &chrominanceTextureRef);
#else
                err = CVOpenGLTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [[GPUImageContext sharedImageProcessingContext] coreVideoTextureCache], movieFrame, NULL, &chrominanceTextureRef);
#endif
            }
            else
            {
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
                err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [[GPUImageContext sharedImageProcessingContext] coreVideoTextureCache], movieFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE_ALPHA, bufferWidth/2, bufferHeight/2, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, 1, &chrominanceTextureRef);
#else
                err = CVOpenGLTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [[GPUImageContext sharedImageProcessingContext] coreVideoTextureCache], movieFrame, NULL, &chrominanceTextureRef);
#endif
            }
            if (err)
            {
                NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
            }
            
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
            chrominanceTexture = CVOpenGLESTextureGetName(chrominanceTextureRef);
#else
            chrominanceTexture = CVOpenGLTextureGetName(chrominanceTextureRef);
#endif
            glBindTexture(GL_TEXTURE_2D, chrominanceTexture);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            
            //            if (!allTargetsWantMonochromeData)
            //            {
            [self convertYUVToRGBOutputWithTime:currentSampleTime];
            //            }
            
            for (id<GPUImageInput> currentTarget in targets)
            {
                NSInteger indexOfObject = [targets indexOfObject:currentTarget];
                NSInteger targetTextureIndex = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
                [currentTarget setInputSize:CGSizeMake(bufferWidth, bufferHeight) atIndex:targetTextureIndex];
                [currentTarget setInputFramebuffer:outputFramebuffer atIndex:targetTextureIndex];
            }
            
            [outputFramebuffer unlock];
            
            for (id<GPUImageInput> currentTarget in targets)
            {
                NSInteger indexOfObject = [targets indexOfObject:currentTarget];
                NSInteger targetTextureIndex = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
                [currentTarget newFrameReadyAtTime:currentSampleTime atIndex:targetTextureIndex];
            }
            
            CVPixelBufferUnlockBaseAddress(movieFrame, 0);
            if (luminanceTextureRef != NULL) {
                CFRelease(luminanceTextureRef);
            }
            if (chrominanceTextureRef != NULL) {
                CFRelease(chrominanceTextureRef);
            }
        }
    }
    else
    {
        // Upload to texture
        CVPixelBufferLockBaseAddress(movieFrame, 0);
        
        outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:CGSizeMake(bufferWidth, bufferHeight) textureOptions:self.outputTextureOptions onlyTexture:YES];
        
        glBindTexture(GL_TEXTURE_2D, [outputFramebuffer texture]);
        // Using BGRA extension to pull in video frame data directly
        glTexImage2D(GL_TEXTURE_2D,
                     0,
                     self.outputTextureOptions.internalFormat,
                     bufferWidth,
                     bufferHeight,
                     0,
                     self.outputTextureOptions.format,
                     self.outputTextureOptions.type,
                     CVPixelBufferGetBaseAddress(movieFrame));
        
        for (id<GPUImageInput> currentTarget in targets)
        {
            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
            NSInteger targetTextureIndex = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
            [currentTarget setInputSize:CGSizeMake(bufferWidth, bufferHeight) atIndex:targetTextureIndex];
            [currentTarget setInputFramebuffer:outputFramebuffer atIndex:targetTextureIndex];
        }
        
        [outputFramebuffer unlock];
        
        for (id<GPUImageInput> currentTarget in targets)
        {
            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
            NSInteger targetTextureIndex = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
            [currentTarget newFrameReadyAtTime:currentSampleTime atIndex:targetTextureIndex];
        }
        
        CVPixelBufferUnlockBaseAddress(movieFrame, 0);
    }
    
}


- (void)convertYUVToRGBOutputWithTime:(CMTime)time;
{
    [GPUImageContext setActiveShaderProgram:yuvConversionProgram];
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:CGSizeMake(imageBufferWidth, imageBufferHeight) onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    static const GLfloat squareVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    static const GLfloat textureCoordinates[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
    
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, luminanceTexture);
    glUniform1i(yuvConversionLuminanceTextureUniform, 4);
    
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, chrominanceTexture);
    glUniform1i(yuvConversionChrominanceTextureUniform, 5);
    if (CMTimeCompare(time, _recordInfo.totalVideoDuraion) >= 0) {
        glUniform1i(yuvIsAnotherUniform, 5);
    }else{
        glUniform1i(yuvIsAnotherUniform, 0);
    }
    glUniformMatrix3fv(yuvConversionMatrixUniform, 1, GL_FALSE, _preferredConversion);
    
    glVertexAttribPointer(yuvConversionPositionAttribute, 2, GL_FLOAT, 0, 0, squareVertices);
    glVertexAttribPointer(yuvConversionTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}


- (void)endProcessing;
{
    for (id<GPUImageInput> currentTarget in targets)
    {
        [currentTarget endProcessing];
    }
    [self pause];
}


- (void)pause
{
    @synchronized (self) {
        _isPlaying = NO;
        [self.audioPlayer pause];
        if (self.delegate && [self.delegate respondsToSelector:@selector(videoCompositionPlayerWillPasue)]) {
            [self.delegate videoCompositionPlayerWillPasue];
        }
    }
}
- (void)clearLastPlayResourse
{
    @synchronized (self) {
        if (_playReader != nil && _playReader.status == AVAssetReaderStatusReading) {
            [_playReader cancelReading];
            _playReader = nil;
        }
    }
}
- (void)yuvConversionSetup;
{
    if ([GPUImageContext supportsFastTextureUpload])
    {
        runSynchronouslyOnVideoProcessingQueue(^{
            [GPUImageContext useImageProcessingContext];
            
            _preferredConversion = kColorConversion709;
            isFullYUVRange       = YES;
            yuvConversionProgram = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:kGPUImageYUVFullRangeConversionForLAFragmentShaderString];
            
            if (!yuvConversionProgram.initialized)
            {
                [yuvConversionProgram addAttribute:@"position"];
                [yuvConversionProgram addAttribute:@"inputTextureCoordinate"];
                
                if (![yuvConversionProgram link])
                {
                    NSString *progLog = [yuvConversionProgram programLog];
                    NSLog(@"Program link log: %@", progLog);
                    NSString *fragLog = [yuvConversionProgram fragmentShaderLog];
                    NSLog(@"Fragment shader compile log: %@", fragLog);
                    NSString *vertLog = [yuvConversionProgram vertexShaderLog];
                    NSLog(@"Vertex shader compile log: %@", vertLog);
                    yuvConversionProgram = nil;
                    NSAssert(NO, @"Filter shader link failed");
                }
            }
            
            yuvConversionPositionAttribute = [yuvConversionProgram attributeIndex:@"position"];
            yuvConversionTextureCoordinateAttribute = [yuvConversionProgram attributeIndex:@"inputTextureCoordinate"];
            yuvConversionLuminanceTextureUniform = [yuvConversionProgram uniformIndex:@"luminanceTexture"];
            yuvConversionChrominanceTextureUniform = [yuvConversionProgram uniformIndex:@"chrominanceTexture"];
            yuvConversionMatrixUniform = [yuvConversionProgram uniformIndex:@"colorConversionMatrix"];
            yuvIsAnotherUniform = [yuvConversionProgram uniformIndex:@"isAnother"];
            [GPUImageContext setActiveShaderProgram:yuvConversionProgram];
            
            glEnableVertexAttribArray(yuvConversionPositionAttribute);
            glEnableVertexAttribArray(yuvConversionTextureCoordinateAttribute);
        });
    }
}

- (void)addGPUImageFilters:(GPUImageOutput<GPUImageInput> *)filter
{
    if (_filters == nil)
    {
        _filters = [NSMutableArray array];
    }
    if (_filterGroup == nil)
    {
        _filterGroup = [[GPUImageFilterGroup alloc] init];
    }
    [_filterGroup addFilter:filter];
    [_filters addObject:filter];
    GPUImageOutput<GPUImageInput> *newTerminalFilter = filter;
    NSInteger count = _filterGroup.filterCount;
    if (count == 1)
    {
        _filterGroup.initialFilters = @[newTerminalFilter];
        _filterGroup.terminalFilter = newTerminalFilter;
        
    } else
    {
        GPUImageOutput<GPUImageInput> *terminalFilter    = _filterGroup.terminalFilter;
        NSArray *initialFilters                          = _filterGroup.initialFilters;
        [terminalFilter addTarget:newTerminalFilter];
        _filterGroup.initialFilters = @[initialFilters[0]];
        _filterGroup.terminalFilter = newTerminalFilter;
    }
}

- (UIImage *)getThumbImage
{
    @autoreleasepool {
        AVAsset *asset = self.compositon;
        NSParameterAssert(asset);
        AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
        assetImageGenerator.maximumSize = CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH);
        CGImageRef thumbnailImageRef = NULL;
        NSError *thumbnailImageGenerationError = nil;
        thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:kCMTimeZero actualTime:NULL error:&thumbnailImageGenerationError];
        if(!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
        UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
        if (thumbnailImageRef) {
            CGImageRelease(thumbnailImageRef);
        }
        return thumbnailImage;
        
    }
}


- (void)stopRecordingMovieWithCompletion:(void (^)(NSURL *))completion
{
    self.playAtActualSpeed = NO;
    _originMoiveName = [JPVideoUtil fileNameForDocumentMovie];
#if TARGET_IPHONE_SIMULATOR
//    __weak typeof(self) weakSelf = self;
//    [JPVideoUtil newMoviewUrlWithVideoUrl:self.recordInfo.videoSource.firstObject.videoUrl audioTracks:self.recordInfo.videoComposition allAudioParams:self.recordInfo.allAudioParams  completion:^(JPVideoMergeStatus status, NSURL *url) {
//        if (url != nil) {
//            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//            [library saveVideo:url toAlbum:@"新建相册" completion:^(NSURL *assetURL, NSError *error){
//                weakSelf.savedAssetUrl = assetURL;
//                completion(url);
//            }failure:^(NSError *error){
//                completion(nil);
//            }];
//        }else{
//            completion(nil);
//        }
//    }];
#else
    CGSize reallySize = _recordInfo.videoSize;
    CGSize fillSize = _recordInfo.videoSize;
    __weak typeof(self) weakSelf = self;
    
    self.originMovieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:_originMoiveName]] size:reallySize withFailureBlock:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.audioEncodingTarget = nil;
            [weakSelf removeTarget:weakSelf.originMovieWriter];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil);
            });
        });
    }];
    self.originMovieWriter.fillSize = fillSize;
    [self.filterGroup addTarget:_originMovieWriter];
    [self enableSynchronizedEncodingUsingMovieWriter:self.originMovieWriter];
    [_originMovieWriter startRecording];
    [self startPlaying];
    [_originMovieWriter setCompletionBlock:^{
        weakSelf.audioEncodingTarget = nil;
        [weakSelf.originMovieWriter finishRecording];
        [weakSelf removeTarget:weakSelf.originMovieWriter];
        [JPVideoUtil newMoviewUrlWithVideoUrl:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:weakSelf.originMoiveName]]  audioTracks:weakSelf.recordInfo.composition allAudioParams:weakSelf.recordInfo.allAudioParams  completion:^(JPVideoMergeStatus status, NSURL *url) {
            if (url != nil) {
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                [library saveVideo:url toAlbum:@"新建相册" completion:^(NSURL *assetURL, NSError *error){
                    weakSelf.savedAssetUrl = assetURL;
                    completion(url);
                }failure:^(NSError *error){
                    completion(url);
                }];
            }else{
                completion(nil);
            }
        }];
    }];
    
    [_originMovieWriter setFailureBlock:^(NSError *error) {
        completion(nil);
    }];
#endif
}

- (void)enableSynchronizedEncodingUsingMovieWriter:(GPUImageMovieWriter *)movieWriter;
{
    synchronizedMovieWriter = movieWriter;
    movieWriter.encodingLiveVideo = NO;
}

- (void)pauseToPlay
{
    if (_isCompsitiom == YES) {
        return;
    }
    _isPlaying = NO;
    CMTime currentTime = _audioPlayer.currentTime;
    [self pause];
    usleep(1000000.0 * CMTimeGetSeconds(CMTimeMake(1, 24)));
    [self scrollToWatchThumImageWithTime:CMTimeAdd(currentTime, CMTimeMake(1, 24)) withSticker:NO];
    
}


- (void)setRecordInfo:(JPBaseVideoRecordInfo *)recordInfo
{
    [self pause];
    [self clearLastPlayResourse];
    _recordInfo = recordInfo;
    _stickersFilter.videoSize = _recordInfo.videoSize;
    AVMutableComposition *newAudioComposition = _recordInfo.composition;
    [_audioMix setInputParameters:@[]];
    [_avplayerItem setAudioMix:nil];
    if (_avplayerItem) {
        [_avplayerItem removeObserver:self forKeyPath:@"status"];
    }
    if (displayLink != nil) {
        [displayLink setPaused:YES];
        [displayLink invalidate];
        displayLink = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_audioPlayer replaceCurrentItemWithPlayerItem:nil];
    _audioMix = [AVMutableAudioMix audioMix];
    [_audioMix setInputParameters:recordInfo.allAudioParams];
    
    
    if (_isCompsitiom == NO) {
        if (_avplayerItem != nil && playerItemOutput != nil && [_avplayerItem.outputs containsObject:playerItemOutput]) {
            [_avplayerItem removeOutput:playerItemOutput];
        }
        _avplayerItem = [AVPlayerItem playerItemWithAsset:newAudioComposition];
        _avplayerItem.videoComposition = _recordInfo.videoComposition;
        _avplayerItem.audioMix = _audioMix;
        [_audioPlayer replaceCurrentItemWithPlayerItem:_avplayerItem];
        _audioPlayer.muted = _audioMute;
        [self processPlayerItem];
    }
    self.compositon = newAudioComposition;
    self.videoComposition = _recordInfo.videoComposition;
    _stickersFilter.totalDuration = _recordInfo.totalVideoDuraion;
    _generalFilter.isAddVideoEnd = YES;
    _generalFilter.videoTotalDuration = _recordInfo.totalVideoDuraion;
}


- (void)setAudioMute:(BOOL)audioMute
{
    if (audioMute != _audioMute) {
        _audioMute = audioMute;
        _audioPlayer.muted = _audioMute;
    }
}

- (void)seekToTime:(CMTime)time
{
    if (_isCompsitiom == YES) {
        return;
    }
    [self scrollToWatchThumImageWithTime:time withSticker:YES];
    
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    if (notification.object == self.avplayerItem) {
        [self pause];
        [self seekToTime:kCMTimeZero];
        [self startPlaying];
    }
}

- (void)processPlayerItem
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [displayLink setPaused:YES];
#else
    // Suggested implementation: use CVDisplayLink http://stackoverflow.com/questions/14158743/alternative-of-cadisplaylink-for-mac-os-x
    CGDirectDisplayID   displayID = CGMainDisplayID();
    CVReturn            error = kCVReturnSuccess;
    error = CVDisplayLinkCreateWithCGDisplay(displayID, &displayLink);
    if (error)
    {
        NSLog(@"DisplayLink created with error:%d", error);
        displayLink = NULL;
    }
    CVDisplayLinkSetOutputCallback(displayLink, renderCallback, (__bridge void *)self);
    CVDisplayLinkStop(displayLink);
#endif
    
    [self configueOutPut];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.avplayerItem];
}

- (void)configueOutPut
{
    playerItemOutput = nil;
    NSMutableDictionary *pixBuffAttributes = [NSMutableDictionary dictionary];
    if ([GPUImageContext supportsFastTextureUpload]) {
        [pixBuffAttributes setObject:@(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    }else {
        [pixBuffAttributes setObject:@(kCVPixelFormatType_32BGRA) forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    }
    
    if (_avplayerItem.status == AVPlayerItemStatusReadyToPlay) {
        playerItemOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixBuffAttributes];
        [playerItemOutput setDelegate:self queue:_myVideoOutputQueue];
        [_avplayerItem addOutput:playerItemOutput];
        [playerItemOutput requestNotificationOfMediaDataChangeWithAdvanceInterval:0];
    }
    [_avplayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)outputMediaDataWillChange:(AVPlayerItemOutput *)sender
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    // Restart display link.
//    if (![playerItemOutput hasNewPixelBufferForItemTime:CMTimeMake(1, 10)]) {
//configueOutPut
//        NSLog(@"WillChange---error---%@",_avplayerItem.outputs);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self pauseToPlay];
//            if ([self.recordInfo isKindOfClass:[JPVideoRecordInfo class]]) {
//                [((JPVideoRecordInfo *)self.recordInfo) resetRecordAudio];
//            }
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self setRecordInfo:self.recordInfo];
//                [self startPlaying];
//            });
//        });
//    }else{
//        NSLog(@"WillChange---success---%@",_avplayerItem.outputs);
        
//    }

    
    [displayLink setPaused:NO];
#else
    CVDisplayLinkStart(displayLink);
#endif
}

- (void)displayLinkCallback:(CADisplayLink *)sender
{
    /*
     The callback gets called once every Vsync.
     Using the display link's timestamp and duration we can compute the next time the screen will be refreshed, and copy the pixel buffer for that time
     This pixel buffer can then be processed and later rendered on screen.
     */
    // Calculate the nextVsync time which is when the screen will be refreshed next.
    CFTimeInterval nextVSync = ([sender timestamp] + [sender duration]);
    
    CMTime outputItemTime = [playerItemOutput itemTimeForHostTime:nextVSync];
    [self processPixelBufferAtTime:outputItemTime];
    
}

- (void)processPixelBufferAtTime:(CMTime)outputItemTime {

    
    if ([playerItemOutput hasNewPixelBufferForItemTime:outputItemTime]) {
        __weak typeof(self) weakSelf = self;
        CVPixelBufferRef pixelBuffer = [playerItemOutput copyPixelBufferForItemTime:outputItemTime itemTimeForDisplay:NULL];
        if( pixelBuffer )
            runSynchronouslyOnVideoProcessingQueue(^{
                [weakSelf processMovieFrame:pixelBuffer withSampleTime:outputItemTime];
                CFRelease(pixelBuffer);
            });
    }
}

- (CMTime)videoDuration
{
    return _compositon.duration;
}

- (void)scrollToWatchThumImageWithTime:(CMTime)time withSticker:(BOOL)isSticker
{
    if (_isCompsitiom == YES) {
        return;
    }
    if (_isPlaying == YES) {
        return;
    }
    if (self.compositon == nil) {
        return;
    }
    _stopWithSticker = isSticker;
    self.stickersFilter.needSticker = isSticker;
    CMTime reallyTime = time;
    if (reallyTime.timescale == 0) {
        reallyTime = kCMTimeZero;
    }
    [self.audioPlayer seekToTime:reallyTime toleranceBefore:CMTimeMake(1, 30) toleranceAfter:CMTimeMake(1, 30)];
}


- (void)switchFilter
{
    [_generalFilter setFilterDelegate:_recordInfo.filterDelegate];
}

- (void)destruction
{
    if (displayLink != nil) {
        [displayLink setPaused:YES];
        [displayLink invalidate];
        displayLink = nil;
    }
    [self pause];
    [self clearLastPlayResourse];
    [self setUpdateProgressBlock:nil];
    self.delegate = nil;
    [_originMovieWriter setCompletionBlock:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_audioMix setInputParameters:@[]];
    if (_avplayerItem) {
        [_avplayerItem removeObserver:self forKeyPath:@"status"];
    }
    [_avplayerItem setAudioMix:nil];
    if (playerItemOutput != nil && [_avplayerItem.outputs containsObject:playerItemOutput]) {
        [_avplayerItem removeOutput:playerItemOutput];
        playerItemOutput = nil;
    }
    [self.audioPlayer pause];
    [self.audioPlayer replaceCurrentItemWithPlayerItem:nil];
    self.avplayerItem = nil;
    self.audioPlayer = nil;
    [self endProcessing];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_renderView removeFromSuperview];
    });
    [self removeAllTargets];
    [_filterGroup removeAllTargets];
}


- (void)levelCurrentPage
{
    if (displayLink) {
        [displayLink setPaused:YES];
        [displayLink invalidate];
        displayLink = nil;
    }
    [self clearLastPlayResourse];
    if (_avplayerItem) {
        [_avplayerItem removeObserver:self forKeyPath:@"status"];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_avplayerItem];
    self.avplayerItem = nil;
    [self.audioPlayer pause];
    self.audioPlayer = nil;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (object == self.avplayerItem && [keyPath isEqualToString:@"status"]) {
        if (playerItemOutput == nil) {
            if (self.avplayerItem.status == AVPlayerItemStatusReadyToPlay) {
                NSMutableDictionary *pixBuffAttributes = [NSMutableDictionary dictionary];
                if ([GPUImageContext supportsFastTextureUpload]) {
                    [pixBuffAttributes setObject:@(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) forKey:(id)kCVPixelBufferPixelFormatTypeKey];
                }else {
                    [pixBuffAttributes setObject:@(kCVPixelFormatType_32BGRA) forKey:(id)kCVPixelBufferPixelFormatTypeKey];
                }
                playerItemOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixBuffAttributes];
                [playerItemOutput setDelegate:self queue:_myVideoOutputQueue];
                [_avplayerItem addOutput:playerItemOutput];
                [playerItemOutput requestNotificationOfMediaDataChangeWithAdvanceInterval:0];
                if (_isPlaying == YES) {
                    [self startPlaying];
                }
            }
        }
    }
}

- (void)returnCurrentPage
{
    self.audioPlayer = [[AVPlayer alloc] init];
}

- (void)dealloc
{
    
}
@end
