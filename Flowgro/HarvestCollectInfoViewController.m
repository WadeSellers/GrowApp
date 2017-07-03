//
//  HarvestCollectInfoViewController.m
//  Flowgro
//
//  Created by Wade Sellers on 2/16/15.
//  Copyright (c) 2015 Flowhub. All rights reserved.
//  Please adhere to the coding style
//  Coding style can be found at https://github.com/raywenderlich/objective-c-style-guide


#import "HarvestCollectInfoViewController.h"
#import "MainMenuVC.h"
#import "UIButton+PrimaryButton.h"
#import <QuartzCore/QuartzCore.h>
#import "GTMagBarDevice.h"
#import "NSLogger.h"
#import "SCLAlertView.h"
#import "LoginViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "Constants.h"
#import "FlowhubAPIHandler.h"
#import "Captuvo.h"

NSUInteger currentHarvestPlantCount = 0;

@interface HarvestCollectInfoViewController () <CaptuvoEventsProtocol>

@property (weak, nonatomic) IBOutlet UILabel *barcodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *strainLabel;
@property (weak, nonatomic) IBOutlet UILabel *flagsLabel;
@property (weak, nonatomic) IBOutlet UILabel *daysInFloweringLabel;
@property (weak, nonatomic) IBOutlet UITextField *wetWeightTextField;
@property SCLAlertView *connectingNugAlertWait;
@property UIVisualEffectView *blurredEffectView;
@property CGSize keyboardSize;
@property (strong, nonatomic) UIView *inputAccessoryView;
@property Plant *plant;
@property NSMutableArray *harvestedPlantsMutableArray;
@property (weak, nonatomic) IBOutlet UIButton *harvestPlantButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIView *InstructionCurtain;
@property (weak, nonatomic) IBOutlet UILabel *harvestActivityLabel;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation HarvestCollectInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.harvestPlantButton setExclusiveTouch:YES];
    [self.cancelButton setExclusiveTouch:YES];

    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.spinner setCenter:CGPointMake(self.view.frame.size.width *.5, self.view.frame.size.height *.8)];
    [self.view addSubview:self.spinner]; // spinner is not visible until started


//    //Listen up and act when keyboard shows and hides
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];

    [self.harvestPlantButton setBackgroundImage:Green_Accent_Image forState:UIControlStateNormal];

    //Sets background to our default image
    self.view.backgroundColor = Main_Background_Color;
    [self navBarSetup];

    currentHarvestPlantCount = 0;
    
    [self initCaptuvoSDK];

//THIS IS WHERE YOU CAN MANUALLY INPUT A TAG AND TEST HARVEST
//    [self decoderDataReceived:@"1J4000400266X3X900000016"];
//    self.barcodeLabel.text = @"1A4000400266F3D000000290";
}

-(void)viewWillAppear:(BOOL)animated {

    self.InstructionCurtain.frame = self.view.frame;
    [[Captuvo sharedCaptuvoDevice] addCaptuvoDelegate:self];
    [[Captuvo sharedCaptuvoDevice] startDecoderHardware];
    self.harvestedPlantsMutableArray = [[NSMutableArray alloc] init];;

    self.harvestActivityLabel.text = @"";
}

- (void)viewWillDisappear:(BOOL)animated {
    [[Captuvo sharedCaptuvoDevice] removeCaptuvoDelegate:self];
    [[Captuvo sharedCaptuvoDevice] stopDecoderHardware];
}

