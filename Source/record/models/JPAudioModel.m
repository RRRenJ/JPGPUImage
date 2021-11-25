//
//  JPAudioModel.m
//  jper
//
//  Created by 藩 亜玲 on 2017/4/18.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#import "JPAudioModel.h"
#import "JPVideoUtil.h"
#import "JPPublicConstant.h"
@implementation JPAudioModel

- (id)init {
    self = [super init];
    if (self) {
        _theme = @"NONE";
        _durationTime = kCMTimeZero;
    }
    return self;
}

//@property (nonatomic, assign) CMTime durationTime;
//@property (nonatomic, assign) CMTime startTime;
//@property (nonatomic, assign) CMTimeRange clipTimeRange;
//@property (nonatomic, strong) NSURL *fileUrl;
//@property (nonatomic) JPAudioSourceType sourceType;
//@property (nonatomic, strong) NSString *fileName;
//@property (nonatomic, strong) UIImage *thumImg;
//@property (nonatomic, strong) NSString *theme;
//@property (nonatomic, assign) BOOL isNone;
//@property (nonatomic, assign) NSInteger selectIndex;

- (NSURL *)fileUrl
{
    if (_absoluteLocalPath) {
        return [NSURL fileURLWithPath:_absoluteLocalPath];
    }
    if (_baseFilePath) {
        if (_isBundle) {
            return [NSURL fileURLWithPath:[[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:_baseFilePath]];
        }else{
            return [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:_baseFilePath]];
        }
    }else{
        return nil;
    }
}


- (id)copyWithZone:(NSZone *)zone
{
    JPAudioModel *model = [[JPAudioModel alloc] init];
    model.durationTime = self.durationTime;
    model.startTime = self.startTime;
    model.clipTimeRange = self.clipTimeRange;
    model.isBundle = self.isBundle;
    model.absoluteLocalPath = self.absoluteLocalPath;
    model.baseFilePath = self.baseFilePath;
    model.sourceType = self.sourceType;
    model.theme = self.theme;
    model.isITunes = self.isITunes;
    model.selectIndex = self.selectIndex;
    model.fileName = self.fileName;
    model.resource_id = self.resource_id;
    model.volume = self.volume;
    model.fileNameWidth = self.fileNameWidth;
    return model;
}

- (UIImage *)selectedThumImg
{
    return [UIImage imageNamed:_selectedThumImgName inBundle:JP_Resource_bundle compatibleWithTraitCollection:nil];
}

- (UIImage *)unSelectedThumImg
{
    return [UIImage imageNamed:_selectedThumImgName inBundle:JP_Resource_bundle compatibleWithTraitCollection:nil];
}

