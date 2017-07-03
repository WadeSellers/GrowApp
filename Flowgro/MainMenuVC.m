//
//  ViewController.m
//  Flowgro
//
//  Created by Wade Sellers on 12/12/14.
//  Copyright (c) 2014 Flowhub. All rights reserved.
//  Please adhere to the coding style
//  Coding style can be found at https://github.com/raywenderlich/objective-c-style-guide


#import "MainMenuVC.h"
#import "LoginViewController.h"
#import "MoveDestroyVC.h"
#import <QuartzCore/QuartzCore.h>
#import "UIButton+PrimaryButton.h"
#import "UIImage+Tint.h"
#import "NSLogger.h"
#import "Constants.h"
#import "SCLAlertView.h"
#import "FlowhubAPIHandler.h"
#import "SCLAlertCreator.h"



@interface MainMenuVC ()

@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *FlowhubLogoCenter;
@property(strong) NSDictionary *loginCredentials;
@property NSMutableArray *roomsArray;
@property (strong, nonatomic) UIButton *cloneBurgerBarButton;

@end

@implementation MainMenuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMainMenuScreen];
}

- (void)setupMainMenuScreen {
    [self.movePlantsButton setExclusiveTouch:YES];
    [self.destroyPlantsButton setExclusiveTouch:YES];
    [self.lookupPlantsButton setExclusiveTouch:YES];
    [self.harvestPlantsButton setExclusiveTouch:YES];

    self.view.backgroundColor = Main_Background_Color;
    [self introAnimations];
    self.userGreetingLabel.text = [NSString stringWithFormat:@"Hello, %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"name"]];
    [self.view addSubview:self.burgerBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [self navBarSetup];
    self.operation = @"";
}

- (void)viewDidAppear:(BOOL)animated {

}

- (void)viewWillDisappear:(BOOL)animated {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    [[self navigationItem] setBackBarButtonItem:backButton];
}

- (IBAction)anyButtonTapped:(UIButton *)sender {
    if (sender == self.movePlantsButton) {
        self.operation = @"Move";
    } else if (sender == self.destroyPlantsButton) {
        self.operation = @"Destroy";
    } else if (sender == self.lookupPlantsButton) {
        self.operation = @"Lookup";
    } else if (sender == self.harvestPlantsButton) {
        self.operation = @"Harvest";
    } else if (sender == self.cloneBurgerBarButton) {
        self.operation = @"Clone";
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton *)sender
{
    if ([self.operation isEqualToString:@"Move"]) {
        MoveDestroyVC *movePlantsViewController = [segue destinationViewController];
        movePlantsViewController.operation = @"move";
    }

    else if ([self.operation isEqualToString:@"Destroy"]) {
        MoveDestroyVC *movePlantsViewController = [segue destinationViewController];
        movePlantsViewController.operation = @"destroy";
    }

    else if ([self.operation isEqualToString:@"Clone"]) {
      MoveDestroyVC *movePlantsViewController = [segue destinationViewController];
      movePlantsViewController.operation = @"clone";
    }

    else if ([self.operation isEqualToString:@"Logout"]) {
        
    }
}

- (IBAction)unwindToHomeScreen:(UIStoryboardSegue *)segue {

}

- (void)navBarSetup {
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBarTintColor:Nav_Bar_Background_Color];
    UIImage *FlowhubImage = [UIImage imageNamed:@"flowhub_white"];
    UIImageView *FlowhubImageimageView = [[UIImageView alloc] initWithImage:FlowhubImage];
    self.navigationItem.titleView = FlowhubImageimageView;
    self.navigationItem.leftBarButtonItem.title = @"Main";

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"FlowhubLogoNavBar"] style:UIBarButtonItemStylePlain target:self action:@selector(onBurgerMenuButtonPressed:)];
    self.navigationItem.leftBarButtonItem = item;

    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(onLogoutButtonPressed)];
    self.navigationItem.rightBarButtonItem = logoutButton;
  
}

- (void)onLogoutButtonPressed {
    [self performSegueWithIdentifier:@"unwindToLoginScreen" sender:self];
}

