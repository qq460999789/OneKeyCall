//
// Copyright 2009-2010 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

//#import "Three20UI.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NSString (ITTAdditions)

- (NSInteger)numberOfLinesWithFont:(UIFont*)font
										 withLineWidth:(NSInteger)lineWidth{
  CGSize size = [self sizeWithFont:font
								 constrainedToSize:CGSizeMake(lineWidth, CGFLOAT_MAX)
										 lineBreakMode:UILineBreakModeTailTruncation];
	NSInteger lines = size.height / font.lineHeight;
	return lines;
}
- (CGFloat)heightWithFont:(UIFont*)font
						withLineWidth:(NSInteger)lineWidth{
  CGSize size = [self sizeWithFont:font
								 constrainedToSize:CGSizeMake(lineWidth, CGFLOAT_MAX)
										 lineBreakMode:UILineBreakModeTailTruncation];
	return size.height;
	
}

- (NSString *)md5{
	const char *concat_str = [self UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(concat_str, strlen(concat_str), result);
	NSMutableString *hash = [NSMutableString string];
	for (int i = 0; i < 16; i++){
		[hash appendFormat:@"%02X", result[i]];
	}
	return [hash lowercaseString];
	
}
+ (NSString *) showNsstrig:(NSString *) orgValue defaultNsstring:(NSString *) defaultValue{
    
    
    if (!defaultValue) {
        
        defaultValue = @"未知";
    }
    
    if ([orgValue isKindOfClass:[NSNull class ]] ) {
        return defaultValue;
    }
    if (!orgValue||[orgValue isEqualToString:@""]) {
        return defaultValue;
    }
    
    return orgValue;
}
- (NSString *)URLEncodedString
{
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)self,
                                                                           NULL,
																		   CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                           kCFStringEncodingUTF8);
    [result autorelease];
	return result;
}

- (NSString*)URLDecodedString
{
	NSString *result = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
																						   (CFStringRef)self,
																						   CFSTR(""),
																						   kCFStringEncodingUTF8);
    [result autorelease];
	return result;
}

/**
	得到中英文混合字符串长度
	@param strtemp 英文混合字符串
	@returns 长度
 */
+ (int)getENCNLength:(NSString*)strtemp
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData* da = [strtemp dataUsingEncoding:enc];
    return [da length];
}

@end

