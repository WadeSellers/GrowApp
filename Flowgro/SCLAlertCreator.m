//
//  SCLAlertCreator.m
//  Flowgro
//
//  Created by Alex Moller on 10/26/15.
//  Copyright © 2015 Flowhub. All rights reserved.
//

#import "SCLAlertCreator.h"

@implementation SCLAlertCreator

+ (SCLAlertView *)createSCLAlertViewWithColor:(UIColor *)color {

  SCLAlertView *alert = [[SCLAlertView alloc] init];
  [alert setBackgroundViewColor:color];
  alert.soundURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/right_answer.mp3", [[NSBundle mainBundle] resourcePath]]];
  
  return alert;
  
}

@end
