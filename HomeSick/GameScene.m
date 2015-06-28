//
//  GameScene.m
//  HomeSick
//
//  Created by Damir Stuhec on 27/06/15.
//  Copyright (c) 2015 damirstuhec. All rights reserved.
//

#import "GameScene.h"

#import "HSPlanetNode.h"
#import "HSMainCharacterNode.h"
#import "PBParallaxScrolling.h"
#import "HSProgressBarNode.h"
#import "HSMasks.h"

#import "UIColor+HSAdditions.h"

#import <AVFoundation/AVFoundation.h>

static inline CGFloat DegreesToRadians(CGFloat angle)
{
    return angle * 0.01745329252f;
}


static CGFloat const kDurationOfLevelInSeconds = 30.0f;

@interface GameScene() <SKPhysicsContactDelegate>

@property (nonatomic, strong) AVAudioPlayer *startEndSoundtrackPlayer;
@property (nonatomic, strong) AVAudioPlayer *playSoundtrackPlayer;
@property (nonatomic, strong) AVAudioPlayer *victorySoundPlayer;
@property (nonatomic, strong) AVAudioPlayer *crashSoundPlayer;

@property (nonatomic, strong) PBParallaxScrolling *parallaxBackgroundNode;
@property (nonatomic, weak) HSPlanetNode *foreignPlanetNode;
@property (nonatomic, weak) HSPlanetNode *homePlanetNode;
@property (nonatomic, weak) HSMainCharacterNode *characterNode;
@property (nonatomic, weak) HSProgressBarNode *progressBarNode;

@property (nonatomic, strong) NSMutableArray *monsters;

@property (nonatomic) BOOL gameOver;
@property (nonatomic) BOOL falling;
@property (nonatomic) BOOL landed;
@property (nonatomic) BOOL spawnGoTime;
@property (nonatomic, strong) SKAction *waitForSpawnAction;

@property (nonatomic, strong) SKLabelNode *gameOverLabelNode;
@property (nonatomic, strong) SKLabelNode *victoryLabelNode;
@property (nonatomic, strong) UIButton *playAgainButton;

@property (nonatomic) NSTimeInterval lastCheckTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) NSTimeInterval totalTimePassed;

@end

@implementation GameScene

- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        self.physicsWorld.contactDelegate = self;
    }
    return self;
}


- (void)didMoveToView:(SKView *)view
{
    self.backgroundColor = [UIColor hs_colorFromHexString:@"071d33"];
    
    //
    // Create soundtrack players
    NSURL *url1 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Drone01" ofType:@"mp3"]];
    self.startEndSoundtrackPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url1 error:nil];
    [self.startEndSoundtrackPlayer play];
    
    NSURL *url2 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Drone02" ofType:@"mp3"]];
    self.playSoundtrackPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url2 error:nil];
    
    NSURL *url3 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Crash" ofType:@"mp3"]];
    self.crashSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url3 error:nil];
    
    NSURL *url4 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Victory" ofType:@"mp3"]];
    self.victorySoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url4 error:nil];

    // Setup nodes
    [self _setupGlobalNodes];
    
    // Initialize an array to hold monsters
    self.monsters = [[NSMutableArray alloc] init];
    
    // Setup wait for spawn monsters action
    self.waitForSpawnAction = [SKAction waitForDuration:0.5f];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.gameOver) {
        return;
    }
    
    //
    // Start falling if not already
    if (!self.falling && !self.landed) {
        self.falling = YES;
        self.spawnGoTime = true;
        
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
    [self.characterNode.physicsBody applyImpulse:[self _characterImpulseVectorBasedOnTouchLocation:touchLocation]];
    
    //
    // Rotate the character based on touch
    CGFloat rotationAngle = [self _characterRotationAngleBasedOnTouchLocation:touchLocation andCharacterPosition:self.characterNode.position];
    [self.characterNode rotateByAngle:rotationAngle];
}


- (void)update:(CFTimeInterval)currentTime
{
    if (self.falling) {
        // Count the time
        [self _countTimeBasedOnCurrentTime:currentTime];
        
        // Spawn monster if needed
        [self _spawnMonsterIfNeeded];
        
        // Update monsters rotations
        [self _updateMonstersRotations];
        
        // Update progress bar
        [self _updateProgressBar];
    }
    
    // Update parallax backgrounds
    [self.parallaxBackgroundNode update:currentTime];
}


#pragma mark - Actions

