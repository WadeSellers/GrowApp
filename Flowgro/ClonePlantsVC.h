//
//  ClonePlantsVC.h
//  Flowgro
//
//  Created by Wade Sellers on 9/4/15.
//  Copyright (c) 2015 Flowhub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Plant.h"

@interface ClonePlantsVC : UIViewController
@property NSMutableArray *scannedPlantsArray;
@property NSInteger numberOfClones;
@property Plant *motherPlant;

- (NSArray *)getEncondedUserRooms;
- (Plant *)getMotherPlant;


@end
