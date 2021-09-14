//
//  JPBaseVideoRecordInfo.m
//  GPUImage
//
//  Created by FoundaoTEST on 2017/10/17.
//  Copyright © 2017年 Brad Larson. All rights reserved.
//

#import "JPBaseVideoRecordInfo.h"

@implementation JPBaseVideoRecordInfo

- (instancetype)initWithFilterManager:(id<JPVideoRecordInfoFilterManager>)manager
{
    if (self = [self init])
    {
        _currentFilterType = -1;
        _filterManager = manager;
        self.currentFilterType = 0;
        _recordId = @([[NSDate date] timeIntervalSince1970]).stringValue;
        _localType = @"1";
    }
    return self;
}

- (void)setCurrentFilterType:(NSInteger)currentFilterType
{
    if (currentFilterType != _currentFilterType) {
        _currentFilterType = currentFilterType;
        _filterDelegate = [_filterManager filterManagerGeneralImageFilterDelegeteWithFilterType:currentFilterType];
    }
}


- (CGSize)videoSize
{
    switch (_aspectRatio) {
        case JPVideoAspectRatio1X1:
            return  CGSizeMake(1080, 1080);
            break;
        case JPVideoAspectRatio16X9:
            return CGSizeMake(1920, 1080);
            break;
        case JPVideoAspectRatio9X16:
            return CGSizeMake(1080, 1920);
            break;
        case JPVideoAspectRatio4X3:
            return CGSizeMake(1440, 1080);
            break;
        case JPVideoAspectRatioCircular:
            return CGSizeMake(1080, 1080);
            break;
        default:
            break;
    }
    return CGSizeZero;
}

- (JPBaseCompositionPlayer *)getCompositionPlayer
{
    return nil;
}
- (void)becomeOrigin
{
    NSLog(@"自己实现");
}


- (NSMutableDictionary *)configueDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.localPath) {
        [dict setObject:self.localPath forKey:@"localPath"];
    }
    if (self.onlineURL) {
        [dict setObject:self.onlineURL forKey:@"onlineURL"];
    }
    [dict setObject:self.recordId forKey:@"recordId"];
    [dict setObject:self.localType forKey:@"localType"];
    [dict setObject:@(self.currentFilterType) forKey:@"currentFilterType"];
    [dict setObject:@(self.aspectRatio) forKey:@"aspectRatio"];
    if (self.saveDate) {
        [dict setObject:self.saveDate forKey:@"saveDate"];
    }
    return dict;
}

- (void)updateInfoWithDict:(NSDictionary *)dict
{
    self.localPath = [dict objectForKey:@"localPath"];
    self.onlineURL = [dict objectForKey:@"onlineURL"];
    self.recordId = [dict objectForKey:@"recordId"];
    self.localType = [dict objectForKey:@"localType"];
    if (!self.localType) {
        self.localType = @"1";
    }
    self.currentFilterType = [[dict objectForKey:@"currentFilterType"] integerValue];
    self.aspectRatio = [[dict objectForKey:@"aspectRatio"] integerValue];
    self.saveDate = [dict objectForKey:@"saveDate"];
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }else if ([object isKindOfClass:[self class]])
    {
        JPBaseVideoRecordInfo *recordInfo = (JPBaseVideoRecordInfo *)object;
        if ([recordInfo.recordId isEqualToString:self.recordId]) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return NO;
    }
}

- (NSUInteger)hash
{
    return [_recordId integerValue];
}

@end
