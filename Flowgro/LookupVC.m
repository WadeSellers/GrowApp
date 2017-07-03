//
//  LookupPlantsViewController.m
//  Flowgro
//
//  Created by Wade Sellers on 12/12/14.
//  Copyright (c) 2014 Flowhub. All rights reserved.
//  Please adhere to the coding style
//  Coding style can be found at https://github.com/raywenderlich/objective-c-style-guide
//

#import "LookupVC.h"
#import "FlagPlantViewController.h"
#import "MoveDestroyVC.h"
#import "MoveWhereVC.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import "UIButton+PrimaryButton.h"
#import "SCLAlertView.h"
#import "LoginViewController.h"
#import "NSLogger.h"
#import "FlowhubAPIHandler.h"
#import "Constants.h"
#import "AFNetworking.h"
#import "Captuvo.h"
#import "DestroyReasonVC.h"



@interface LookupVC () <UISearchBarDelegate, UIAlertViewDelegate, CaptuvoEventsProtocol>
@property (weak, nonatomic) IBOutlet UILabel *barcodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (weak, nonatomic) IBOutlet UIButton *moveButton;
@property (weak, nonatomic) IBOutlet UIButton *destroyButton;
@property (weak, nonatomic) IBOutlet UIButton *flagButton;
@property UIVisualEffectView *blurredEffectView;

@property (weak, nonatomic) IBOutlet UIImageView *placeholderImage;
@property NSMutableArray *scannedPlantsArray;
@property NSMutableArray *lookupResults;

@property SCLAlertView *alert;
@property (weak, nonatomic) IBOutlet UIImageView *imagePlaceholder;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *allLabels;

@property (weak, nonatomic) IBOutlet UILabel *licenseLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomLabel;
@property (weak, nonatomic) IBOutlet UILabel *strainLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *speciesLabel;
@property (weak, nonatomic) IBOutlet UILabel *flagLabel;

@property UITextField *destroyReasonTextField;

@property Plant *plant;

@end

@implementation LookupVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.moveButton setExclusiveTouch:YES];
    [self.destroyButton setExclusiveTouch:YES];
    [self.flagButton setExclusiveTouch:YES];
    [self.moveButton setBackgroundImage:Green_Accent_Image forState:UIControlStateNormal];
    [self.flagButton setBackgroundImage:Green_Accent_Image forState:UIControlStateNormal];
    [self.destroyButton setBackgroundImage:Pink_Accent_Image forState:UIControlStateNormal];
    
    self.licenseLabel.alpha = 0;
    self.roomLabel.alpha = 0;
    self.strainLabel.alpha = 0;
    self.stateLabel.alpha = 0;
    self.startDateLabel.alpha = 0;
    self.speciesLabel.alpha = 0;
    self.flagLabel.alpha = 0;
    self.barcodeLabel.alpha = 0;
    self.imagePlaceholder.alpha = 0;

    self.view.backgroundColor = Main_Background_Color;
    [self buttonInitialSetup];
    self.scannedPlantsArray = [NSMutableArray new];
    self.lookupResults = [NSMutableArray new];
    
    [self initCaptuvoSDK];

    //Enter a tag here to simulate a scan
    //[self decoderDataReceived:@"1J4000400266X3X900000016"];
}

- (void) viewWillAppear:(BOOL)animated {
    [self navBarSetup];
    [self introAnimations];
    [[Captuvo sharedCaptuvoDevice] addCaptuvoDelegate:self];
    [[Captuvo sharedCaptuvoDevice] startDecoderHardware];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[Captuvo sharedCaptuvoDevice] removeCaptuvoDelegate:self];
    [[Captuvo sharedCaptuvoDevice] stopDecoderHardware];
}

