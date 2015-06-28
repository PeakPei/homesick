//
//  HSPlanetNode.m
//  HomeSick
//
//  Created by Damir Stuhec on 27/06/15.
//  Copyright (c) 2015 damirstuhec. All rights reserved.
//

#import "HSPlanetNode.h"

@implementation HSPlanetNode

- (void)moveUpByDistance:(CGFloat)distance duration:(CGFloat)duration
{
    SKAction *moveUpAction = [SKAction moveByX:0.0 y:distance duration:duration];
    moveUpAction.timingMode = SKActionTimingEaseOut;
    [self runAction:moveUpAction];
}

@end
