//
//  UIButton+PrimaryButton.h
//  Flowgro
//
//  Created by Wade Sellers on 1/27/15.
//  Copyright (c) 2015 Flowhub. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (PrimaryButton)

- (void)setupButton:(NSString *)title setEnabled:(BOOL)enabled setVisible:(BOOL)visible;

- (void)fadeInWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;

- (void)fadeOutWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;

- (void)pulsateBorderWithStartValue:(float)start andEndValue:(float)end andDuration:(CFTimeInterval)duration;

- (void) enableWithPresets;

- (void) disableWithPresets;

@end
