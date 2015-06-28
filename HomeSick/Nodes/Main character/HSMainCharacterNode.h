//
//  HSMainCharacter.h
//  HomeSick
//
//  Created by Damir Stuhec on 27/06/15.
//  Copyright (c) 2015 damirstuhec. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface HSMainCharacterNode : SKSpriteNode

- (instancetype)initWithSceneSize:(CGRect)sceneSize;
- (void)prepareForFallingWithDescentByDistance:(CGFloat)distance;
- (void)prepareForLandingWithDescentByDistance:(CGFloat)distance;
- (void)rotateByAngle:(CGFloat)angle;

@end
