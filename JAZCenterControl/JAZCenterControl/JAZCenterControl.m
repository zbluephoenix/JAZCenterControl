//
//  JAZCenterControl.m
//  JAZCenterControl
//
//  Created by 筱鹏 on 2019/3/12.
//  Copyright © 2019 筱鹏. All rights reserved.
//

#import "JAZCenterControl.h"
#import "NSObject+JAZCenterControl.h"
#import <UIKit/UIKit.h>

@interface JAZCenterControl ()

@property (nonatomic, strong) NSMutableDictionary <NSNumber *, NSHashTable *>*typeKeyDic;
@property (nonatomic, strong) NSMapTable *blockMap;

@end

@implementation JAZCenterControl

+ (instancetype)sharedManager
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

+ (void)startControl
{
    [[self.class sharedManager] privateStartControl];
}

+ (void)stopControl
{
    [[self.class sharedManager] privateStopControl];
}

+ (void)addObserver:(NSObject *)observer type:(JAZCenterControlType)type block:(JAZCenterControlCallBack)block
{
    [[self.class sharedManager] privateAddObserver:observer type:type block:block];

}

+ (void)removeObserver:(NSObject *)observer type:(JAZCenterControlType)type
{
    [[self.class sharedManager] privateRemoveObserver:observer type:type];
}

+ (void)addObserver:(NSObject <JAZCenterControlDelegate>*)observer type:(JAZCenterControlType)type
{
    __weak NSObject <JAZCenterControlDelegate> *weakObserver = observer;
    JAZCenterControlCallBack callBack = ^(JAZCenterControlType type) {
        if (weakObserver &&
            [weakObserver respondsToSelector:@selector(jazCenterControlActionWithType:)]) {
            [weakObserver jazCenterControlActionWithType:type];
        }
    };
    [self.class addObserver:observer type:type block:callBack];
}

#pragma mark - Private

- (void)privateStartControl
{
    _typeKeyDic = [NSMutableDictionary dictionaryWithCapacity:1];
    _blockMap = [NSMapTable weakToWeakObjectsMapTable];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)privateStopControl
{
    [_typeKeyDic removeAllObjects];
    _typeKeyDic = nil;
    [_blockMap removeAllObjects];
    _blockMap = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)privateExecuteBlockWithType:(JAZCenterControlType)type
{
    NSEnumerator *objEnu = [self obtainHashTableWithType:type].objectEnumerator;
    NSString *objKey;
    while ((objKey = [objEnu nextObject])) {
        JAZCenterControlCallBack callBack = [self.blockMap objectForKey:objKey];
        if (callBack) {
            callBack(type);
        }
    }
}

#pragma mark - Private AddObserver

- (void)privateAddObserver:(NSObject *)observer type:(JAZCenterControlType)type block:(JAZCenterControlCallBack)block
{
    if (![observer isKindOfClass:NSObject.class]) {
        return;
    }
    
    NSString * (^compareAndConfig)(JAZCenterControlType, JAZCenterControlType)
    = ^NSString * (JAZCenterControlType outType, JAZCenterControlType fixType){
        if (outType & fixType) {
            NSString *key = [self generateObserver:observer type:fixType];
            if (key) {
                // 将生成的key 绑定到observer 中， 并让 center 记录 这个key
                // block 单独添加， 因为可能 多个key 对应一个 block
                [observer addJazCenterControlKey:key];
                [[self obtainHashTableWithType:fixType] addObject:key];
            }
            return key;
        }
        return nil;
    };
    NSMutableArray *allKeys = [NSMutableArray arrayWithCapacity:1];
    // 给 allKeys 添加数据时 先判断是否为 nil
    // addObj 方法内部有判断 是否为 nil
    [self centerControlTypeEnumerateUserBlock:^(JAZCenterControlType objType) {
        NSString *key = compareAndConfig(type, objType);
        if (key) {
            [allKeys addObject:key];
        }
    }];
    
    
    if (allKeys.count == 0) {
        // 如果 allKeys 为空， 则 observer 没有绑定成任何一个key 所以不用 进行绑定 block
        return;
    }
    
    // 将 block 与 observer 进行绑定
    JAZCenterControlCallBack copyBlock = [observer addJazCenterControlBlock:block];
    [allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 通过 center 将 block与 key 进行关联起来
        [self.blockMap setObject:copyBlock forKey:obj];
    }];
}

