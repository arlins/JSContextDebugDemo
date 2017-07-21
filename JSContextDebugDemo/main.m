//
//  main.m
//  JSContextDebugDemo
//
//  Created by dps on 2017/6/3.
//  Copyright © 2017年 dps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "JSContextDebugWapper.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        [JSContextDebugWapper hookCMethods];
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
