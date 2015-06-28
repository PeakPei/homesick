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
    self = [super initWithTexture:[SKTexture textureWithImageNamed:@"character01"]];
    if (self) {
        CGFloat characterSize = CGRectGetWidth(sceneSize) * 0.14f;
        self.size = CGSizeMake(characterSize, characterSize);
        self.scale = 0.6f;
        
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:(characterSize * 0.4f)];
        self.physicsBody.velocity = CGVectorMake(0.0f, 0.0f);
        self.physicsBody.mass = 1.0f;
        self.physicsBody.dynamic = YES;
        self.physicsBody.affectedByGravity = NO;
        self.physicsBody.linearDamping = 1.0f;
//        self.physicsBody.categoryBitMask = kColliderTypeGift;
//        self.physicsBody.collisionBitMask = kColliderTypeSkyscraperCollision | kColliderTypeGift;
//        self.physicsBody.contactTestBitMask = kColliderTypeSkyscraper;
    }
    return self;
}


- (void)prepareForFallingWithDescentByDistance:(CGFloat)distance
{
    SKAction *descentAction = [SKAction moveByX:0.0 y:-distance duration:2.0f];
    descentAction.timingMode = SKActionTimingEaseIn;
    [self runAction:descentAction];
    
    SKAction *scaleAction = [SKAction scaleTo:1.0f duration:2.0f];
    scaleAction.timingMode = SKActionTimingEaseOut;
    [self runAction:scaleAction];
}

@end
