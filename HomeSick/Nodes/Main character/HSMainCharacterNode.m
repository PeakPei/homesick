//
//  HSMainCharacter.m
//  HomeSick
//
//  Created by Damir Stuhec on 27/06/15.
//  Copyright (c) 2015 damirstuhec. All rights reserved.
//

#import "HSMainCharacterNode.h"

@implementation HSMainCharacterNode

- (instancetype)initWithSceneSize:(CGRect)sceneSize
{
    self = [super initWithTexture:[SKTexture textureWithImageNamed:@"main_character"]];
    if (self) {
        CGFloat characterSize = CGRectGetWidth(sceneSize) * 0.07f;
        self.size = CGSizeMake(characterSize, characterSize);
        self.scale = 0.6f;
    }
    return self;
}

- (void)prepareForFallingWithDescentByDistance:(CGFloat)distance
{
    SKAction *descentAction = [SKAction moveByX:0.0 y:-distance duration:1.4f];
    descentAction.timingMode = SKActionTimingEaseInEaseOut;
    [self runAction:descentAction];
    
    SKAction *scaleAction = [SKAction scaleTo:1.0f duration:1.4f];
    scaleAction.timingMode = SKActionTimingEaseOut;
    [self runAction:scaleAction];
}

@end
