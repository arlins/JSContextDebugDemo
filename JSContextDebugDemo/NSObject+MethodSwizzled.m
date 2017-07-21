//
//  NSObject+MethodSwizzled.m
//  JSContextDebugDemo
//
//  Created by arlin on 2017/6/3.
//  Copyright © 2017年 dps. All rights reserved.
//

#import "NSObject+MethodSwizzled.h"
#import <objc/runtime.h>

@implementation NSObject (MethodSwizzled)

+ (void)methodSwizzled:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector;
{
    Class cls = [self class];
    
    Method originalMethod = class_getInstanceMethod(cls, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
    
    BOOL didAddMethod1 = class_addMethod(cls,
                                         originalSelector,
                                         method_getImplementation(swizzledMethod),
                                         method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod1)
    {
        class_replaceMethod(cls,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    }
    else
    {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
