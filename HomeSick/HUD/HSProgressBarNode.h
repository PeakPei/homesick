//
//  HSProgressBarNode.h
//  HomeSick
//
//  Created by Damir Stuhec on 28/06/15.
//  Copyright (c) 2015 damirstuhec. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface HSProgressBarNode : SKSpriteNode

@property (nonatomic, strong) SKSpriteNode *characterNode;

- (void)fadeIn;
- (void)fadeOut;
- (void)repositionCharacterNodeForProgress:(CGFloat)progress;

@end