- (void)checkForScannedItems {
    if (self.scannedPlantsArray.count > 0) {
        [self buttonsActivate];

        self.moveButton.enabled = YES;
        [[self.moveButton layer] setBorderColor:[UIColor whiteColor].CGColor];
        self.destroyButton.enabled = YES;
        [[self.destroyButton layer] setBorderColor:[UIColor whiteColor].CGColor];
        self.flagButton.enabled = YES;
        [[self.flagButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    } else {
        self.moveButton.enabled = NO;
        [[self.moveButton layer] setBorderColor:[UIColor grayColor].CGColor];
        self.destroyButton.enabled = NO;
        [[self.destroyButton layer] setBorderColor:[UIColor grayColor].CGColor];
        self.flagButton.enabled = NO;
        [[self.flagButton layer] setBorderColor:[UIColor grayColor].CGColor];
    }
}


- (IBAction)onMoveButtonPressed:(id)sender {

}

- (IBAction)onDestroyButtonPressed:(id)sender {

}

- (void)buttonInitialSetup {
    [self.moveButton setHidden:YES];
    [self.destroyButton setHidden:YES];
    [self.flagButton setHidden:YES];
}

- (void)buttonsActivate {
    [self.moveButton setHidden:NO];
    [self.destroyButton setHidden:NO];
    [self.flagButton setHidden:NO];

    [[self.moveButton layer] setCornerRadius:1.0];
    self.moveButton.clipsToBounds = YES;
    [[self.destroyButton layer] setCornerRadius:1.0];
    self.moveButton.clipsToBounds = YES;
    [[self.flagButton layer] setCornerRadius:1.0];
    self.moveButton.clipsToBounds = YES;

    self.moveButton.alpha = 0;
    [[self.moveButton layer] setBorderColor:[UIColor grayColor].CGColor];
    [[self.moveButton layer] setBorderWidth:1.0f];
    self.moveButton.enabled = NO;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{ self.moveButton.alpha = 1;
    }
    completion:nil];

    self.destroyButton.alpha = 0;
    [[self.destroyButton layer] setBorderColor:[UIColor grayColor].CGColor];
    [[self.destroyButton layer] setBorderWidth:1.0f];
    self.destroyButton.enabled = NO;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{ self.destroyButton.alpha = 1;
    }
    completion:nil];

    self.flagButton.alpha = 0;
    [[self.flagButton layer] setBorderColor:[UIColor grayColor].CGColor];
    [[self.flagButton layer] setBorderWidth:1.0f];
    self.flagButton.enabled = NO;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{ self.flagButton.alpha = 1;
    }
    completion:nil];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromLookupToMove"]) {
        MoveWhereVC *moveWhereViewController = segue.destinationViewController;
        moveWhereViewController.numberScanned = self.scannedPlantsArray.count;
        moveWhereViewController.plantsToMoveArray = self.scannedPlantsArray;
    } else if ([segue.identifier isEqualToString:@"fromLookupToFlag"]) {
        FlagPlantViewController *flagViewController = segue.destinationViewController;
        flagViewController.numberScanned = self.scannedPlantsArray.count;
        flagViewController.scannedPlantsArray = self.scannedPlantsArray;
    } else if ([segue.identifier isEqualToString:@"fromLookupToDestroy"]) {
        DestroyReasonVC *destroyReasonsViewController = segue.destinationViewController;
        destroyReasonsViewController.plantsToDestroyArray = self.scannedPlantsArray;
    }
}


- (void)hideAllLabels {
    for (UILabel *label in self.allLabels) {
        label.alpha = 0;
    }
}

- (void)introAnimations {
    self.instructionLabel.textColor = [UIColor whiteColor];
    self.instructionLabel.alpha = .5;
    self.instructionLabel.clipsToBounds = YES;

    [UIView animateWithDuration:.75
                          delay:0
                        options: UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat
                     animations:^
                    {
                        self.instructionLabel.alpha = 1;

                    }
                     completion:nil];
}

#pragma mark - NavBar

- (void)navBarSetup {
    self.navigationItem.title = @"LOOKUP";
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    //Makes nav bar translucent
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)resetLookupScreen {
    self.licenseLabel.alpha = 0;
    self.roomLabel.alpha = 0;
    self.strainLabel.alpha = 0;
    self.stateLabel.alpha = 0;
    self.startDateLabel.alpha = 0;
    self.speciesLabel.alpha = 0;
    self.flagLabel.alpha = 0;
    self.barcodeLabel.alpha = 0;
    self.imagePlaceholder.alpha = 0;
    self.instructionLabel.hidden = NO;
    [self buttonInitialSetup];
    
    [self.scannedPlantsArray removeLastObject];
}

