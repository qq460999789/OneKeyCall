//
//  ComMethod.h
//  BoyGirlMatch
//
//  Created by korea32008 on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ComMethod : NSObject

+(UINavigationBar *) createNavigateBarWithBackgroundImage:(UIImage *) backgroundImage title:(NSString *)nstitle;

//打开沙盒目录
+(NSString *) getDocumentPath;
//存储UIimage
+(BOOL)writeUIImage:(UIImage*)image toFileAtPath:(NSString*)aPath;

//判断是否有效
+ (BOOL)isValidKey:(NSString*)key;

+(BOOL)isValidateEmail:(NSString *)email;

//验证字符和中文
+(BOOL)isValidateCHAndChar:(NSString *)string;
//验证字符和数字
+(BOOL)isValidateNumberAndChar:(NSString *)string;
//验证字符和数字 还有（- _）
+(BOOL)isValidateNumberAndChar2:(NSString *)string;
//验证手机号
+(BOOL)isValidateMobile:(NSString *)mobile;
//获得正确的号码
+(NSString *)getRealMobileNum:(NSString *)mobileNum;

//正则验证字符串是否符合规则
+(BOOL)isValidate:(NSString *)string regex:(NSString*)stringRegex;
+(BOOL)isMobileNumber:(NSString *)mobileNum;
    



/**
 线程睡眠
 */
+(void) sleep;

@end
