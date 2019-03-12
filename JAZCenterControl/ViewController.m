//
//  ViewController.m
//  JAZCenterControl
//
//  Created by 筱鹏 on 2019/3/12.
//  Copyright © 2019 筱鹏. All rights reserved.
//

#import "ViewController.h"
#import "JAZCenterControl.h"

#define ViewControllerDebugLog NSLog(@"%@, %@", self, NSStringFromSelector(_cmd))
@interface ViewController () <JAZCenterControlDelegate>

@end

@implementation ViewController

- (void)dealloc
{
    ViewControllerDebugLog;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    ViewControllerDebugLog;
    
    [JAZCenterControl addObserver:self type:JAZCenterControlType_appWillEnterForeground];
    [JAZCenterControl addObserver:self type:JAZCenterControlType_appDidBecomeActive block:^(JAZCenterControlType type) {
        NSLog(@"didBecomeActive  = %lu", type);
    }];
    
    [JAZCenterControl addObserver:self type:JAZCenterControlType_appWillResignActive block:^(JAZCenterControlType type) {
        NSLog(@"willResignActive = %lu", type);
    }];
    [JAZCenterControl addObserver:self type:JAZCenterControlType_appDidEnterBackground];
}

- (void)jazCenterControlActionWithType:(JAZCenterControlType)type
{
    NSLog(@"jazCenterControlActionWithType = %lu", type);
    
}

@end