- (void)onBurgerMenuButtonPressed:(id)sender {
    [self animateBurgerBarInOut];
    NSLog(@"%@", self.burgerBar);
}

//This needs refactoring
- (void)introAnimations {
    [self.movePlantsButton setupButton:@"Move" setEnabled:YES setVisible:NO];
    [self.destroyPlantsButton setupButton:@"Destroy" setEnabled:YES setVisible:NO];
    [self.lookupPlantsButton setupButton:@"Lookup" setEnabled:YES setVisible:NO];
    [self.harvestPlantsButton setupButton:@"Harvest" setEnabled:YES setVisible:NO];
    self.FlowhubLogoCenter.alpha = 0;
    self.instructionLabel.alpha = 0;
  
    [UIView animateWithDuration:0.25
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
         self.FlowhubLogoCenter.alpha = 1;
     } completion:^(BOOL finished) {
        if (finished) {
         [UIView animateWithDuration:0.5
                               delay:0
                             options:UIViewAnimationOptionCurveEaseIn
                          animations:^ {
              [self.movePlantsButton fadeInWithDuration:0.25 delay:0.0];
              [self.destroyPlantsButton fadeInWithDuration:0.25 delay:0.1];
              [self.lookupPlantsButton fadeInWithDuration:0.25 delay:0.2];
              [self.harvestPlantsButton fadeInWithDuration:0.25 delay:0.3];
          } completion:^(BOOL finished) {
              if (finished) {
                [UIView animateWithDuration:0.5
                                      delay:0.0
                                        options:UIViewAnimationOptionCurveEaseIn
                                        animations:^ {
                                        self.instructionLabel.alpha = 1;
                }
                                 completion:nil];
              }
            }];
         }
       }];
}

- (UIView *)burgerBar {
    if (!_burgerBar) {
        _burgerBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
        _burgerBar.backgroundColor = Nav_Bar_Background_Color;
    }
    return _burgerBar;
}

- (void)animateBurgerBarInOut {
    if (self.burgerBar.frame.size.height == 0) {

        [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:.4 initialSpringVelocity:.6 options:UIViewAnimationOptionCurveEaseInOut animations:^ {
            _burgerBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.instructionLabel.frame.origin.y);
            [self.burgerBar addSubview:self.cloneBurgerBarButton];
         }
              completion:^(BOOL finished) {
              NSLog(@"Animation Finished");
              }];
      
    } else {
        [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:.4 initialSpringVelocity:.6 options:UIViewAnimationOptionCurveEaseInOut animations:^ {
            [self.cloneBurgerBarButton removeFromSuperview];
            _burgerBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0);
         }
              completion:^(BOOL finished) {
              NSLog(@"Animation Finished");
            //[self.burgerBar addSubview:self.cloneBurgerBarButton];
              }];
    }
}

- (UIButton *)cloneBurgerBarButton {
  if (!_cloneBurgerBarButton) {
      
    _cloneBurgerBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 175, 45)];
    _cloneBurgerBarButton.backgroundColor = Main_Background_Color;
    [[_cloneBurgerBarButton layer] setBorderWidth:1.0f];
    [[_cloneBurgerBarButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    [_cloneBurgerBarButton setTitle:@"Clone" forState:UIControlStateNormal];
    _cloneBurgerBarButton.center = CGPointMake(self.burgerBar.center.x, self.burgerBar.center.y);

    [_cloneBurgerBarButton addTarget:self
                              action:@selector(onClonePlantsButtonTapped)
                    forControlEvents:UIControlEventTouchUpInside];
  }
  
    return _cloneBurgerBarButton;
}

- (void)onClonePlantsButtonTapped {
    [self animateBurgerBarInOut];
    self.operation = @"Clone";
    [self performSegueWithIdentifier:@"segueMainToClone" sender:self];
}

- (IBAction)unwindToMainMenu:(UIStoryboardSegue *)segue {
    SCLAlertView *alert = [SCLAlertCreator createSCLAlertViewWithColor:Green_Accent_Color];
    [alert showNotice:self title:@"Thank You" subTitle:@"Your clones have been added"
     closeButtonTitle:nil duration:2.0f];
}

@end


