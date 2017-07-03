//
//  MovePlantsViewController.m
//  Flowgro
//
//  Created by Wade Sellers on 12/12/14.
//  Copyright (c) 2014 Flowhub. All rights reserved.
//  Please adhere to the coding style
//  Coding style can be found at https://github.com/raywenderlich/objective-c-style-guide


#import "MoveDestroyVC.h"
#import "DestroyReasonVC.h"
#import "MoveWhereVC.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import "UIButton+PrimaryButton.h"
#import "SCLAlertView.h"
#import "LoginViewController.h"
#import "NSLogger.h"
#import "Constants.h"
#import "Plant.h"
#import "FlowhubAPIHandler.h"
#import "Captuvo.h"
#import "NumberOfClonesVC.h"
#import "SCLAlertCreator.h"

@interface MoveDestroyVC () <UITableViewDataSource, UITableViewDelegate, CaptuvoEventsProtocol, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UITableView *tagTableView;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property UIVisualEffectView *blurredEffectView;
@property NSMutableArray *scannedPlantsArray;
@property long numberScanned;
@property SCLAlertView *alert;
@property NSString *commentString;
@property UITextField *destroyReasonTextField;

@end

@implementation MoveDestroyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMoveDestroyController];
  
}

#pragma mark - Setup
- (void)setupMoveDestroyController {
    [self.actionButton setExclusiveTouch:YES];
    
    UIBarButtonItem *clearAll = [[UIBarButtonItem alloc] initWithTitle:@"Clear All" style:UIBarButtonItemStylePlain target:self action:@selector(clearAllButtonPressed)];
    self.navigationItem.rightBarButtonItem = clearAll;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(onBackButtonPressed:)];
    
    self.navigationItem.leftBarButtonItem = backButton;
    
    
    //HIDE InstructionLabel and Button immediately. We will produce them when needed from checkForScannedItems
    self.instructionLabel.alpha = 0;
    self.actionButton.hidden = YES;
    [[self.actionButton layer] setBorderColor:Button_Border_Color];
    
    self.scannedPlantsArray = [NSMutableArray new];
    [self.scannedPlantsArray removeAllObjects];
    
    [self checkForScannedItems];
    [self.tagTableView reloadData];
    
    NSLog(@"operation is: %@", self.operation);
    
    [self initCaptuvoSDK];
    
    //////    Enter a tag here to simulate a scan
//    [self decoderDataReceived:@"1A4000400266F3D000000557"];

}

