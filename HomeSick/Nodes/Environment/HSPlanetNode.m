//
//  HSPlanetNode.m
//  HomeSick
//
//  Created by Damir Stuhec on 27/06/15.
//  Copyright (c) 2015 damirstuhec. All rights reserved.
//

#import "HSPlanetNode.h"

@implementation HSPlanetNode

- (void)moveUp
{
    SKAction *moveUpAction = [SKAction moveByX:0.0 y:CGRectGetHeight(self.frame) duration:4.0f];
    [self runAction:moveUpAction];
}


- (void)moveDown
{
    SKAction *moveDownAction = [SKAction moveByX:0.0 y:-CGRectGetHeight(self.frame) duration:4.0f];
    [self runAction:moveDownAction];
}

@end
