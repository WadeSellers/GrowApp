//
//  UIImage+Tint.h
//  Pods
//
//  Created by Wade Sellers on 3/6/15.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (Tint)

- (UIImage *)tintedGradientImageWithColor:(UIColor *)tintColor;
- (UIImage *)tintedImageWithColor:(UIColor *)tintColor;

@end
