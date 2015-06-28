//
//  HSMainCharacter.m
//  HomeSick
//
//  Created by Damir Stuhec on 27/06/15.
//  Copyright (c) 2015 damirstuhec. All rights reserved.
//

#import "HSMainCharacterNode.h"

static CGFloat const kSmallScale = 0.6f;
static CGFloat const kFullScale = 1.0f;

@interface HSMainCharacterNode()

@property (nonatomic, strong) SKSpriteNode *tailNode;
@property (nonatomic, strong) SKSpriteNode *headNode;

@end

@implementation HSMainCharacterNode

- (instancetype)initWithSceneSize:(CGRect)sceneSize
{
    self = [super init];
    if (self) {
        CGFloat headSize = CGRectGetWidth(sceneSize) * 0.14f;
        
        //
        // Add tail node
        self.headNode = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"character01"]];
        self.headNode.size = CGSizeMake(headSize, headSize);
        self.headNode.scale = kSmallScale;
        self.headNode.zPosition = 20;
        [self addChild:self.headNode];
        
        //
        // Add tail node
        self.tailNode = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"tail01"]];
        self.tailNode.alpha = 0.9f;
        self.tailNode.size = CGSizeMake(headSize * 0.4f, headSize * 1.2f);
        self.tailNode.anchorPoint = CGPointMake(0.5f, 0.0f);
        self.tailNode.zPosition = 10;
        [self addChild:self.tailNode];
        
        //
        // Setup physics body
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(headSize * 0.7f, headSize * 0.7f) center:CGPointMake(CGRectGetMidX(self.headNode.frame), CGRectGetMidY(self.headNode.frame))];
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
    
    SKAction *scaleAction = [SKAction scaleTo:kFullScale duration:2.0f];
    scaleAction.timingMode = SKActionTimingEaseIn;
    [self runAction:scaleAction];
}


- (void)prepareForLandingWithDescentByDistance:(CGFloat)distance
{
    SKAction *descentAction = [SKAction moveByX:0.0 y:-distance duration:1.8f];
    descentAction.timingMode = SKActionTimingEaseInEaseOut;
    [self runAction:descentAction];
    
    SKAction *scaleAction = [SKAction scaleTo:kSmallScale duration:1.8f];
    scaleAction.timingMode = SKActionTimingEaseOut;
    [self runAction:scaleAction];
}


- (void)rotateByAngle:(CGFloat)angle
{
    //
    // Rotate head
    [self.headNode runAction:[SKAction rotateByAngle:angle duration:0.2f] completion:^{
        SKAction *waitAction = [SKAction waitForDuration:0.1f];
        SKAction *reverseRotateAction = [SKAction rotateByAngle:-angle duration:0.4f];
        SKAction *sequence = [SKAction sequence:@[waitAction, reverseRotateAction]];
        [self.headNode runAction:sequence];
    }];
    
    //
    // Rotate tail
    SKAction *waitAction1 = [SKAction waitForDuration:0.05f];
    SKAction *rotateAction = [SKAction rotateByAngle:angle duration:0.3f];
    SKAction *sequence1 = [SKAction sequence:@[waitAction1, rotateAction]];
    [self.tailNode runAction:sequence1 completion:^{
        SKAction *waitAction2 = [SKAction waitForDuration:0.1f];
        SKAction *reverseRotateAction = [SKAction rotateByAngle:-angle duration:0.5f];
        SKAction *sequence2 = [SKAction sequence:@[waitAction2, reverseRotateAction]];
        [self.tailNode runAction:sequence2];
    }];
}

@end