//+ (NSArray<JPAudioModel *> *)loadAllLocalMusic
//{
//    NSMutableArray<JPAudioModel *> *dataArr = [NSMutableArray array];
//    for (NSInteger index = 0; index < 30; index ++) {
//        JPAudioModel *model = [[JPAudioModel alloc] init];
//        model.selectIndex = index;
//        model.volume = 0.5;
//        model.sourceType = JPAudioSourceTypeLocal;
//        switch (index) {
//            case 0:
//                model.isITunes = YES;
//                model.fileName = @"";
//                model.theme = @"";
//                model.selectedThumImgName = @"itunes";
//                model.unSelectedThumImgName = @"itunes";
//                break;
//            case 1:
//                model.fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"water" ofType:@"aac"]];
//                model.fileName = @"water";
//                model.durationTime = [JPVideoUtil getVideoDurationWithSourcePath:model.fileUrl];
//                model.theme = @"WATER";
//                model.selectedThumImgName = @"01water";
//                break;
//            case 2:
//                model.fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Summer" ofType:@"aac"]];
//                model.fileName = @"summer";
//                model.durationTime = [JPVideoUtil getVideoDurationWithSourcePath:model.fileUrl];
//                model.theme = @"SUMMER";
//                model.selectedThumImgName = @"02Summer";
//                break;
//            case 3:
//                model.fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Birthday" ofType:@"aac"]];
//                model.fileName = @"birthday";
//                model.durationTime = [JPVideoUtil getVideoDurationWithSourcePath:model.fileUrl];
//                model.theme = @"BIRTHDAY";
//                model.selectedThumImgName = @"03birthday";
//                break;
//            case 4:
//                model.fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"James" ofType:@"aac"]];
//                model.fileName = @"james";
//                model.durationTime = [JPVideoUtil getVideoDurationWithSourcePath:model.fileUrl];
//                model.theme = @"JAMES";
//                model.selectedThumImgName = @"04game";
//                break;
//            case 5:
//                model.fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"future" ofType:@"aac"]];
//                model.fileName = @"future";
//                model.durationTime = [JPVideoUtil getVideoDurationWithSourcePath:model.fileUrl];
//                model.theme = @"FUTURE";
//                model.selectedThumImgName = @"05future";
//                break;
//            case 6:
//                model.fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"country" ofType:@"aac"]];
//                model.fileName = @"country";
//                model.durationTime = [JPVideoUtil getVideoDurationWithSourcePath:model.fileUrl];
//                model.theme = @"COUNTRY";
//                model.selectedThumImgName = @"06country";
//                break;
//            case 7:
//                model.fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"stars" ofType:@"aac"]];
//                model.fileName = @"stars";
//                model.durationTime = [JPVideoUtil getVideoDurationWithSourcePath:model.fileUrl];
//                model.theme = @"STARS";
//                model.selectedThumImgName = @"07Stars";
//                break;
//            case 8:
//                model.fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"edit" ofType:@"aac"]];
//                model.fileName = @"edit";
//                model.durationTime = [JPVideoUtil getVideoDurationWithSourcePath:model.fileUrl];
//                model.theme = @"EDIT";
//                model.selectedThumImgName = @"08edit";
//                break;
//            case 9:
//                model.fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"world" ofType:@"aac"]];
//                model.fileName = @"world";
//                model.durationTime = [JPVideoUtil getVideoDurationWithSourcePath:model.fileUrl];
//                model.theme = @"WORLD";
//                model.selectedThumImgName = @"09world";
//                break;
//            case 10:
//                model.fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sorrowwful" ofType:@"aac"]];
//                model.fileName = @"sorrowful";
//                model.durationTime = [JPVideoUtil getVideoDurationWithSourcePath:model.fileUrl];
//                model.theme = @"SORROWFUL";
//                model.selectedThumImgName = @"10Sorrowful";
//                break;
//            case 11:
//                model.fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Childhood" ofType:@"aac"]];
//                model.fileName = @"childhood";
//                model.durationTime = [JPVideoUtil getVideoDurationWithSourcePath:model.fileUrl];
//                model.theme = @"CHILDHOOD";
//                model.selectedThumImgName = @"11Childhood";
//                break;
//            case 12:
//                model.fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"the passes" ofType:@"aac"]];
//                model.fileName = @"the-passes";
//                model.durationTime = [JPVideoUtil getVideoDurationWithSourcePath:model.fileUrl];
//                model.theme = @"TIME PASSES";
//                model.selectedThumImgName = @"12Time-passes";
//                break;
//            case 13:
//                model.fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Smile" ofType:@"aac"]];
//                model.fileName = @"smile";
//                model.durationTime = [JPVideoUtil getVideoDurationWithSourcePath:model.fileUrl];
//                model.theme = @"SMILE";
//                model.selectedThumImgName = @"13smile";
//                break;
//            case 14:
//                model.fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"fresh" ofType:@"aac"]];
//                model.fileName = @"fresh";
//                model.durationTime = [JPVideoUtil getVideoDurationWithSourcePath:model.fileUrl];
//                model.theme = @"FRESH";
//                model.selectedThumImgName = @"14fresh";
//                break;
//            case 15:
//                model.fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Moment" ofType:@"aac"]];
//                model.fileName = @"moment";
//                model.durationTime = [JPVideoUtil getVideoDurationWithSourcePath:model.fileUrl];
//                model.theme = @"MOMENT";
//                model.selectedThumImgName = @"15Moment";
//                break;
//            case 16:
//                model.fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"light" ofType:@"aac"]];
//                model.fileName = @"light";
//                model.durationTime = [JPVideoUtil getVideoDurationWithSourcePath:model.fileUrl];
//                model.theme = @"LIGHT";
//                model.selectedThumImgName = @"16light";
//                break;
//            case 17:
//                model.fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"pink" ofType:@"aac"]];
//                model.fileName = @"pink";
//                model.durationTime = [JPVideoUtil getVideoDurationWithSourcePath:model.fileUrl];
//                model.theme = @"PINK";
//                model.selectedThumImgName = @"17pink";
//                break;
//            case 18:
//                model.fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"metal" ofType:@"aac"]];
//                model.fileName = @"metal";
//                model.durationTime = [JPVideoUtil getVideoDurationWithSourcePath:model.fileUrl];
//                model.theme = @"METAL";
//                model.selectedThumImgName = @"18Metal";
//                break;
//            case 19:
//                model.fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Modern" ofType:@"aac"]];
//                model.fileName = @"modern";
//                model.durationTime = [JPVideoUtil getVideoDurationWithSourcePath:model.fileUrl];
//                model.theme = @"MODERN";
//                model.selectedThumImgName = @"19Modern";
//                break;
//            case 20:
//                model.fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Unite" ofType:@"aac"]];
//                model.fileName = @"unite";
//                model.durationTime = [JPVideoUtil getVideoDurationWithSourcePath:model.fileUrl];
//                model.theme = @"UNITE";
//                model.selectedThumImgName = @"20Unite";
//                break;
//            case 21:
//                model.fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Happy" ofType:@"aac"]];
//                model.fileName = @"happy";
//                model.durationTime = [JPVideoUtil getVideoDurationWithSourcePath:model.fileUrl];
//                model.theme = @"HAPPY";
//                model.selectedThumImgName = @"21happy";
//                break;
//            case 22:
//                model.fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"piano01" ofType:@"aac"]];
//                model.fileName = @"piano01";
//                model.durationTime = [JPVideoUtil getVideoDurationWithSourcePath:model.fileUrl];
//                model.theme = @"PIANO01";
//                model.selectedThumImgName = @"piano";
//                break;
//            case 23:
//                model.fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"piano02" ofType:@"aac"]];
//                model.fileName = @"piano02";
//                model.durationTime = [JPVideoUtil getVideoDurationWithSourcePath:model.fileUrl];
//                model.theme = @"PIANO02";
//                model.selectedThumImgName = @"piano";
//                break;
//            case 24:
//                model.fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"cello" ofType:@"aac"]];
//                model.fileName = @"cello";
//                model.durationTime = [JPVideoUtil getVideoDurationWithSourcePath:model.fileUrl];
//                model.theme = @"CELLO";
//                model.selectedThumImgName = @"Cello";
//                break;
//            case 25:
//                model.fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Electronics" ofType:@"aac"]];
//                model.fileName = @"electronics";
//                model.durationTime = [JPVideoUtil getVideoDurationWithSourcePath:model.fileUrl];
//                model.theme = @"ELECTRONICS";
//                model.selectedThumImgName = @"Electronics";
//                break;
//            case 26:
//                model.fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"pop01" ofType:@"aac"]];
//                model.fileName = @"pop01";
//                model.durationTime = [JPVideoUtil getVideoDurationWithSourcePath:model.fileUrl];
//                model.theme = @"POP01";
//                model.selectedThumImgName = @"pop";
//                break;
//            case 27:
//                model.fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"rock01" ofType:@"aac"]];
//                model.fileName = @"rock01";
//                model.durationTime = [JPVideoUtil getVideoDurationWithSourcePath:model.fileUrl];
//                model.theme = @"ROCK01";
//                model.selectedThumImgName = @"rock";
//                break;
//            case 28:
//                model.fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Ukulele01" ofType:@"aac"]];
//                model.fileName = @"ukulele01";
//                model.durationTime = [JPVideoUtil getVideoDurationWithSourcePath:model.fileUrl];
//                model.theme = @"UKULELE01";
//                model.selectedThumImgName = @"ukulele01";
//                break;
//            case 29:
//                model.fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"ukulele02" ofType:@"aac"]];
//                model.fileName = @"ukulele02";
//                model.durationTime = [JPVideoUtil getVideoDurationWithSourcePath:model.fileUrl];
//                model.theme = @"UKULELE02";
//                model.selectedThumImgName = @"ukulele02";
//                break;
//            default:
//                break;
//        }
//
//        [dataArr addObject:model];
//    }
//    return dataArr;
//}