- (void)playAgainButtonTouched:(UIButton *)button
{
    //
    // Reset everything
    self.totalTimePassed = 0;
    self.lastCheckTimeInterval = 0;
    self.lastUpdateTimeInterval = 0;
    self.gameOver = NO;
    self.landed = NO;
    self.falling = NO;
    self.spawnGoTime = NO;
    
    [self.parallaxBackgroundNode removeFromParent];
    [self.characterNode removeFromParent];
    
    [self.foreignPlanetNode removeFromParent];
    [self.homePlanetNode removeFromParent];
    [self.progressBarNode removeFromParent];
    
    [self.gameOverLabelNode removeFromParent];
    [self.victoryLabelNode removeFromParent];
    [self.playAgainButton removeFromSuperview];
    [self.view setNeedsDisplay];
    
    [self _setupGlobalNodes];
}


#pragma mark - Physic

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *bodyA = contact.bodyA;
    SKPhysicsBody *bodyB = contact.bodyB;
    
    // If the categories of physics bodies are different then the character has hit one of the monsters
    if (bodyA.categoryBitMask != bodyB.categoryBitMask) {
        if (!self.gameOver) {
            [self _gameOver];
        }
    }
}


#pragma mark - Private methods

- (void)_startFalling
{
    // Move foreign planet out from the scene by translating it upwards
    [self.foreignPlanetNode moveUpByDistance:CGRectGetHeight(self.foreignPlanetNode.frame) duration:4.0f];
    
    //
    // Descent main character to falling position
    CGFloat characterCurrentVerticalPosition = self.characterNode.position.y;
    CGFloat characterDescentDistance = characterCurrentVerticalPosition - (CGRectGetHeight(self.frame) * 0.75f);
    [self.characterNode prepareForFallingWithDescentByDistance:characterDescentDistance];
    
    // Speed up the parallax background
    [self.parallaxBackgroundNode changeSpeedsByFactor:6.0f];
    
    // Fade in progress bar
    [self.progressBarNode fadeIn];
    
    //
    // Change soundtrack
    [self.startEndSoundtrackPlayer pause];
    [self.playSoundtrackPlayer play];
}


- (void)_land
{
    // Mark game over
    self.gameOver = YES;
    
    // Mark landed
    self.landed = YES;
    
    // Stop falling
    self.falling = NO;
    
    // Stop spawning monsters
    self.spawnGoTime = NO;
    
    // Move foreign planet out from the scene by translating it upwards
    [self.homePlanetNode moveUpByDistance:(CGRectGetHeight(self.homePlanetNode.frame) * 0.8f) duration:1.2f];
    
    //
    // Descent main character to falling position
    CGFloat characterCurrentVerticalPosition = self.characterNode.position.y;
    CGFloat characterDescentDistance = characterCurrentVerticalPosition - (CGRectGetHeight(self.frame) * 0.17f);
    [self.characterNode prepareForLandingWithDescentByDistance:characterDescentDistance];
    
    // Slow down the parallax background
    [self.parallaxBackgroundNode changeSpeedsByFactor:0.1f];
    
    // Fade out progress bar
    [self.progressBarNode fadeOut];
    
    //
    // Play victory soundtrack
    [self.victorySoundPlayer play];
    
    //
    // Change background soundtrack
    [self.startEndSoundtrackPlayer play];
    [self.playSoundtrackPlayer stop];
    
    [self _showVictoryAndPlayAgain];
}


- (void)_gameOver
{
    // Mark game over
    self.gameOver = YES;
    
    // Mark landed
    self.landed = NO;
    
    // Stop falling
    self.falling = NO;
    
    // Stop spawning monsters
    self.spawnGoTime = NO;
    
    //
    // Show the game over stuff
    [self _showGameOverAndPlayAgain];
    
    // Slow down the parallax background
    [self.parallaxBackgroundNode changeSpeedsByFactor:0.1f];
    
    //
    // Play crash sountrack
    [self.crashSoundPlayer play];
    
    //
    // Change background soundtrack
    [self.startEndSoundtrackPlayer play];
    [self.playSoundtrackPlayer stop];
}


- (void)_spawnMonsterIfNeeded
{
    if (self.spawnGoTime) {
        self.spawnGoTime = false;
        
        SKAction *spawnAction = [SKAction runBlock:^{
            [self _spawnMonster];
            self.spawnGoTime = true;
        }];
        
        SKAction *spawnSequence = [SKAction sequence:@[self.waitForSpawnAction, spawnAction]];
        [self runAction:spawnSequence];
    }
}


