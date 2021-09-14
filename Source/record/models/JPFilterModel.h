//
//  JPFilterModel.h
//  jper
//
//  Created by FoundaoTEST on 2017/3/24.
//  Copyright © 2017年 MuXiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface JPFilterModel : NSObject
@property (nonatomic, strong) NSString *thumbImageName;
@property (nonatomic) NSInteger filterType;
@property (nonatomic, strong) NSString *filterName;
@property (nonatomic, strong) NSString *filterNumberString;
@property (nonatomic, strong) NSString *filterCNName;


- (UIImage *)thumbImage;
- (NSMutableDictionary *)configueDict;
- (void)updateInfoWithDict:(NSDictionary *)dict;

@end
