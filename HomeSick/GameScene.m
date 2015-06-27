//
//  GameScene.m
//  HomeSick
//
//  Created by Damir Stuhec on 27/06/15.
//  Copyright (c) 2015 damirstuhec. All rights reserved.
//

#import "GameScene.h"

#import "HSBackgroundNode.h"
#import "HSPlanetNode.h"
#import "HSMainCharacterNode.h"
#import "PBParallaxScrolling.h"

#import "UIColor+HSAdditions.h"

#define SK_DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) * 0.01745329252f) // PI / 180
#define SK_RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) * 57.29577951f) // PI * 180

@interface GameScene()

@property (nonatomic, strong) SKAction *droneSoundPlay;

@property (nonatomic, weak) HSBackgroundNode *colorBackgroundNode;
@property (nonatomic, strong) PBParallaxScrolling *parallaxBackgroundNode;

@property (nonatomic, weak) HSPlanetNode *foreignPlanetNode;
@property (nonatomic, weak) HSPlanetNode *homePlanetNode;

@property (nonatomic, weak) HSMainCharacterNode *characterNode;

@property (nonatomic) BOOL falling;

@end

@implementation GameScene

- (void)didMoveToView:(SKView *)view
{
    self.backgroundColor = [UIColor hs_colorFromHexString:@"071d33"];
    //
    // Start drone
    self.droneSoundPlay = [SKAction playSoundFileNamed:@"Drone01.mp3" waitForCompletion:NO];
    [self runAction:self.droneSoundPlay];
    
    //
    // Add background paralax node
    HSBackgroundNode *colorBackgroundNode = [HSBackgroundNode spriteNodeWithColor:[UIColor hs_colorFromHexString:@"071d33"] size:self.frame.size];
    NSArray * imageNames = @[@"bg2", @"bg3", colorBackgroundNode];
    PBParallaxScrolling *parallaxBackgroundNode = [[PBParallaxScrolling alloc] initWithBackgrounds:imageNames size:self.frame.size direction:kPBParallaxBackgroundDirectionUp fastestSpeed:3.0f andSpeedDecrease:kPBParallaxBackgroundDefaultSpeedDifferential];
    parallaxBackgroundNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    parallaxBackgroundNode.zPosition = 20;
    [self addChild:parallaxBackgroundNode];
    self.parallaxBackgroundNode = parallaxBackgroundNode;
    
    //
    // Create and add a foreign planet node
    HSPlanetNode *foreignPlanetNode = [HSPlanetNode shapeNodeWithCircleOfRadius:(CGRectGetWidth(self.frame) * 0.4f)];
    foreignPlanetNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) + (CGRectGetHeight(foreignPlanetNode.frame) * 0.22f));
    foreignPlanetNode.fillColor = [UIColor hs_colorFromHexString:@"44484d"];
    foreignPlanetNode.strokeColor = [UIColor hs_colorFromHexString:@"5a5f66"];
    foreignPlanetNode.lineWidth = 4.0f;
    foreignPlanetNode.zPosition = 30;
    [self addChild:foreignPlanetNode];
    self.foreignPlanetNode = foreignPlanetNode;
    
    //
    // Create and add a main character node
    HSMainCharacterNode *characterNode = [[HSMainCharacterNode alloc] initWithSceneSize:self.frame];
    characterNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.foreignPlanetNode.frame));
    characterNode.zPosition = 40;
    [self addChild:characterNode];
    self.characterNode = characterNode;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //
    // Start falling if not already
    if (!self.falling) {
        self.falling = YES;
        
        [self _startFalling];
        return;
    }
    
    //
    // Move the character based on the touch location
    if (touches.count == 0) {
        return;
    }
    
    UITouch *touch = touches.allObjects.firstObject;
    CGPoint touchLocation = [touch locationInNode:self];
    
    BOOL touchedLeftSide = touchLocation.x <= CGRectGetMidX(self.frame);
    CGFloat sideTranslatedTouchLocation = 0.0f;
    if (touchedLeftSide) {
        sideTranslatedTouchLocation = (CGRectGetMidX(self.frame) - touchLocation.x) / CGRectGetMidX(self.frame);
    }
    else {
        sideTranslatedTouchLocation = (touchLocation.x - CGRectGetMidX(self.frame)) / CGRectGetMidX(self.frame);
    }
    
    CGFloat impulseVelocityFactor = MAX(0.2f, sideTranslatedTouchLocation);
    CGFloat impulseVelocity = impulseVelocityFactor * 220.0f;
    CGVector characterImpulseVector = CGVectorMake((touchedLeftSide) ? -impulseVelocity : impulseVelocity, 0.0f);
    [self.characterNode.physicsBody applyImpulse:characterImpulseVector];
    
    //
    // Rotate the character based on touch
    CGPoint characterPosition = self.characterNode.position;
    CGFloat opposite = characterPosition.y - touchLocation.y;
    CGFloat adjacent = fabs(characterPosition.x - touchLocation.x);
    CGFloat alphaAngle = atanf(opposite/adjacent);
    CGFloat gemmaAngle = SK_DEGREES_TO_RADIANS(90.0f) - alphaAngle;
    CGFloat rotationAngle = (touchedLeftSide) ? -gemmaAngle : gemmaAngle;
    
    [self.characterNode runAction:[SKAction rotateByAngle:rotationAngle duration:0.2f] completion:^{
        SKAction *waitAction = [SKAction waitForDuration:0.1f];
        SKAction *reverseRotateAction = [SKAction rotateByAngle:-rotationAngle duration:0.4f];
        SKAction *sequence = [SKAction sequence:@[waitAction, reverseRotateAction]];
        [self.characterNode runAction:sequence];
    }];
}


- (void)update:(CFTimeInterval)currentTime
{
    [self.parallaxBackgroundNode update:currentTime];
}


#pragma mark - Private methods

- (void)_startFalling
{
    //
    // Move foreign planet out from the scene by translating it upwards
    [self.foreignPlanetNode moveUp];
    
    //
    // Descent main character to falling position
    CGFloat characterCurrentVerticalPosition = self.characterNode.position.y;
    CGFloat characterDescentDistance = characterCurrentVerticalPosition - (CGRectGetHeight(self.frame) * 0.75f);
    [self.characterNode prepareForFallingWithDescentByDistance:characterDescentDistance];
}

@end
