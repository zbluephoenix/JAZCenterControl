//
//  NSObject+JAZCenterControl.h
//  JAZCenterControl
//
//  Created by 筱鹏 on 2019/3/12.
//  Copyright © 2019 筱鹏. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (JAZCenterControl)

@property (nonatomic, readonly) NSMutableArray *jazCenterControlKeys;
@property (nonatomic, readonly) NSMutableArray *jazCenterControlBlocks;

- (void)addJazCenterControlKey:(NSString *)key;
- (void)removeJazCenterControlKey:(NSString *)key;

/** Return block 的 copy 对象 */
- (id)addJazCenterControlBlock:(id)block;
- (void)removeJazCenterControlBlock:(id)block;

- (BOOL)containsJazCenterControlkey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
