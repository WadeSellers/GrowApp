//
//  NumberOfClonesVC.m
//  Flowgro
//
//  Created by Alex Moller on 9/24/15.
//  Copyright © 2015 Flowhub. All rights reserved.
//  Please adhere to the coding style
//  Coding style can be found at https://github.com/raywenderlich/objective-c-style-guide
//  Deleted derived data


#import "NumberOfClonesVC.h"
#import "Constants.h"
#import "ClonePlantsVC.h"
#import "flowgroSCLAlertView.h"
#import "SCLAlertCreator.h"


@interface NumberOfClonesVC ()

@property (weak, nonatomic) IBOutlet UILabel *enterAValidNumberOfClonesLabel;
@property (weak, nonatomic) IBOutlet UILabel *plantStrainLabel;
@property (weak, nonatomic) IBOutlet UILabel *plantTagIDNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *enterArrowButton;
@property (weak, nonatomic) IBOutlet UIImageView *imagePlaceHolder;
@property (weak, nonatomic) IBOutlet UIImageView *lineImagePlaceHolder;
@property (weak, nonatomic) IBOutlet UILabel *plantSpeciesLabel;
@property (weak, nonatomic) IBOutlet UILabel *plantPhaseLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeAgoPlantedLabel;
@property (weak, nonatomic) IBOutlet UILabel *licenseNumberLabel;

@end

@implementation NumberOfClonesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

#pragma mark - Setup UI
- (void)setupUI {
    self.view.backgroundColor = Main_Background_Color;
    
    UIToolbar* numberKeyBoardToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberKeyBoardToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberKeyBoardToolbar.barTintColor = Main_Background_Color;
    numberKeyBoardToolbar.items = [NSArray arrayWithObjects:
                                   [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelNumberPad)],
                                   [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                   [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(applyToolBarButtonPressed)],
                                   nil];
    
    [numberKeyBoardToolbar setTintColor:[UIColor whiteColor]];
    [numberKeyBoardToolbar sizeToFit];
    
    self.numberOfClonesTextField.inputAccessoryView = numberKeyBoardToolbar;
    self.numberOfClonesTextField.backgroundColor = [UIColor whiteColor];
    self.enterAValidNumberOfClonesLabel.textColor = [UIColor whiteColor];
    [self.numberOfClonesTextField becomeFirstResponder];
    
    Plant *scannedPlant = [self getFirstPlantObject];
    self.plantStrainLabel.text = scannedPlant.strain;
    self.plantTagIDNumberLabel.text = scannedPlant.tagId;
    self.plantSpeciesLabel.text = scannedPlant.species;
    self.plantPhaseLabel.text = scannedPlant.state;
    
    self.timeAgoPlantedLabel.text = [scannedPlant.startDate substringWithRange:NSMakeRange(0,8)];
    self.licenseNumberLabel.text = scannedPlant.license;
    self.plantStrainLabel.textColor = [UIColor whiteColor];
    self.plantTagIDNumberLabel.textColor = [UIColor whiteColor];
    self.plantSpeciesLabel.textColor = [UIColor whiteColor];
    self.plantPhaseLabel.textColor = [UIColor whiteColor];
    self.timeAgoPlantedLabel.textColor = [UIColor whiteColor];
    self.licenseNumberLabel.textColor = [UIColor whiteColor];
    
    UIImage *buttonImage = [UIImage imageNamed:@"enter-next.png"];
    self.enterArrowButton.tintColor = [UIColor whiteColor];
    [self.enterArrowButton setImage:buttonImage forState:UIControlStateNormal];
    
    
    if ([scannedPlant.species isEqualToString:@"sativa"]) {
      self.imagePlaceHolder.image = [UIImage imageNamed:@"plant-placeholder_sativa"];
    }
    if ([scannedPlant.species isEqualToString:@"indica"]) {
      self.imagePlaceHolder.image = [UIImage imageNamed:@"plant-placeholder_indica"];
    }

}

- (Plant *)getFirstPlantObject {
  
  Plant *scannedPlant = [self.scannedPlantsArray firstObject];
  
  return scannedPlant;
  
}


#pragma mark - Keyboard Actions
- (void)cancelNumberPad {
    [self.numberOfClonesTextField resignFirstResponder];
}

- (void)applyToolBarButtonPressed {
    [self.numberOfClonesTextField resignFirstResponder];
    
    if ([self checkForCorrectNumberOfClones] == true) {
      [self performSegueWithIdentifier:@"numberToRoomCloneSegue" sender:self];
    } else {
      
        SCLAlertView *alert = [SCLAlertCreator createSCLAlertViewWithColor:Green_Accent_Color];
      [alert showNotice:self title:@"Error" subTitle:@"Please enter a valid number of clones" closeButtonTitle:@"Okay" duration:2.0f];
      
    }
}

#pragma mark - Arrow Button Pressed
- (IBAction)arrowGoButtonPressed:(UIButton *)sender {
    [self.numberOfClonesTextField resignFirstResponder];
    
    if ([self checkForCorrectNumberOfClones] == true) {
      [self performSegueWithIdentifier:@"numberToRoomCloneSegue" sender:self];
    } else {
      
        SCLAlertView *alert = [SCLAlertCreator createSCLAlertViewWithColor:Green_Accent_Color];
      
      [alert showNotice:self title:@"Error" subTitle:@"Please enter a valid number of clones" closeButtonTitle:@"Okay" duration:2.0f];
      
//        [alert showNotice:@"Error" subTitle:@"Please enter a valid number of clones" closeButtonTitle:@"Okay" duration:2.0f];
    }
}

#pragma mark - prepareForSegue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ClonePlantsVC *vc = segue.destinationViewController;
    vc.scannedPlantsArray = self.scannedPlantsArray;
    vc.numberOfClones = [self.numberOfClonesTextField.text integerValue];
}

#pragma mark - Check for correct number of clones
- (BOOL)checkForCorrectNumberOfClones {
    NSInteger numberOfClonesToCheck = [self.numberOfClonesTextField.text  integerValue];
    NSNumber *numberOfClonesToCheckInNSNumberForm = [NSNumber numberWithInteger:numberOfClonesToCheck];
    
    if (numberOfClonesToCheck <= 100 && numberOfClonesToCheck >= 1 && numberOfClonesToCheckInNSNumberForm != nil) {
      return true;
    } else {
        return false;
    }
}

@end
