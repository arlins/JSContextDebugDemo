//
//  JSContextDebugWapper.m
//  JSContextDebugDemo
//
//  Created by arlin on 2017/6/3.
//  Copyright © 2017年 dps. All rights reserved.
//

#import "JSContextDebugWapper.h"
#import "NSObject+MethodSwizzled.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <objc/runtime.h>
#import "fishhook.h"

typedef JSValue *(^JSMethodWithArg0)(void);
typedef JSValue *(^JSMethodWithArg1)(JSValue *value0);
typedef JSValue *(^JSMethodWithArg2)(JSValue *value0, JSValue *value1);
typedef JSValue *(^JSMethodWithArg3)(JSValue *value0, JSValue *value1, JSValue *value2);
typedef JSValue *(^JSMethodWithArg4)(JSValue *value0, JSValue *value1, JSValue *value2, JSValue *value3);

#define MakeMeBecomeStackBlock {self;}

//#define ThreadCallStackSymbols_Enable

#ifdef ThreadCallStackSymbols_Enable
    #define ThreadCallStackSymbols {NSLog(@"%@", [NSThread callStackSymbols]);};
#else
    #define ThreadCallStackSymbols {do{}while(0);}
#endif


/** C Methods Hook. **/

static void* (*Old_Block_copy)(const void *aBlock);

void *New_Block_copy(const void *aBlock)
{
    void * block_copy = Old_Block_copy( aBlock );
    
    return block_copy;
}

static NSMapTable *s_valueMapTable = nil;

#pragma mark - JSContextDefineClass

@interface JSContextDefineClass : NSObject

- (void)defineJSContext:(JSContext *)context;

@end

@implementation JSContextDefineClass

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        {
            SEL originalSelector = NSSelectorFromString(@"retain");
            SEL swizzledSelector = NSSelectorFromString(@"hook_retain");
            [[self class] methodSwizzled:originalSelector swizzledSelector:swizzledSelector];
        }
        
        {
            SEL originalSelector = NSSelectorFromString(@"release");
            SEL swizzledSelector = NSSelectorFromString(@"hook_release");
            [[self class] methodSwizzled:originalSelector swizzledSelector:swizzledSelector];
        }
        
        {
            SEL originalSelector = NSSelectorFromString(@"retainCount");
            SEL swizzledSelector = NSSelectorFromString(@"hook_retainCount");
            [[self class] methodSwizzled:originalSelector swizzledSelector:swizzledSelector];
        }
    });
}

- (void)defineJSContext:(JSContext *)context
{
    context[@"delete1"] = ^(JSValue *num1, JSValue* num2){
        int res = [num1 toInt32]  - [num2 toInt32];
        
        MakeMeBecomeStackBlock;
        
        return [JSValue valueWithInt32:res inContext:[JSContext currentContext]];
    };
    
    context[@"delete2"] = ^(JSValue *num1, JSValue* num2){
        int res = [num1 toInt32]  - [num2 toInt32] - 1;
        
        MakeMeBecomeStackBlock;
        
        return [JSValue valueWithInt32:res inContext:[JSContext currentContext]];
    };
}

- (void)defineJSContextUsingSameBlock:(JSContext *)context
{
    JSMethodWithArg2 method = ^(JSValue *num1, JSValue* num2){
        int res = [num1 toInt32]  - [num2 toInt32];
        
        MakeMeBecomeStackBlock;
        
        return [JSValue valueWithInt32:res inContext:[JSContext currentContext]];
    };
    
    context[@"delete1"] = method;
    context[@"delete2"] = method;
}

- (NSUInteger)hook_retainCount
{
    return [self hook_retainCount];
}

- (instancetype)hook_retain
{
    NSLog(@"%s retainCount = %d", __PRETTY_FUNCTION__, (int)[self hook_retainCount]);
    ThreadCallStackSymbols;
    
    return [self hook_retain];
}

- (oneway void)hook_release
{
    NSLog(@"%s retainCount = %d", __PRETTY_FUNCTION__, (int)[self hook_retainCount]);
    ThreadCallStackSymbols;
    
    [self hook_release];
}

- (void)dealloc
{
    NSLog(@"%s", __PRETTY_FUNCTION__);

#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

@end


#pragma mark - JSContextDebug

@interface JSContextDebug : JSContext

@end

@implementation JSContextDebug

- (void)dealloc
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

@end


#pragma mark - JSValue (Debug)

@interface JSValue (Debug)

@end


@implementation JSValue (Debug)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSelector = NSSelectorFromString(@"setValue:forProperty:");
        SEL swizzledSelector = NSSelectorFromString(@"hook_setValue:forProperty:");
        [[self class] methodSwizzled:originalSelector swizzledSelector:swizzledSelector];
    });
}

- (void)checkIfValueExist:(id)value forProperty:(NSString *)property
{
    if ( s_valueMapTable == nil )
    {
#if !__has_feature(objc_arc)
        s_valueMapTable = [[NSMapTable mapTableWithKeyOptions:NSMapTableCopyIn valueOptions:NSMapTableCopyIn] retain];
#else
        s_valueMapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableCopyIn valueOptions:NSMapTableCopyIn];
#endif
    }
    
    NSString * key = [NSString stringWithFormat:@"%p", value];
    NSString * hitTestVaule = [s_valueMapTable objectForKey:key];
    if ( hitTestVaule != nil )
    {
        NSLog(@"[error] duplicate_value %@, old_property = %@, new_property = %@", value, hitTestVaule, property );
    }
    else
    {
        [s_valueMapTable setObject:property forKey:key];
    }
}