#pragma mark - backButtonPressed
- (void)onBackButtonPressed:(id)sender {
    if(self.scannedPlantsArray != nil) {
      
      NSLog(@"The scanned plant array has something in it");
      SCLAlertView *backAlert = [SCLAlertCreator createSCLAlertViewWithColor:Green_Accent_Color];
      
      [backAlert addButton:@"Yes" actionBlock:^{
        [self.navigationController popViewControllerAnimated:YES];
      }];
      
      [backAlert showNotice:self title:@"Warning"subTitle:@"Going back will cancel current progress. Is this Okay?" closeButtonTitle:@"Cancel" duration:0.0f];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - View Did:
- (void)viewWillAppear:(BOOL)animated {
    [self navBarSetup];
    [self checkForScannedItems];
    [[Captuvo sharedCaptuvoDevice] addCaptuvoDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"view did appear");
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[Captuvo sharedCaptuvoDevice] removeCaptuvoDelegate:self];
    [[Captuvo sharedCaptuvoDevice] stopDecoderHardware];
}


- (BOOL) navigationShouldPopOnBackButton {
    if (self.scannedPlantsArray.count > 0) {
      NSLog(@"%ld", (unsigned long)self.scannedPlantsArray.count);
      [[[UIAlertView alloc] initWithTitle:@"Tags Scanned In" message:@"Are you sure you want to go back?"
                            delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
      return NO;
    }
  
    return YES;
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
      [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)onActionButtonPressed:(id)sender {
    if ([self.operation isEqualToString:@"move"]) {
      [self performSegueWithIdentifier:@"moveWhereSegue" sender:self];
    } else if ([self.operation isEqualToString:@"destroy"]) {
      [self performSegueWithIdentifier:@"destroyReasonsSegue" sender:self];
    } else if ([self.operation isEqualToString:@"clone"]) {
      [self performSegueWithIdentifier:@"numberOfClonesSegue" sender:self];
    }
 
}

#pragma mark - TableView Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.scannedPlantsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell" forIndexPath:indexPath];
    cell.textLabel.text = [[self.scannedPlantsArray objectAtIndex:indexPath.row] valueForKey:@"tagId"];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];

    UIImage *image = [UIImage imageNamed:@"tableDeletionX"];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    button.frame = frame;
    [button setBackgroundImage:image forState:UIControlStateNormal];

    [button addTarget:self action:@selector(checkButtonTapped:event:)
     forControlEvents:UIControlEventTouchUpInside];
  
    button.backgroundColor = [UIColor clearColor];
    cell.accessoryView = button;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01;
}

- (void)checkButtonTapped:(id)sender event:(id)event {
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tagTableView];
    NSIndexPath *indexPath = [self.tagTableView indexPathForRowAtPoint: currentTouchPosition];

    if (indexPath != nil) {
        [self tableView: self.tagTableView accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Update the data model
      [self.scannedPlantsArray removeObjectAtIndex:indexPath.row];

      // Animate the removal of the row
      [self.tagTableView beginUpdates];
      [self.tagTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
      [self.tagTableView endUpdates];
      
      [self checkForScannedItems];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    // Update the data model
    [self.scannedPlantsArray removeObjectAtIndex:indexPath.row];
    // Animate the removal of the row
    [self.tagTableView beginUpdates];
    [self.tagTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];

    [self.tagTableView endUpdates];
    [self checkForScannedItems];
}

//refactor
#pragma mark - Check For Scanned Items
- (void)checkForScannedItems {
    NSString *actionButtonString;

    //If any tags are in the array...
    if (self.scannedPlantsArray.count > 0) {
        [self pulsateInstructionLabel:NO];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.actionButton.hidden = NO;
        [self.actionButton pulsateBorderWithStartValue:1.0 andEndValue:0.5 andDuration:0.5];

        //Various actionButton titles can be displayed based on number of tags and operation
        if (self.scannedPlantsArray.count == 0) {
            actionButtonString = @"Waiting for tags...";
        } else if (self.scannedPlantsArray.count == 1) {
          
            if ([self.operation isEqualToString:@"move"]) {
              actionButtonString = [NSString stringWithFormat:@"Move %lu Plant", (unsigned long)self.scannedPlantsArray.count];
            }
            else if ([self.operation isEqualToString:@"destroy"]) {
              actionButtonString = [NSString stringWithFormat:@"Destroy %lu Plant", (unsigned long)self.scannedPlantsArray.count];
            }
            
            else if ([self.operation isEqualToString:@"clone"]) {
              actionButtonString = @"Clone this plant";
            }
        } else {
            if ([self.operation isEqualToString:@"move"]) {
              actionButtonString = [NSString stringWithFormat:@"Move %lu Plants", (unsigned long)self.scannedPlantsArray.count];
            }
            else if ([self.operation isEqualToString:@"destroy"]) {
              actionButtonString = [NSString stringWithFormat:@"Destroy %lu Plants", (unsigned long)self.scannedPlantsArray.count];
            }
            //can clone more than one plant????
            else if ([self.operation isEqualToString:@"clone"]) {
//              [self performSegueWithIdentifier:@"numberOfClonesSegue" sender:self];
              [self.scannedPlantsArray removeLastObject];
              [self.tagTableView reloadData];
              actionButtonString = @"Clone this plant";
            }
        }
      
        [self.actionButton setTitle:actionButtonString forState:UIControlStateNormal];
    }
  
    else {
      [self pulsateInstructionLabel:YES];
      self.navigationItem.rightBarButtonItem.enabled = NO;
      self.actionButton.hidden = YES;
    }
}

- (void)clearAllButtonPressed {
    self.numberScanned = [self.scannedPlantsArray count];

    self.alert = [SCLAlertCreator createSCLAlertViewWithColor:Green_Accent_Color];
    [self.alert setShouldDismissOnTapOutside:YES];
    [self.alert setButtonsTextFontFamily:@"HelveticaNeue-Light" withSize:19.0];
    [self.alert addButton:@"Clear Tags" target:self selector:@selector(confirmClearAllAlertViewButton)];
    [self.alert showCustom:self
                     image:[UIImage imageNamed:@"FlowhubLogo"]
                     color:Green_Accent_Color
                     title:@"Are You Sure?"
                  subTitle:[NSString stringWithFormat:@"Clear %lu Scanned Plants", (unsigned long) self.numberScanned]
          closeButtonTitle:@"Cancel"
                  duration:0.0];
}

- (void)confirmClearAllAlertViewButton {
    self.alert.hideAnimationType = SlideOutToBottom;
    [self.alert hideView];

    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.scannedPlantsArray removeAllObjects];
        [self checkForScannedItems];
        [self.tagTableView reloadData];

    });
}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([self.operation isEqualToString:@"move"]) {
      return YES;
    } else {
        return NO;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([self.operation isEqualToString:@"move"]) {
        MoveWhereVC *moveWhereViewController = segue.destinationViewController;
        moveWhereViewController.plantsToMoveArray = self.scannedPlantsArray;
        moveWhereViewController.numberScanned = self.scannedPlantsArray.count;
    } else if ([self.operation isEqualToString:@"destroy"]) {
        DestroyReasonVC *destroyReasonsViewController = segue.destinationViewController;
        destroyReasonsViewController.plantsToDestroyArray = self.scannedPlantsArray;
    }
  
    else if ([self.operation isEqualToString:@"clone"]) {
      NumberOfClonesVC *numberOfClonesVC= segue.destinationViewController;
      numberOfClonesVC.scannedPlantsArray = self.scannedPlantsArray;
    }
}

- (void)animateButtonBorder {
    CABasicAnimation* borderAnimation = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
    [borderAnimation setFromValue:[NSNumber numberWithFloat:1.5f]];
    [borderAnimation setToValue:[NSNumber numberWithFloat:0.4f]];
    //[borderAnimation setRepeatCount:2.0];
    [borderAnimation setAutoreverses:YES];
    [borderAnimation setDuration:1.0f];
    [borderAnimation setRepeatCount:HUGE_VALF];

    [self.actionButton.layer addAnimation:borderAnimation forKey:@"animateBorder"];
}

#pragma mark - Pulsate instruction label
- (void)pulsateInstructionLabel: (BOOL)activate {
    if (activate == YES) {
        self.instructionLabel.alpha = 0;
        [UIView animateWithDuration:1.5 delay:0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
            self.instructionLabel.alpha = 1;
        } completion:nil];
    } else {
        self.instructionLabel.alpha = 0;
    }
}

