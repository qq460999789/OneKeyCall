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

@interface NSString (ITTAdditions)

- (NSInteger)numberOfLinesWithFont:(UIFont*)font
                     withLineWidth:(NSInteger)lineWidth;
- (CGFloat)heightWithFont:(UIFont*)font
            withLineWidth:(NSInteger)lineWidth;
- (NSString *)md5;
- (NSString *)URLEncodedString;
- (NSString *)URLDecodedString;


+ (NSString *) showNsstrig:(NSString *) orgValue defaultNsstring:(NSString *) defaultValue;

/**
	分词使用
	@returns 分词后的数组
 */
- (NSArray *)arrayWithWordTokenize;

/**
	分词使用
	@param separator分割符
	@returns 分词后做成separator分割的字符串
 */
- (NSString *)separatedStringWithSeparator:(NSString *)separator;
/**
 得到中英文混合字符串长度
 @param strtemp 英文混合字符串
 @returns 长度
 */
+ (int)getENCNLength:(NSString*)strtemp;

@end