- (IBAction)onHarvestPlantButtonPressed:(UIButton *)sender {
    if ([self.wetWeightTextField.text isEqualToString:@""] || ([self.wetWeightTextField.text isEqualToString:@"."])) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert setBackgroundViewColor:Green_Accent_Color];
        alert.soundURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/right_answer.mp3", [[NSBundle mainBundle] resourcePath]]];
        [alert showNotice:self title:nil subTitle:@"Add a weight please" closeButtonTitle:nil duration:2.0f];
        
        return;
    }

    [self.spinner startAnimating];
    self.harvestActivityLabel.alpha = 1.0;
    self.harvestActivityLabel.text = @"Harvesting";

    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *wetWeight = [formatter numberFromString:self.wetWeightTextField.text];
    self.plant.wetWeight = wetWeight;

    NSLog(@"plants wet weight is %@ grams", self.plant.wetWeight);
    
    FlowhubAPIHandler *handler = [FlowhubAPIHandler new];
    [handler harvestPlant:self.plant WithCompletion:^(NSString *errorString) {
        if (errorString) {
            [self.spinner stopAnimating];

            SCLAlertView *alert = [[SCLAlertView alloc] init];
            [alert setBackgroundViewColor:Green_Accent_Color];
            alert.soundURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/right_answer.mp3", [[NSBundle mainBundle] resourcePath]]];
            [alert showNotice:self title:nil subTitle:errorString closeButtonTitle:nil duration:2.0f];
            
            return;
        }

        [self.spinner stopAnimating];
        [self labelQuickFlickToFadeOut:self.harvestActivityLabel WithMessage:@"Plant Successfully Harvested"];
        [self fadeViewIn:self.InstructionCurtain];
        [self.wetWeightTextField resignFirstResponder];

    }];
}

- (IBAction)onCancelButtonPressed:(UIButton *)sender {
    [self.wetWeightTextField resignFirstResponder];
    [self fadeViewIn:self.InstructionCurtain];
}

#pragma mark - Activity Label Helper Methods

- (void)labelQuickFlickToFadeOut: (UILabel *)label WithMessage:(NSString *)message {
    label.text = message;
    [UIView animateWithDuration:3.0 animations:^{
        label.alpha = 0.0;
    }];
}

#pragma mark - NavBar

- (void)navBarSetup {
    self.navigationItem.title = @"HARVEST PLANTS";
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    //Makes nav bar translucent
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;

}

//#pragma mark - Keyboard Helper Methods
//- (void)keyboardDidShow:(NSNotification *)notification {
//    self.keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//
//    [self.view setFrame:CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height - self.keyboardSize.height)];
//}
//
//-(void)keyboardDidHide:(NSNotification *)notification {
//    [self.view setFrame:CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height)];
//}

#pragma mark - Captuvo Delegate Methods
- (void)initCaptuvoSDK {
    [[Captuvo sharedCaptuvoDevice] addCaptuvoDelegate:self];
    [[Captuvo sharedCaptuvoDevice] startDecoderHardware];
    [[Captuvo sharedCaptuvoDevice] requestBatteryVoltage];
    [[Captuvo sharedCaptuvoDevice] requestChargeStatus];
}

