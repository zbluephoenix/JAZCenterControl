//
//  JAZCenterControl.h
//  JAZCenterControl
//
//  Created by 筱鹏 on 2019/3/12.
//  Copyright © 2019 筱鹏. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, JAZCenterControlType) {
    JAZCenterControlType_appWillEnterForeground      = 1 << 0,
    JAZCenterControlType_appDidBecomeActive          = 1 << 1,
    JAZCenterControlType_appWillResignActive         = 1 << 2,
    JAZCenterControlType_appDidEnterBackground       = 1 << 3,
};

typedef void(^JAZCenterControlCallBack)(JAZCenterControlType type);

@protocol JAZCenterControlDelegate <NSObject>

- (void)jazCenterControlActionWithType:(JAZCenterControlType)type;

@end

@interface JAZCenterControl : NSObject

+ (instancetype)sharedManager;

+ (void)startControl;
+ (void)stopControl;

/**
 * @warning observer 强引用 block对象，使用时注意避免循环引用
 * observer: 添加观察者对象
 * type: 添加观察的事件类型
 * block: 观察的事件响应回调
 */
+ (void)addObserver:(NSObject *)observer type:(JAZCenterControlType)type block:(JAZCenterControlCallBack)block;

+ (void)removeObserver:(NSObject *)observer type:(JAZCenterControlType)type;

+ (void)addObserver:(NSObject <JAZCenterControlDelegate>*)observer type:(JAZCenterControlType)type;

@end

NS_ASSUME_NONNULL_END
