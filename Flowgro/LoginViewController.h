//
//  LoginViewController.h
//  Flowgro
//
//  Created by Wade Sellers on 3/25/15.
//  Copyright (c) 2015 Flowhub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Captuvo.h"

@interface LoginViewController : UIViewController <CaptuvoEventsProtocol>

@property (weak, nonatomic) IBOutlet UITextField *badgeIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *errorInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

- (IBAction)unwindToLoginScreen:(UIStoryboardSegue *)segue;
- (void)setupLoginView;

@end
