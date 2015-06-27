//
//  UIColor+HSAdditions.h
//  HomeSick
//
//  Created by Damir Stuhec on 27/06/15.
//  Copyright (c) 2015 damirstuhec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HSAdditions)

+ (UIColor *)hs_randomColor;
+ (UIColor *)hs_colorFromHexString:(NSString *)hexString;
+ (UIColor *)hs_colorFromHexString:(NSString *)hexString alpha:(CGFloat)alpha;

@end
