//
//  Singleton.m
//  FoundationTest
//
//  Created by swhl on 13-7-2.
//  Copyright (c) 2013年 swhl. All rights reserved.
//

#import "Singleton.h"


@implementation Singleton

//已创建的实例集合
static NSMutableDictionary *instanceDic;

+ (id)getInstance:(Class)className {
    @synchronized(self) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            //初始化实例集合字典
            instanceDic = [[NSMutableDictionary alloc]initWithCapacity:0];
        });
        
        //字典中取当前要创建的实例
        id instance = instanceDic[NSStringFromClass(className)];
        
        if(!instance){
            //如果实例不存在 创建一个新的
            instance= [[className alloc]  init];
            //新的实例放入字典中
            instanceDic[NSStringFromClass(className)] = instance;
        }
               
        return instance;
    }
}

@end
