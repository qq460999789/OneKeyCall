//
//  Singleton.h
//  FoundationTest
//
//  Created by swhl on 13-7-2.
//  Copyright (c) 2013年 swhl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Singleton : NSObject

+ (id)getInstance:(Class)className;

@end