- (NSHashTable *)obtainHashTableWithType:(JAZCenterControlType)type
{
    NSHashTable *hashTable = [_typeKeyDic objectForKey:@(type)];
    if (!hashTable) {
        hashTable = [NSHashTable weakObjectsHashTable];
        [_typeKeyDic setObject:hashTable forKey:@(type)];
    }
    return hashTable;
}

- (NSString *)generateObserver:(NSObject *)observer type:(JAZCenterControlType)type
{
    NSString *key = [NSString stringWithFormat:@"%@-%ld-%p",observer, type, observer];
    if ([observer containsJazCenterControlkey:key]) {
        NSLog(@"%@ - Error - Observer:%@ Have The Key:%@", NSStringFromClass(self.class), observer, key);
        return nil;
    }
    return key;
}

#pragma mark - Private RemoveObserver

- (void)privateRemoveObserver:(NSObject *)observer type:(JAZCenterControlType)type
{
    if (![observer isKindOfClass:NSObject.class]) {
        return;
    }
    [self debugTest];
    
    NSString * (^compareAndConfig)(JAZCenterControlType, JAZCenterControlType)
    = ^NSString * (JAZCenterControlType outType, JAZCenterControlType fixType){
        if (outType & fixType) {
            NSString *key = [self generateRemoveObserver:observer type:fixType];
            return key;
        }
        return nil;
    };
    NSMutableArray *allKeys = [NSMutableArray arrayWithCapacity:1];
    // 给 allKeys 添加数据时 先判断是否为 nil
    // addObj 方法内部有判断 是否为 nil
    [self centerControlTypeEnumerateUserBlock:^(JAZCenterControlType objType) {
        NSString *key = compareAndConfig(type, objType);
        if (key) {
            [allKeys addObject:key];
        }
    }];
    
    
    if (allKeys.count == 0) {
        // 如果 allKeys 为空， 则 observer 没有绑定成任何一个key 所以不用 进行绑定 block
        return;
    }
    
    // 将 block 与 observer 进行绑定
    [allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 通过 center 将 block与 key 进行关联起来
        JAZCenterControlCallBack removeBlock = [self.blockMap objectForKey:obj];
        [observer removeJazCenterControlKey:obj];
        [observer removeJazCenterControlBlock:removeBlock];
    }];
    [self debugTest];
}


- (NSString *)generateRemoveObserver:(NSObject *)observer type:(JAZCenterControlType)type
{
    NSString *key = [NSString stringWithFormat:@"%@-%ld-%p",observer, type, observer];
    if ([observer containsJazCenterControlkey:key]) {
        return key;
    }
    return nil;
}

#pragma mark - DebugTest

- (void)debugTest
{
    [_typeKeyDic enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSHashTable * _Nonnull obj, BOOL * _Nonnull stop) {
        NSLog(@"_typeKeyDic key - %@ value - %@", key, obj);
        [obj.objectEnumerator.allObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"typeKeyDic - Obj - idx:%ld - obj:%@", idx, obj);
        }];
    }];
    [_blockMap.keyEnumerator.allObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"blockMap key: %@",obj);
    }];
    [_blockMap.objectEnumerator.allObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"blockMap obj: %@",obj);
    }];
}

#pragma mark - EnumArray

- (void)centerControlTypeEnumerateUserBlock:(void (^)(JAZCenterControlType objType))block
{
    if (!block) {
        return;
    }
    block(JAZCenterControlType_appWillEnterForeground);
    block(JAZCenterControlType_appDidBecomeActive);
    block(JAZCenterControlType_appWillResignActive);
    block(JAZCenterControlType_appDidEnterBackground);
}

#pragma mark - NotificationOrAction

- (void)appWillResignActive:(NSNotification *)notification
{
    [self privateExecuteBlockWithType:JAZCenterControlType_appWillResignActive];
}

- (void)appDidBecomeActive:(NSNotification *)notification
{
    [self privateExecuteBlockWithType:JAZCenterControlType_appDidBecomeActive];
}

- (void)appWillEnterForeground:(NSNotification *)notification
{
    [self privateExecuteBlockWithType:JAZCenterControlType_appWillEnterForeground];
}

- (void)appDidEnterBackground:(NSNotification *)notification
{
    [self privateExecuteBlockWithType:JAZCenterControlType_appDidEnterBackground];
}

@end