- (void)_spawnMonster
{
    // Instantiate Atlas
    SKTextureAtlas *angrySquare = [SKTextureAtlas atlasNamed:@"AngrySquare"];
    SKTexture *monsterTexture = [angrySquare textureNamed:@"01"];
    
    //
    // Create sprite
    SKSpriteNode * monster = [SKSpriteNode spriteNodeWithTexture:monsterTexture];
    monster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monsterTexture.size];
    monster.physicsBody.velocity = CGVectorMake(0.0f, 0.0f);
    monster.physicsBody.mass = 1.0f;
    monster.physicsBody.dynamic = YES;
    monster.physicsBody.affectedByGravity = NO;
    monster.physicsBody.linearDamping = 1.0f;
    monster.physicsBody.categoryBitMask = kColliderTypeMonster;
    monster.physicsBody.collisionBitMask = 0;
    monster.physicsBody.contactTestBitMask = kColliderTypeCharacter;
    [self.monsters addObject:monster];
    
    //
    // Determine where to spawn the monster along the X axis
    int minX = monster.size.height / 2;
    int maxX = self.frame.size.width - monster.size.height / 2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    
    //
    // Create the monster slightly off-screen along the bottom edge,
    // and along a random position along the X axis as calculated above
    monster.position = CGPointMake(actualX, -monster.size.height);
    [self addChild:monster];
    
    //
    // Determine speed of the monster
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    //
    // Create the actions
    SKAction * actionMove = [SKAction moveTo:CGPointMake(actualX, self.size.height + monster.size.height) duration:actualDuration];
    SKAction * actionMoveDone = [SKAction runBlock:^{
        [monster removeFromParent];
        [self.monsters removeObject:monster];
    }];
    
    // Run action
    [monster runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
}


- (void)_updateMonstersRotations
{
    for (SKSpriteNode *monster in self.monsters) {
        //
        // Calculate the angle for monster
        CGFloat rotationAngle = [self _monsterRotationAngleBasedOnMonsterPosition:monster.position andCharacterPosition:self.characterNode.position];
        
        //
        // Rotate the monster
        monster.zRotation = rotationAngle;
    }
}


- (void)_updateProgressBar
{
    CGFloat progressFactor = self.totalTimePassed / kDurationOfLevelInSeconds;
    [self.progressBarNode repositionCharacterNodeForProgress:progressFactor];
}


- (CGVector)_characterImpulseVectorBasedOnTouchLocation:(CGPoint)touchLocation
{
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
    
    return characterImpulseVector;
}


- (CGFloat)_characterRotationAngleBasedOnTouchLocation:(CGPoint)touchLocation andCharacterPosition:(CGPoint)characterPosition
{
    BOOL touchedLeftSide = touchLocation.x <= CGRectGetMidX(self.frame);
    
    CGFloat gemmaAngle = [self _angleBetweenPositionA:characterPosition andPositionB:touchLocation];
    CGFloat rotationAngle = (touchedLeftSide) ? -gemmaAngle : gemmaAngle;
    
    return rotationAngle;
}


- (CGFloat)_monsterRotationAngleBasedOnMonsterPosition:(CGPoint)monsterPosition andCharacterPosition:(CGPoint)characterPosition
{
    BOOL monsterOnLeftSide = monsterPosition.x <= characterPosition.x;
    
    CGFloat gemmaAngle = [self _angleBetweenPositionA:characterPosition andPositionB:monsterPosition];
    CGFloat rotationAngle = (monsterOnLeftSide) ? -gemmaAngle : gemmaAngle;
    
    return rotationAngle;
}


- (CGFloat)_angleBetweenPositionA:(CGPoint)positionA andPositionB:(CGPoint)positionB
{
    CGFloat opposite = positionA.y - positionB.y;
    CGFloat adjacent = fabs(positionA.x - positionB.x);
    CGFloat alphaAngle = atanf(opposite / adjacent);
    return DegreesToRadians(90.0f) - alphaAngle;
}


- (void)_countTimeBasedOnCurrentTime:(CFTimeInterval)currentTime
{
    // Handle time delta - If frames drop below 60fps
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second has passed since the last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    self.lastCheckTimeInterval += timeSinceLast;
    if (self.lastCheckTimeInterval > 1) {
        self.lastCheckTimeInterval = 0;
        self.totalTimePassed++;
    }
    
    // End game if a certain time period has passed
    if (self.totalTimePassed > kDurationOfLevelInSeconds) {
        [self _land];
    }
}


