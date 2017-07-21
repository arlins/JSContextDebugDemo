//
//  ViewController.m
//  JSContextDebugDemo
//
//  Created by arlin on 2017/6/3.
//  Copyright © 2017年 dps. All rights reserved.
//

#import "ViewController.h"
#import "JSContextDebugWapper.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    float height = 100.0;
    float width = self.view.bounds.size.width;
    float yOffset = 0.0;
    
    {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, yOffset, width, height)];
        [button setTitle:@"testUsingMultipleBlocks" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(testUsingMultipleBlocks:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:button];
        
#if !__has_feature(objc_arc)
        [button release];
#endif
    }
    
    {
        yOffset += height;
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, yOffset, width, height)];
        [button setTitle:@"testUsingSameBlock" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(testUsingSameBlock:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:button];
        
#if !__has_feature(objc_arc)
        [button release];
#endif
    }
    
    {
        yOffset += height;
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, yOffset, width, height)];
        [button setTitle:@"testUsingSameObject" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(testUsingSameObject:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:button];
        
#if !__has_feature(objc_arc)
        [button release];
#endif
    }
}


- (void)testUsingMultipleBlocks:(id)sender
{
    [JSContextDebugWapper testUsingMultipleBlocks];
}

- (void)testUsingSameBlock:(id)sender
{
    [JSContextDebugWapper testUsingSameBlock];
}

- (void)testUsingSameObject:(id)sender
{
    [JSContextDebugWapper testUsingSameObject];
}

@end
