//
//  LoginViewController.m
//  Flowgro
//
//  Created by Wade Sellers on 3/25/15.
//  Copyright (c) 2015 Flowhub. All rights reserved.
//


#import "LoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "FlowhubAPIHandler.h"
#import "NSLogger.h"
#import "Constants.h"
#import "SCLAlertView.h"
#import "Captuvo.h"
#import "SCLAlertCreator.h"

@interface LoginViewController ()


//Properties regarding Griffin Olli
@property (strong, nonatomic) NSTimer *batteryStatusPollingTimer;

@property NSNumber *loginAttempts;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLoginView];
}

- (void)setupLoginView {
    self.versionLabel.text = [NSString stringWithFormat:@"Version %@ © 2015 Flowhub, LLC. All rights reserved.", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"Green_Accent_Image"] forState:UIControlStateNormal];
    [self.loginButton setExclusiveTouch:YES];
    self.badgeIDTextField.borderStyle = UITextBorderStyleLine;
    self.passwordTextField.borderStyle = UITextBorderStyleLine;
    [self.badgeIDTextField.layer setBorderColor:Button_Border_Color];
    [self.passwordTextField.layer setBorderColor:Button_Border_Color];
    self.badgeIDTextField.layer.borderWidth = 1.0;
    self.passwordTextField.layer.borderWidth = 1.0;
  
    self.errorInfoLabel.text = @"";
  
    self.badgeIDTextField.text = @"";
    self.passwordTextField.text = @"";
  
//    self.badgeIDTextField.text = @"M72364";
//    self.passwordTextField.text = @"password1234!";
    [self initCaptuvoSDK];
}

-(void)viewDidAppear:(BOOL)animated {
    //[self checkForUpdate];
 
}



- (void)viewWillAppear:(BOOL)animated {
    [[Captuvo sharedCaptuvoDevice] addCaptuvoDelegate:self];

    self.navigationController.navigationBarHidden = YES;

}

- (void)viewWillDisappear:(BOOL)animated {
    [[Captuvo sharedCaptuvoDevice] removeCaptuvoDelegate:self];
    [[Captuvo sharedCaptuvoDevice] stopDecoderHardware];
}

