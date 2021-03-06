//
//  DesignerServiceApi.m
//  jiaModuleDemo
//
//  Created by wujunyang on 16/9/21.
//  Copyright © 2016年 wujunyang. All rights reserved.
//

#import "DesignerServiceApi.h"

@implementation DesignerServiceApi

- (NSString *)requestUrl {
    return [NSString stringWithFormat:@"%@%@",[jiaDesignerConfigManager sharedInstance].prefixNetWorkUrl,@"projects/1/replenishment-documents"];
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodGet;
}

@end