- (void)dealloc
{
    
}


- (NSMutableDictionary *)configueDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSString *durationTime = [NSString stringWithFormat:@"%lld,%d", _durationTime.value, _durationTime.timescale];
    [dict setObject:durationTime forKey:@"durationTime"];
    NSString *startTime = [NSString stringWithFormat:@"%lld,%d", _startTime.value, _startTime.timescale];
    [dict setObject:startTime forKey:@"startTime"];
    NSString *clipTimeRange = [NSString stringWithFormat:@"%lld,%d,%lld,%d", _clipTimeRange.start.value, _clipTimeRange.start.timescale, _clipTimeRange.duration.value,_clipTimeRange.duration.timescale];
    [dict setObject:clipTimeRange forKey:@"clipTimeRange"];
    if (_baseFilePath) {
        [dict setObject:_baseFilePath forKey:@"baseFilePath"];
    }
    if (_absoluteLocalPath) {
        [dict setObject:_absoluteLocalPath forKey:@"absoluteLocalPath"];
    }
    [dict setObject:@(_isBundle) forKey:@"isBundle"];
    [dict setObject:@(_sourceType) forKey:@"sourceType"];
    if (_fileName) {
        [dict setObject:_fileName forKey:@"fileName"];
    }
    if (_resource_id) {
        [dict setObject:_resource_id forKey:@"resource_id"];
    }
    if (_selectedThumImgName) {
        [dict setObject:_selectedThumImgName forKey:@"selectedThumImgName"];
    }
    if (_unSelectedThumImgName) {
        [dict setObject:_unSelectedThumImgName forKey:@"unSelectedThumImgName"];
    }
    [dict setObject:@(_isITunes) forKey:@"isITunes"];
    [dict setObject:@(_selectIndex) forKey:@"selectIndex"];
    [dict setObject:@(_fileNameWidth) forKey:@"fileNameWidth"];
    [dict setObject:@(_volume) forKey:@"volume"];
    if (_theme) {
        [dict setObject:_theme forKey:@"theme"];
    }
    return dict;
}

