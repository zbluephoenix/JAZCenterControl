//
//  NSObject+JAZCenterControl.m
//  JAZCenterControl
//
//  Created by 筱鹏 on 2019/3/12.
//  Copyright © 2019 筱鹏. All rights reserved.
//

#import "NSObject+JAZCenterControl.h"
#import "JAZCenterControlConstant.h"
#import <objc/runtime.h>

@implementation NSObject (JAZCenterControl)

- (NSMutableArray *)jazCenterControlKeys
{
    NSMutableArray *array = objc_getAssociatedObject(self, @selector(jazCenterControlKeys));
    if (!array) {
        array = [NSMutableArray arrayWithCapacity:1];
        objc_setAssociatedObject(self, @selector(jazCenterControlKeys), array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return array;
}

- (NSMutableArray *)jazCenterControlBlocks
{
    NSMutableArray *array = objc_getAssociatedObject(self, @selector(jazCenterControlBlocks));
    if (!array) {
        array = [NSMutableArray arrayWithCapacity:1];
        objc_setAssociatedObject(self, @selector(jazCenterControlBlocks), array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return array;
}

- (void)addJazCenterControlKey:(NSString *)key
{
    JAZDebugAssert(!(!key || ![key isKindOfClass:NSString.class]), @"key must be NSString class");
    if (!key || ![key isKindOfClass:NSString.class]) {
        return ;
    }
    [self.jazCenterControlKeys addObject:key];
}

- (void)removeJazCenterControlKey:(NSString *)key
{
    JAZDebugAssert(!(!key || ![key isKindOfClass:NSString.class]), @"key must be NSString class");
    if (!key || ![key isKindOfClass:NSString.class]) {
        return;
    }
    [self.jazCenterControlKeys removeObject:key];
}

- (id)addJazCenterControlBlock:(id)block
{
    JAZDebugAssert((block != nil), @"block is nil");
    if (!block) {
        return nil;
    }
    id copyBlock = [block copy];
    [self.jazCenterControlBlocks addObject:copyBlock];
    return copyBlock;
}

- (void)removeJazCenterControlBlock:(id)block
{
    JAZDebugAssert((block != nil), @"block is nil");
    if (!block) {
        return;
    }
    [self.jazCenterControlBlocks removeObject:block];
}

- (BOOL)containsJazCenterControlkey:(NSString *)key
{
    JAZDebugAssert(!(!key || ![key isKindOfClass:NSString.class]), @"key must be NSString class");
    if (!key || ![key isKindOfClass:NSString.class]) {
        return NO;
    }
    return [self.jazCenterControlKeys containsObject:key];
}

@end
