//
//  HSMasks.h
//  HomeSick
//
//  Created by Damir Stuhec on 28/06/15.
//  Copyright (c) 2015 damirstuhec. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : uint8_t {
    kColliderTypeCharacter  =  0x1 << 0,
    kColliderTypeMonster    =  0x1 << 1
} ColliderType;

@interface HSMasks : NSObject
@end