- (void)hook_setValue:(id)value forProperty:(NSString *)property
{
    [self checkIfValueExist:value forProperty:property];
    
    [self hook_setValue:value forProperty:property];
    
    NSLog(@"%s value = %@ property = %@",__PRETTY_FUNCTION__, value, property );
    
//    NSLog(@"====###======");
//    NSDictionary *modifiedGlobalvalue = [self toDictionary];
//    NSLog(@"modifiedGlobalvalue = %@", modifiedGlobalvalue );
//    NSLog(@"====###======");
}

@end

@implementation JSContextDebugWapper

- (void)defineJSContext:(JSContext *)context
{
    context[@"add1"] = ^(JSValue *num1, JSValue* num2){
        int res = [num1 toInt32]  + [num2 toInt32];
        
        MakeMeBecomeStackBlock;
        
        return [JSValue valueWithInt32:res inContext:[JSContext currentContext]];
    };
    
    context[@"add2"] = ^(JSValue *num1, JSValue* num2){
        int res = [num1 toInt32]  + [num2 toInt32] + 1;
        
        MakeMeBecomeStackBlock;
        
        return [JSValue valueWithInt32:res inContext:[JSContext currentContext]];
    };
    
    context[@"add3"] = ^(JSValue *num1, JSValue* num2 ){
        int res = [num1 toInt32]  + [num2 toInt32] + 2;
        
        MakeMeBecomeStackBlock;
        
        return [JSValue valueWithInt32:res inContext:[JSContext currentContext]];
    };
}

+ (void)defineJSContext1:(JSContext *)context
{
    context[@"add1"] = ^(){ NSLog(@"%@",self);};
    context[@"add2"] = ^(){ NSLog(@"%@",self);};
    context[@"add3"] = ^(){ NSLog(@"%@",self);};
}

+ (void)defineJSContext2:(JSContext *)context
{
    context[@"delete1"] = ^(){ NSLog(@"%@",self);};
    context[@"delete2"] = ^(){ NSLog(@"%@",self);};
}

+ (void)testSimpleJSContext
{
    JSContext *jsContext = [[JSContext alloc] init];
    [self defineJSContext1:jsContext];
    [self defineJSContext2:jsContext];
    
    NSLog(@"%@", [jsContext.globalObject toDictionary]);
    
#if !__has_feature(objc_arc)
    [jsContext release];
#endif
}

+ (void)testUsingSameObject
{
    JSContext *jsContext = [[JSContext alloc] init];
    NSDictionary *dictionary = [[NSDictionary alloc] init];
    JSValue * dictionaryJSValue = [JSValue valueWithObject:dictionary inContext:jsContext];
    NSObject *shareObject = [[NSObject alloc] init];
 
    [s_valueMapTable removeAllObjects];
    dictionaryJSValue[@"1"] = shareObject;
    dictionaryJSValue[@"2"] = shareObject;
    NSLog(@"%@", [dictionaryJSValue toDictionary]);

#if !__has_feature(objc_arc)
    [jsContext release];
    [dictionary release];
    [shareObject release];
#endif
    
}

+ (void)testUsingMultipleBlocks
{
    JSContextDebugWapper * jsContextDebugWapper = [[JSContextDebugWapper alloc] init];
    JSContextDefineClass *defineClass = [[JSContextDefineClass alloc] init];
    JSContextDebug *context = [[JSContextDebug alloc] init];
    
    [s_valueMapTable removeAllObjects];
    [jsContextDebugWapper defineJSContext:context];
    [defineClass defineJSContext:context];
    
    JSValue *globalValue = context.globalObject;
    NSDictionary *allGlobalVaules = [globalValue toDictionary];
    
    NSLog(@"========####======####=====");
    NSLog(@"allGlobalVaules = %@", allGlobalVaules);
    
    NSLog(@"========####======####=====");
    
    for (NSString *key in [allGlobalVaules allKeys])
    {
        NSUInteger num1 = 31;
        NSUInteger num2 = 12;
        NSUInteger returnvalue = [[context[key] callWithArguments:@[@(num1), @(num2)]] toInt32];
        
        NSLog(@"[call-method] num1 = %ld num2 = %ld result = %ld key = %@", num1, num2, returnvalue, key);
    }
    
#if !__has_feature(objc_arc)
    [jsContextDebugWapper release];
    [defineClass release];
    [context release];
#endif
}

+ (void)testUsingSameBlock
{
    JSContextDebugWapper * jsContextDebugWapper = [[JSContextDebugWapper alloc] init];
    JSContextDefineClass *defineClass = [[JSContextDefineClass alloc] init];
    JSContextDebug *context = [[JSContextDebug alloc] init];
    
    [s_valueMapTable removeAllObjects];
    [jsContextDebugWapper defineJSContext:context];
    [defineClass defineJSContextUsingSameBlock:context];
    
    JSValue *globalValue = context.globalObject;
    NSDictionary *allGlobalVaules = [globalValue toDictionary];
    
    NSLog(@"========####======####=====");
    NSLog(@"allGlobalVaules = %@", allGlobalVaules);
    
    NSLog(@"========####======####=====");
    
    for (NSString *key in [allGlobalVaules allKeys])
    {
        NSUInteger num1 = 31;
        NSUInteger num2 = 12;
        NSUInteger returnvalue = [[context[key] callWithArguments:@[@(num1), @(num2)]] toInt32];
        
        NSLog(@"[call-method] num1 = %ld num2 = %ld result = %ld key = %@", num1, num2, returnvalue, key);
    }
    
#if !__has_feature(objc_arc)
    [jsContextDebugWapper release];
    [defineClass release];
    [context release];
#endif
}

+ (void)hookCMethods
{
    struct rebinding rebinding_info = { "_Block_copy", New_Block_copy, (void *)&Old_Block_copy };
    rebind_symbols((struct rebinding[1]){rebinding_info}, 1);
}

@end
