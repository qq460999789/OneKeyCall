//
//  ComMethod.m
//  BoyGirlMatch
//
//  Created by korea32008 on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ComMethod.h"


@implementation ComMethod

+(UINavigationBar *) createNavigateBarWithBackgroundImage:(UIImage *) backgroundImage title:(NSString *)nstitle{
    UINavigationBar *customNavigationBar = [[[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 49)] autorelease];
    UIImageView *navigationBarBackgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    [customNavigationBar addSubview:navigationBarBackgroundImageView];
    UINavigationItem *navigationTitle = [[UINavigationItem alloc] initWithTitle:nstitle];
    [customNavigationBar pushNavigationItem:navigationTitle animated:NO];
    [navigationTitle release];
    [navigationBarBackgroundImageView release];
    
    return customNavigationBar;
}

+(NSString *) getDocumentPath{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return documentPath;

}

+(BOOL)writeUIImage:(UIImage*)image toFileAtPath:(NSString*)aPath{
    
    if ((image == nil) || (aPath == nil) || ([aPath isEqualToString:@""]))        
        return NO;
    
    @try{
        
        NSData *imageData = nil;
        NSString *ext = [aPath pathExtension];
        
        if ([ext isEqualToString:@"png"]){
            imageData = UIImagePNGRepresentation(image);
        }else{
            imageData = UIImageJPEGRepresentation(image, 0);
        }
        
        if ((imageData == nil) || ([imageData length] <= 0))
            return NO;
        
        [imageData writeToFile:aPath atomically:YES];
        
        return YES;
        
    }
    
    @catch (NSException *e) 
    
    {
        
        NSLog(@"create thumbnail exception.");
        
    }
    
    return NO;
    
}

+ (BOOL)isValidKey:(NSString*)key{
    if (!key || [key length] == 0 || (NSNull*)key == [NSNull null]) {
        return NO;
    }
    return YES;
}

//验证字符和中文
+(BOOL)isValidateCHAndChar:(NSString *)string {
    NSString *stringRegex = @"^[\u4E00-\u9FA5A-Za-z]+$";
    return [ComMethod isValidate:string regex:stringRegex];
}

+(BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

//验证字符和数字
+(BOOL)isValidateNumberAndChar:(NSString *)string {
    //只能输入英文和数字
    NSString *stringRegex = @"^[A-Za-z0-9]+$";
    return [ComMethod isValidate:string regex:stringRegex];
}

//验证字符和数字 还有（- _）
+(BOOL)isValidateNumberAndChar2:(NSString *)string {
    //只能输入英文和数字还有（- _）
    NSString *stringRegex = @"^[A-Za-z0-9-_]+$";
    return [ComMethod isValidate:string regex:stringRegex];
}

//手机号码验证 
+(BOOL) isValidateMobile:(NSString *)mobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    return [ComMethod isValidate:mobile regex:phoneRegex];

}

//正则验证字符串是否符合规则
+(BOOL)isValidate:(NSString *)string regex:(NSString*)stringRegex{
    NSPredicate *stringTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stringRegex];
    return [stringTest evaluateWithObject:string];
}

+(NSString *)getRealMobileNum:(NSString *)mobileNum{

    NSMutableString *newMobileNum = [NSMutableString stringWithString:mobileNum];
    NSRange range = NSMakeRange(0, newMobileNum.length-1);

    int number = 0;
    number = [newMobileNum replaceOccurrencesOfString:@"~" withString:@"" options:NSCaseInsensitiveSearch range:range];
    range.length -= number;

    number =[newMobileNum replaceOccurrencesOfString:@"*" withString:@"" options:NSCaseInsensitiveSearch range:range];
    range.length -= number;
    number =[newMobileNum replaceOccurrencesOfString:@"," withString:@"" options:NSCaseInsensitiveSearch range:range];
    range.length -= number;
    number = [newMobileNum replaceOccurrencesOfString:@"#" withString:@"" options:NSCaseInsensitiveSearch range:range];
    range.length -= number;
    
    number = [newMobileNum replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:range];
    range.length -= number;
    
    number = [newMobileNum replaceOccurrencesOfString:@"-" withString:@"" options:NSCaseInsensitiveSearch range:range];
    range.length -= number;
    
    number = [newMobileNum replaceOccurrencesOfString:@"_" withString:@"" options:NSCaseInsensitiveSearch range:range];

    mobileNum = [NSString stringWithString:newMobileNum];



    return mobileNum;
}



+ (BOOL)isMobileNumber:(NSString *)mobileNum
{

     NSString *ALL = @"^(((\\+86)?13[0-9])|((86)?13[0-9])|((\\+86)?15[^4,\\D])|((86)?15[^4,\\D])|((\\+86)?18[0,0-9])|((86)?18[0,0-9]))\\d{8}$";
    //NSString * ALL = @"^(0[0-9]{2,3}(\\-)?)?([2-9][0-9]{6,7})+(\\-[0-9]{1,4})?$";//固话
    //NSString * ALL = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";//手机号码匹配

        NSPredicate *regextestmobileAll = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", ALL];

    if ([regextestmobileAll evaluateWithObject:mobileNum] == YES)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

/**
    线程睡眠
 */
+(void) sleep{
    [[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
    //    [NSThread sleepForTimeInterval:0.01];
};
@end