#pragma mark - Login
- (IBAction)onLoginButtonPressed:(id)sender {
    [self.badgeIDTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
      
    //Badges starting with d will be set for Demo environment
    if ([self.badgeIDTextField.text hasPrefix:@"D"] || [self.badgeIDTextField.text hasPrefix:@"d"]) {
        NSString *serverToUse = @"demo";
        [[NSUserDefaults standardUserDefaults] setObject:serverToUse forKey:@"server"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        //Any other badge id besides the letter D will function in the production environment
        NSString *serverToUse = @"production";
        [[NSUserDefaults standardUserDefaults] setObject:serverToUse forKey:@"server"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if ([self.badgeIDTextField.text isEqualToString:@""] || [self.passwordTextField.text isEqualToString:@""]) {
        self.errorInfoLabel.text = @"Enter Login Credentials";
        return;
    }
  
    [self loginUser];

}

-(void)loginUser {
    SCLAlertView *alert = [SCLAlertCreator createSCLAlertViewWithColor:[UIColor whiteColor]];
    alert.backgroundType = Blur;
    alert.customViewColor = Green_Accent_Color;
    [alert showWaiting:self title:@"Logging In..." subTitle:nil closeButtonTitle:nil duration:0.0f];
    
    FlowhubAPIHandler *loginCall = [[FlowhubAPIHandler alloc] init];
    [loginCall loginWithBadgeID:self.badgeIDTextField.text andPassword:self.passwordTextField.text WithCompletion:^(NSString *error) {
      
      if (!error) {
        
        [alert hideView];
        //setup alert for grabbing rooms
        SCLAlertView *roomAlert = [SCLAlertCreator createSCLAlertViewWithColor:[UIColor whiteColor]];
        roomAlert.backgroundType = Blur;
        roomAlert.customViewColor = Green_Accent_Color;
        [roomAlert showWaiting:self title:@"Grabbing Grow Rooms" subTitle:nil closeButtonTitle:nil duration:0.0f];
        
        FlowhubAPIHandler *getRoomCall = [FlowhubAPIHandler new];
        [getRoomCall getUsersRoomsWithCompletion:^(NSArray *roomArray, NSString *errorString) {
          [roomAlert hideView];
          if (roomArray) {
            [self performSegueWithIdentifier:@"segueToMainMenu" sender:self];
            
          }
          
          if (errorString) {
              self.errorInfoLabel.text = @"Couldn't Retrieve Rooms. Use webApp to setup your grow";
            
          }
          
        }];
        
//          return YES;
        
      }
      
      else {
        
        if ([error isEqualToString:@"404"] || [error isEqualToString:@"428"]) {
          [alert hideView];
          self.passwordTextField.text = @"";
          self.errorInfoLabel.text = @"Oops. Incorrect Badge or Pass";
          
        }
        
        else if ([error isEqualToString:@"512"]) {
          [alert hideView];
          self.passwordTextField.text = @"";
          self.errorInfoLabel.text = @"Account Locked. See your manager.";
          
        }
        
        else {
          [alert hideView];
          self.passwordTextField.text = @"";
          self.errorInfoLabel.text = @"YIKES! We Goofed up. Login Again";
          
        }
        
      }
      
    }];
  
}

#pragma mark - Check for Updates
//-(void)checkForUpdate {
//    NSLog(@"Checking for update");
//    FlowhubAPIHandler *handler = [FlowhubAPIHandler new];
//    [handler getCurrentVersionWithCompletion:^(Version *versionObject, NSString *errorString) {
//
//    NSLog(@"database current version: %@", versionObject.versionNumber);
//    NSLog(@"internal version number: %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]);
//
//      if ([versionObject.versionNumber isEqualToString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]] || errorString) {
//        return;
//      } else {
//        
//          SCLAlertView *versionUpdateAlert = [[SCLAlertView alloc] init];
//          [versionUpdateAlert setBackgroundViewColor:[UIColor whiteColor]];
//          versionUpdateAlert.backgroundType = Blur;
//          versionUpdateAlert.customViewColor = Green_Accent_Color;
//          [versionUpdateAlert addButton:@"Exit & Install" actionBlock:^{
//
//              NSURL *versionUrl = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@", versionObject.versionUrl]];
//              //NSURL *theURL = [[NSURL alloc] initWithString:@"itms-services://?action=download-manifest&url=https://dl.dropboxusercontent.com/s/4r1w2psjs36jgdh/wirelessappdist.plist"];
//              [[UIApplication sharedApplication] openURL:versionUrl];
//              //This line will break the app by exit out of the Main Thread.  The speed allows for the home screen to show the above triggered install alert from Apple.
//  //                exit(0);
//          }];
//          [versionUpdateAlert showWaiting:self title:@"GrowApp Update" subTitle:@"Tap below to exit & Install update" closeButtonTitle:nil duration:0.0f];
//      }
//    }];
//}

#pragma mark - Unwind Segue
- (IBAction)unwindToLoginScreen:(UIStoryboardSegue *)segue {
    NSLog(@"unwound back to Login Screen");
}

#pragma mark - Captuvo Delegate Methods
- (void)initCaptuvoSDK {
    [[Captuvo sharedCaptuvoDevice] addCaptuvoDelegate:self];
    [[Captuvo sharedCaptuvoDevice] requestBatteryVoltage];
    [[Captuvo sharedCaptuvoDevice] requestChargeStatus];
}

- (void)captuvoConnected {
    NSLog(@"Captuvo Connected");
    [[Captuvo sharedCaptuvoDevice] getBatteryStatus];
    NSLog(@"batter status: %u", [[Captuvo sharedCaptuvoDevice] getBatteryStatus]);
}

- (void)captuvoDisconnected {
    NSLog(@"Captuvo is DISconnected");
}



@end
