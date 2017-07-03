//
//  NumberOfClonesVC.h
//  Flowgro
//
//  Created by Alex Moller on 9/24/15.
//  Copyright © 2015 Flowhub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Plant.h"

@interface NumberOfClonesVC : UIViewController

@property NSMutableArray *scannedPlantsArray;
@property (weak, nonatomic) IBOutlet UITextField *numberOfClonesTextField;

- (Plant *)getFirstPlantObject;

- (BOOL)checkForCorrectNumberOfClones;

@end