- (void)decoderDataReceived:(NSString *)data {

    [self.spinner startAnimating];
    [[Captuvo sharedCaptuvoDevice] disableDecoderScanning];
    
    NSLog(@"decoderDataReceived: %@", data);
    self.barcodeLabel.text = data;
    self.wetWeightTextField.text = nil;
    
    FlowhubAPIHandler *handler = [[FlowhubAPIHandler alloc] init];
    [handler fetchOnePlant:data WithCompletion:^(NSDictionary *plantJSON, NSError *errorString) {
        [self.spinner stopAnimating];

        if (errorString) {
            [self.wetWeightTextField resignFirstResponder];

            SCLAlertView *alert = [[SCLAlertView alloc] init];
            [alert setBackgroundViewColor:Green_Accent_Color];
            alert.soundURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/right_answer.mp3", [[NSBundle mainBundle] resourcePath]]];
            [alert showNotice:self title:nil subTitle:@"Plant Not Found" closeButtonTitle:nil duration:2.0f];
            self.barcodeLabel.text = @"Scan Tag to Harvest Plant";
            
            double delayInSeconds = 1.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                //code to be executed on the main queue after delay
                [[Captuvo sharedCaptuvoDevice] enableDecoderScanning];

                if (self.InstructionCurtain.alpha != 1.0) {
                    [self fadeViewIn:self.InstructionCurtain];
                }
            });

            return;
        } else {
            self.plant = [[Plant alloc] initWithJSON:plantJSON];
            
            if (self.plant.harvestId) {
                self.wetWeightTextField.text = [NSString stringWithFormat:@"%.2f", [self.plant.wetWeight floatValue]];

                [self fadeViewOut:self.InstructionCurtain];

                [self.wetWeightTextField becomeFirstResponder];

                [[Captuvo sharedCaptuvoDevice] enableDecoderScanning];

                return;

            } else if (![self.plant.state isEqualToString:@"flowering"]) {
                SCLAlertView *alert = [[SCLAlertView alloc] init];
                [alert setBackgroundViewColor:Green_Accent_Color];
                alert.soundURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/right_answer.mp3", [[NSBundle mainBundle] resourcePath]]];
                [alert showNotice:self title:@"Invalid State" subTitle:@"Plant not currently flowering" closeButtonTitle:nil duration:1.5f];
                
                double delayInSeconds = 1.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    //code to be executed on the main queue after delay
                    [[Captuvo sharedCaptuvoDevice] enableDecoderScanning];
                });
                
                return;
            }

            self.barcodeLabel.text = self.plant.tagId;
            self.strainLabel.text = [NSString stringWithFormat:@"Strain: %@", self.plant.strain];
            self.flagsLabel.text = [NSString stringWithFormat:@"Flags: %@", [self.plant.flags componentsJoinedByString:@", "]];
            self.daysInFloweringLabel.text = [NSString stringWithFormat:@"Days in flowering: %ld", (long)self.plant.daysInState];

            if (self.InstructionCurtain.alpha != 1.0) {
                [self refreshInfoLabels];
            } else {
                [self fadeViewOut:self.InstructionCurtain];
                [self.wetWeightTextField becomeFirstResponder];
            }


            double delayInSeconds = 1.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                //code to be executed on the main queue after delay
                [[Captuvo sharedCaptuvoDevice] enableDecoderScanning];
            });
        }
    }];
}

#pragma mark - info Label's Helper Methods
- (void)refreshInfoLabels {
    [UIView animateWithDuration:0.5 animations:^{
        self.barcodeLabel.alpha = 0.2;
        self.strainLabel.alpha = 0.2;
        self.flagsLabel.alpha = 0.2;
        self.daysInFloweringLabel.alpha = 0.2;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            self.barcodeLabel.text = self.plant.tagId;
            self.strainLabel.text = [NSString stringWithFormat:@"Strain: %@", self.plant.strain];
            self.flagsLabel.text = [NSString stringWithFormat:@"Flags: %@", [self.plant.flags componentsJoinedByString:@", "]];
            self.daysInFloweringLabel.text = [NSString stringWithFormat:@"Days in flowering: %ld", (long)self.plant.daysInState];

            self.barcodeLabel.alpha = 1.0;
            self.strainLabel.alpha = 1.0;
            self.flagsLabel.alpha = 1.0;
            self.daysInFloweringLabel.alpha = 1.0;
        }];
    }];
}

#pragma mark - instructionCurtain animation methods
- (void)fadeViewOut: (UIView *)view {
    [UIView animateWithDuration:0.5 animations:^{
        view.alpha = 0.0;
    } completion:^(BOOL finished) {
        view.hidden = YES;
    }];
}

- (void)fadeViewIn: (UIView *)view {
    [UIView animateWithDuration:0.5 animations:^{
        view.hidden = NO;
        view.alpha = 1.0;
    } completion:^(BOOL finished) {
        //Place code here to happen after view is displayed
    }];
}

- (void)decoderReady {
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [[Captuvo sharedCaptuvoDevice] enableDecoderBeeperForGoodRead:YES persistSetting:NO] ;
        
        //setting decoder trigger click status.
        [[Captuvo sharedCaptuvoDevice]requestDecoderTriggerClickStatus];
        
        //setting 5 seconds after will auto stop the aimer light.
        [[Captuvo sharedCaptuvoDevice]setDecoderSerialTriggerTimeoutInMilliSeconds:5000 persistSetting:NO];
    });
}

- (void)captuvoConnected {
    NSLog(@"Captuvo Connected");
    [[Captuvo sharedCaptuvoDevice] startDecoderHardware];
}

- (void)captuvoDisconnected {
    NSLog(@"Captuvo is DISconnected");
    [[Captuvo sharedCaptuvoDevice] stopDecoderHardware];
}

@end
