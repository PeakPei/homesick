//
//  HSPlanetNode.h
//  HomeSick
//
//  Created by Damir Stuhec on 27/06/15.
//  Copyright (c) 2015 damirstuhec. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface HSPlanetNode : SKShapeNode

/**
 Moves the planet up by a given distance and duration
 */
- (void)moveUpByDistance:(CGFloat)distance duration:(CGFloat)duration;

@end
