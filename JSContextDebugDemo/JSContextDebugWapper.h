//
//  JSContextDebugWapper.h
//  JSContextDebugDemo
//
//  Created by arlin on 2017/6/3.
//  Copyright © 2017年 dps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSContextDebugWapper : NSObject

+ (void)hookCMethods;

+ (void)testUsingMultipleBlocks;
+ (void)testUsingSameBlock;
+ (void)testUsingSameObject;
+ (void)testSimpleJSContext;

@end