- (void)updateInfoWithDict:(NSDictionary *)dict
{
    NSString *durationTime = [dict objectForKey:@"durationTime"];
    if (durationTime) {
        NSArray *times = [durationTime componentsSeparatedByString:@","];
        _durationTime = CMTimeMake([times.firstObject longLongValue], [times.lastObject intValue]);
    }
    NSString *startTime = [dict objectForKey:@"startTime"];
    if (startTime) {
        NSArray *times = [startTime componentsSeparatedByString:@","];
        _startTime = CMTimeMake([times.firstObject longLongValue], [times.lastObject intValue]);
    }
    NSString *clipTimeRange = [dict objectForKey:@"clipTimeRange"];
    if (clipTimeRange) {
        NSArray *clipTimeRanges = [clipTimeRange componentsSeparatedByString:@","];
        if (clipTimeRanges.count == 4) {
            _clipTimeRange = CMTimeRangeMake(CMTimeMake([clipTimeRanges[0] longLongValue], [clipTimeRanges[1] intValue]), CMTimeMake([clipTimeRanges[2] longLongValue], [clipTimeRanges[3] intValue]));
        }
    }
    _absoluteLocalPath = [dict objectForKey:@"absoluteLocalPath"];
    _baseFilePath = [dict objectForKey:@"baseFilePath"];
    _isBundle = [[dict objectForKey:@"isBundle"] boolValue];
    _sourceType = [[dict objectForKey:@"sourceType"] integerValue];
    _fileName = [dict objectForKey:@"fileName"];
    _resource_id = [dict objectForKey:@"resource_id"];
    _selectedThumImgName = [dict objectForKey:@"selectedThumImgName"];
    _unSelectedThumImgName = [dict objectForKey:@"unSelectedThumImgName"];
    _isITunes = [[dict objectForKey:@"isITunes"] boolValue];
    _selectIndex = [[dict objectForKey:@"selectIndex"] integerValue];
    _fileNameWidth = [[dict objectForKey:@"fileNameWidth"] floatValue];
    _volume = [[dict objectForKey:@"volume"] floatValue];
    _theme = [dict objectForKey:@"theme"];
}
@end
