//
//  HSProgressBarNode.m
//  HomeSick
//
//  Created by Damir Stuhec on 28/06/15.
//  Copyright (c) 2015 damirstuhec. All rights reserved.
//

#import "HSProgressBarNode.h"

@interface HSProgressBarNode()

@property (nonatomic, strong) SKSpriteNode *foreignPlanetNode;
@property (nonatomic, strong) SKSpriteNode *homePlanetNode;

@end

@implementation HSProgressBarNode

- (instancetype)initWithColor:(UIColor *)color size:(CGSize)size
{
    self = [super initWithColor:color size:size];
    if (self) {
        CGSize planetSize = CGSizeMake(size.width, size.width);
        
        //
        // Add foreign planet node
        self.foreignPlanetNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"foreignPlanet"] size:planetSize];
        self.foreignPlanetNode.anchorPoint = CGPointMake(0.0f, 1.0f);
        self.foreignPlanetNode.position = CGPointMake(0.0f, CGRectGetMaxY(self.frame));
        [self addChild:self.foreignPlanetNode];
        
        //
        // Add home planet node
        self.homePlanetNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"homePlanet"] size:planetSize];
        self.homePlanetNode.anchorPoint = CGPointZero;
        self.homePlanetNode.position = CGPointMake(0.0f, CGRectGetMinY(self.frame));
        [self addChild:self.homePlanetNode];
        
        //
        // Add character node
        self.characterNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"character01"] size:CGSizeMake(planetSize.width * 0.7f, planetSize.height * 0.7f)];
        self.characterNode.anchorPoint = CGPointMake(0.5f, 1.0f);
        self.characterNode.position = [self _characterNodePositionBasedOnProgressFactor:0.0f];
        [self addChild:self.characterNode];
    }
    return self;
}


- (void)fadeIn
{
    SKAction *fadeInAction = [SKAction fadeAlphaTo:0.6f duration:3.0f];
    [self runAction:fadeInAction];
}


- (void)fadeOut
{
    SKAction *fadeOutAction = [SKAction fadeOutWithDuration:3.0f];
    [self runAction:fadeOutAction];
}


- (void)repositionCharacterNodeForProgress:(CGFloat)progress
{
    CGPoint newPosition = [self _characterNodePositionBasedOnProgressFactor:progress];
    
    SKAction *moveAction = [SKAction moveTo:newPosition duration:2.0f];
    [self.characterNode runAction:moveAction];
}


#pragma mark - Private methods

- (CGPoint)_characterNodePositionBasedOnProgressFactor:(CGFloat)progressFactor
{
    CGFloat maxY = CGRectGetMinY(self.foreignPlanetNode.frame);
    CGFloat minY = CGRectGetMaxY(self.homePlanetNode.frame);
    CGFloat newYPosition = maxY - (progressFactor * (maxY - minY));
    return CGPointMake(CGRectGetMidX(self.homePlanetNode.frame), newYPosition);
}

@end
