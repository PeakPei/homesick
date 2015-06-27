//
//  UIColor+HSAdditions.m
//  HomeSick
//
//  Created by Damir Stuhec on 27/06/15.
//  Copyright (c) 2015 damirstuhec. All rights reserved.
//

#import "UIColor+HSAdditions.h"

@implementation UIColor (HSAdditions)

+ (UIColor *)hs_randomColor
{
    float r = arc4random() % 12;
    return [UIColor colorWithHue:(30*r)/360 saturation:0.5f brightness:0.8f alpha:1.0f];
}


+ (UIColor *)hs_colorFromHexString:(NSString *)hexString
{
    return [self hs_colorFromHexString:hexString alpha:1.0];
}


+ (UIColor *)hs_colorFromHexString:(NSString *)hexString alpha:(CGFloat)alpha
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    if ([scanner scanHexInt:&rgbValue]) {
		return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:alpha];
	}
	return nil;
}

@end