#pragma mark - NavBar
- (void)navBarSetup {
    if ([self.operation isEqualToString:@"move"]) {
        self.navigationItem.title = @"MOVE";
    }
    else if ([self.operation isEqualToString:@"destroy"]) {
        self.navigationItem.title = @"DESTROY";
    }
    else if ([self.operation isEqualToString:@"clone"]) {
      self.navigationItem.title = @"CLONE";
    }

    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName :[UIColor whiteColor]}];
  
    //Makes nav bar translucent
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBarTintColor:Nav_Bar_Background_Color];
}

#pragma mark - Captuvo Delegate Methods
- (void)initCaptuvoSDK {
    [[Captuvo sharedCaptuvoDevice] addCaptuvoDelegate:self];
    [[Captuvo sharedCaptuvoDevice] startDecoderHardware];
    [[Captuvo sharedCaptuvoDevice] requestBatteryVoltage];
    [[Captuvo sharedCaptuvoDevice] requestChargeStatus];
    [[Captuvo sharedCaptuvoDevice] enableDecoderScanning];
}

#pragma mark - Decoder Methods
- (void)decoderDataReceived:(NSString *)data {
    NSLog(@"decoderDataReceived: %@", data);
    //Get the barcode scan data from the notification
    NSString *tagNumberString = data;
    
    [[Captuvo sharedCaptuvoDevice] disableDecoderScanning];
    
    FlowhubAPIHandler *handler = [FlowhubAPIHandler new];
    [handler fetchOnePlant:tagNumberString WithCompletion:^(NSDictionary *plantJSON, NSError *errorString) {
        NSLog(@"PLANT JSON: %@", plantJSON);
        if (errorString) {
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            [alert setBackgroundViewColor:Green_Accent_Color];
            alert.soundURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/right_answer.mp3", [[NSBundle mainBundle] resourcePath]]];
            [alert showNotice:self title:nil subTitle:@"Cannot Find Plant" closeButtonTitle:nil duration:1.5];
            
            double delayInSeconds = 1.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                //code to be executed on the main queue after delay
                [[Captuvo sharedCaptuvoDevice] enableDecoderScanning];
            });
            return;
        }
        for (Plant *plant in self.scannedPlantsArray) {
            if ([plant.tagId isEqualToString:data]) {
                SCLAlertView *alert = [[SCLAlertView alloc] init];
                [alert setBackgroundViewColor:Green_Accent_Color];
                alert.soundURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/right_answer.mp3", [[NSBundle mainBundle] resourcePath]]];
                [alert showNotice:self title:nil subTitle:@"Tag Already Scanned" closeButtonTitle:nil duration:1.5];
                
                double delayInSeconds = 1.5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    //code to be executed on the main queue after delay
                    [[Captuvo sharedCaptuvoDevice] enableDecoderScanning];
                });
                return;
            }
        }
        
        Plant *plant = [[Plant alloc] initWithJSON:plantJSON];
        if ([plant.state isEqualToString:@"harvested"]) {
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            [alert setBackgroundViewColor:Green_Accent_Color];
            alert.soundURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/right_answer.mp3", [[NSBundle mainBundle] resourcePath]]];
            [alert showNotice:self title:nil subTitle:@"Plant Has Been Harvested" closeButtonTitle:nil duration:1.5];
            
            double delayInSeconds = 1.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                //code to be executed on the main queue after delay
                [[Captuvo sharedCaptuvoDevice] enableDecoderScanning];
            });
            return;
        }
        
        //Update your data first
        [self.scannedPlantsArray insertObject:plant atIndex:0];
        // Animate the add of the row
        [self.tagTableView beginUpdates];
        id path = [NSIndexPath indexPathForRow:0 inSection:0];
        NSArray *indexPathArray = [[NSArray alloc] initWithObjects:path, nil];
        [self.tagTableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationLeft];
        [self.tagTableView endUpdates];
        
        [self checkForScannedItems];
        [[Captuvo sharedCaptuvoDevice] enableDecoderScanning];
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



