//
//  SCLAlertCreator.h
//  Flowgro
//
//  Created by Alex Moller on 10/26/15.
//  Copyright © 2015 Flowhub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCLAlertView.h"
#import "Constants.h"


@interface SCLAlertCreator : SCLAlertView


+ (SCLAlertView *)createSCLAlertViewWithColor:(UIColor *)color;

@end
