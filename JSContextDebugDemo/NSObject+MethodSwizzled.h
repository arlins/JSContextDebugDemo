//
//  NSObject+MethodSwizzled.h
//  JSContextDebugDemo
//
//  Created by arlin on 2017/6/3.
//  Copyright © 2017年 dps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MethodSwizzled)

+ (void)methodSwizzled:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector;

@end
