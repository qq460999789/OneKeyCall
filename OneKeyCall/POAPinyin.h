//
//  POAPinyin.h
//  POA
//
//  Created by haung he on 11-7-18.
//  Copyright 2011年 huanghe. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface POAPinyin : NSObject {
    
}

+ (NSString *) convert:(NSString *) hzString;//输入中文，返回拼音。

//  added by setimouse ( setimouse@gmail.com )
+ (NSString *)quickConvert:(NSString *)hzString;//默认返回拼音转换为全大写
+ (NSString *)quickConvert:(NSString *)hzString uppercase:(BOOL)uppercase;//是否传转换大写
+ (void)clearCache;
//  ------------------

@end
