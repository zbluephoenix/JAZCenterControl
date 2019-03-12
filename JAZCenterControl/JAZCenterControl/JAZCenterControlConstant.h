//
//  JAZCenterControlConstant.h
//  JAZCenterControl
//
//  Created by 筱鹏 on 2019/3/12.
//  Copyright © 2019 筱鹏. All rights reserved.
//

#ifndef JAZCenterControlConstant_h
#define JAZCenterControlConstant_h

#ifdef RELEASE
#define JAZDebugAssert(condition, desc, ...)
#else
#define JAZDebugAssert(condition, desc, ...) NSAssert(condition, desc, ##__VA_ARGS__)
#endif

#endif /* JAZCenterControlConstant_h */