- (void)_showGameOverAndPlayAgain
{
    self.gameOverLabelNode = [SKLabelNode labelNodeWithFontNamed:@"Marker Felt"];
    self.gameOverLabelNode.text = @"Game Over!";
    self.gameOverLabelNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    self.gameOverLabelNode.fontSize = 60.0f;
    [self addChild:self.gameOverLabelNode];
    
    [self _showPlayAgain];
}


- (void)_showVictoryAndPlayAgain
{
    
    self.victoryLabelNode = [SKLabelNode labelNodeWithFontNamed:@"Marker Felt"];
    self.victoryLabelNode.text = @"Victory!";
    self.victoryLabelNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    self.victoryLabelNode.fontSize = 70.0f;
    [self addChild:self.victoryLabelNode];
    
    [self _showPlayAgain];
}


- (void)_showPlayAgain
{
    self.playAgainButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMidY(self.frame), CGRectGetWidth(self.frame), 100.0f)];
    self.playAgainButton.titleLabel.font = [UIFont fontWithName:@"Marker Felt" size:40.0f];
    [self.playAgainButton setTitle:@"PLAY AGAIN" forState:UIControlStateNormal];
    [self.playAgainButton addTarget:self action:@selector(playAgainButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playAgainButton];
}


- (void)_setupGlobalNodes
{
    //
    // Add background paralax node
    SKSpriteNode *colorBackgroundNode = [SKSpriteNode spriteNodeWithColor:[UIColor hs_colorFromHexString:@"182833"] size:self.frame.size];
    NSArray * imageNames = @[@"bg2", @"bg3", colorBackgroundNode];
    PBParallaxScrolling *parallaxBackgroundNode = [[PBParallaxScrolling alloc] initWithBackgrounds:imageNames size:self.frame.size direction:kPBParallaxBackgroundDirectionUp fastestSpeed:3.0f andSpeedDecrease:kPBParallaxBackgroundDefaultSpeedDifferential];
    parallaxBackgroundNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    parallaxBackgroundNode.zPosition = 20;
    [self addChild:parallaxBackgroundNode];
    self.parallaxBackgroundNode = parallaxBackgroundNode;
    [self.parallaxBackgroundNode changeSpeedsByFactor:0.3f];
    
    //
    // Create and add a foreign planet node
    CGSize foreignPlanetSize = CGSizeMake(CGRectGetWidth(self.frame) * 1.2f, CGRectGetWidth(self.frame) * 1.2f);
    HSPlanetNode *foreignPlanetNode = [HSPlanetNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"foreignPlanet"] size:foreignPlanetSize];
    foreignPlanetNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) + (CGRectGetHeight(foreignPlanetNode.frame) * 0.22f));
    foreignPlanetNode.zPosition = 30;
    [self addChild:foreignPlanetNode];
    self.foreignPlanetNode = foreignPlanetNode;
    
    //
    // Create and add a home planet node
    CGSize homePlanetSize = CGSizeMake(CGRectGetWidth(self.frame) * 1.4f, CGRectGetWidth(self.frame) * 1.4f);
    HSPlanetNode *homePlanetNode = [HSPlanetNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"homePlanet"] size:homePlanetSize];
    homePlanetNode.position = CGPointMake(CGRectGetMidX(self.frame), -CGRectGetHeight(homePlanetNode.frame));
    homePlanetNode.zPosition = 30;
    [self addChild:homePlanetNode];
    self.homePlanetNode = homePlanetNode;
    
    //
    // Create and add a main character node
    HSMainCharacterNode *characterNode = [[HSMainCharacterNode alloc] initWithSceneSize:self.frame];
    characterNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.foreignPlanetNode.frame) + 30.0f);
    characterNode.zPosition = 40;
    [self addChild:characterNode];
    self.characterNode = characterNode;
    
    //
    // Create and add progress bar node
    HSProgressBarNode *progressBarNode = [[HSProgressBarNode alloc] initWithColor:UIColor.clearColor size:CGSizeMake(CGRectGetWidth(self.frame) * 0.07f, CGRectGetHeight(self.frame) - 20.0f)];
    progressBarNode.anchorPoint = CGPointMake(0.0f, 0.5f);
    progressBarNode.position = CGPointMake(10.0f, CGRectGetMidY(self.frame));
    progressBarNode.alpha = 0.0f;
    [self addChild:progressBarNode];
    self.progressBarNode = progressBarNode;
}

@end
