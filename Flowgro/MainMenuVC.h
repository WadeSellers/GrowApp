//
//  ViewController.h
//  Flowgro
//
//  Created by Wade Sellers on 12/12/14.
//  Copyright (c) 2014 Flowhub. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainMenuVC : UIViewController <NSURLConnectionDelegate>
@property (weak, nonatomic) IBOutlet UIButton *movePlantsButton;
@property (weak, nonatomic) IBOutlet UIButton *destroyPlantsButton;
@property (weak, nonatomic) IBOutlet UIButton *lookupPlantsButton;
@property (weak, nonatomic) IBOutlet UIButton *harvestPlantsButton;
@property (weak, nonatomic) IBOutlet UILabel *userGreetingLabel;
@property (strong, nonatomic) UIView *burgerBar;
@property NSString *operation;



@end