#pragma mark - Captuvo Delegate Methods
- (void)initCaptuvoSDK {
    [[Captuvo sharedCaptuvoDevice] addCaptuvoDelegate:self];
    [[Captuvo sharedCaptuvoDevice] startDecoderHardware];
    [[Captuvo sharedCaptuvoDevice] requestBatteryVoltage];
    [[Captuvo sharedCaptuvoDevice] requestChargeStatus];
}

- (void)decoderDataReceived:(NSString *)data {
    NSLog(@"decoderDataReceived: %@", data);
    //Get the barcode scan data from the notification
    NSString *barcodeTagNumber = data;
    
    // Log the received barcode data.
    NSLog(@"Received barcode scan data:");
    NSLog(@"\t TagNumber: %@", barcodeTagNumber);
    
    [self resetLookupScreen];
    
    FlowhubAPIHandler *handler = [[FlowhubAPIHandler alloc] init];
    [handler fetchOnePlant:barcodeTagNumber WithCompletion:^(NSDictionary *plantJSON, NSError *errorString) {
        if (errorString) {
            [[Captuvo sharedCaptuvoDevice] disableDecoderScanning];
            self.alert = [[SCLAlertView alloc] init];
            self.alert.backgroundType = Blur;
            self.alert.soundURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/right_answer.mp3", [[NSBundle mainBundle] resourcePath]]];
            [self.alert setShouldDismissOnTapOutside:YES];
            [self.alert setButtonsTextFontFamily:@"HelveticaNeue-Light" withSize:19.0];
            [self.alert setBackgroundViewColor:Green_Accent_Color];
            [self.alert showNotice:self title:@"Plant Not Found" subTitle:@"Possibly Destroyed/Harvested?" closeButtonTitle:nil duration:1.5];

            double delayInSeconds = 1.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                //code to be executed on the main queue after delay
                [[Captuvo sharedCaptuvoDevice] enableDecoderScanning];
            });
        } else {
            self.plant = [[Plant alloc] initWithJSON:plantJSON];
            self.scannedPlantsArray = [[NSMutableArray alloc] initWithObjects:self.plant, nil];
            
            [self checkForScannedItems];            
            //TURN LABELS ON
            self.instructionLabel.hidden = YES;
            self.licenseLabel.alpha = 1;
            self.roomLabel.alpha = 1;
            self.strainLabel.alpha = 1;
            self.stateLabel.alpha = 1;
            self.startDateLabel.alpha = 1;
            self.speciesLabel.alpha = 1;
            self.flagLabel.alpha = 1;
            self.barcodeLabel.alpha = 1;
            self.imagePlaceholder.alpha = 1;
            
            //ASSIGN LABELS
            self.barcodeLabel.text = self.plant.tagId;
            self.licenseLabel.text = [NSString stringWithFormat:@"License: %@", self.plant.license];
            self.roomLabel.text = [NSString stringWithFormat:@"Location: %@", self.plant.currentRoomName];
            self.strainLabel.text = self.plant.strain;
            self.stateLabel.text = self.plant.state;
            NSString *flagString = [self.plant.flags componentsJoinedByString:@", "];
            self.flagLabel.text = [NSString stringWithFormat:@"Flags: %@", flagString];
            self.startDateLabel.text = [NSString stringWithFormat:@"Starting Date: %@", self.plant.startDate];
            self.speciesLabel.text = self.plant.species;
            if ([self.speciesLabel.text isEqualToString:@"sativa"]) {
                self.imagePlaceholder.image = [UIImage imageNamed:@"plant-placeholder_sativa"];
            }
            if ([self.speciesLabel.text isEqualToString:@"indica"]) {
                self.imagePlaceholder.image = [UIImage imageNamed:@"plant-placeholder_indica"];
            }
        }
    }];
}

- (void)decoderReady {
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [[Captuvo sharedCaptuvoDevice] enableDecoderBeeperForGoodRead:YES persistSetting:NO] ;
        
        //setting decoder trigger click status.
        [[Captuvo sharedCaptuvoDevice]requestDecoderTriggerClickStatus];
        
        NSLog(@"THE METHOD IS BEING CALLED!!!");
        
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
