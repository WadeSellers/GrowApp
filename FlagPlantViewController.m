//
//  FlagPlantViewController.m
//  Flowgro
//
//  Created by Wade Sellers on 12/31/14.
//  Copyright (c) 2014 Flowhub. All rights reserved.
//  Please adhere to the coding style
//  Coding style can be found at https://github.com/raywenderlich/objective-c-style-guide


#import "FlagPlantViewController.h"
#import "SCLAlertView.h"
#import "Constants.h"
#import "FlowhubAPIHandler.h"
#import "Flag.h"
#import "SCLAlertCreator.h"

@interface FlagPlantViewController () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *flagTableView;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property NSArray *keyArray;
@property NSArray *valueArray;
@property NSMutableArray *selectedFlagsArray;
@property UIVisualEffectView *blurredEffectView;
@property SCLAlertView *alert;
@property SCLAlertView *connectingNugAlertWait;
@property NSArray *flagsListArray;
@property NSInteger numberOfFlagsSelected;

@end

@implementation FlagPlantViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.confirmButton setExclusiveTouch:YES];
    self.view.backgroundColor = Main_Background_Color;
    
    [self setupFlagObjectsAndArray];
    self.flagTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.flagTableView reloadData];
    
    self.selectedFlagsArray = [NSMutableArray array];
    
    [[self.confirmButton layer] setBorderWidth:1.0f];
    [[self.confirmButton layer] setCornerRadius:5.0];
    self.confirmButton.clipsToBounds = YES;
    
    self.numberOfFlagsSelected = 0;


}

#pragma mark - TableView Delegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.flagsListArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell" forIndexPath:indexPath];
    UIView *cellBGColorView = [UIView new];
    cellBGColorView.backgroundColor = Button_Selected_Color;
    UIImageView *cellBackgroundSelected = [[UIImageView alloc] initWithImage:Green_Accent_Image];
    [cell setSelectedBackgroundView:cellBackgroundSelected];
    
    cell.textLabel.text = [[self.flagsListArray objectAtIndex:indexPath.row] valueForKey:@"displayedTitle"];
    cell.detailTextLabel.text = [[self.flagsListArray objectAtIndex:indexPath.row] valueForKey:@"flagDescription"];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:19.0];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0];
    
    for (Plant *plant in self.scannedPlantsArray) {
        for (NSString *flag in plant.flags) {
            if ([flag isEqualToString:[[self.flagsListArray objectAtIndex:indexPath.row] valueForKey:@"backendTitle"]]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
                [self.selectedFlagsArray addObject:[[self.flagsListArray objectAtIndex:indexPath.row] valueForKey:@"backendTitle"]];
                self.numberOfFlagsSelected++;
                [self checkIfAnyFlagsSelected];
                NSLog(@"self.selectedFlagsArray: %@", self.selectedFlagsArray);
            }
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    [self.selectedFlagsArray addObject:[[self.flagsListArray objectAtIndex:indexPath.row] valueForKey:@"backendTitle"]];
    self.numberOfFlagsSelected++;
    [self checkIfAnyFlagsSelected];
    NSLog(@"self.selectedFlagsArray: %@", self.selectedFlagsArray);

}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    [self.selectedFlagsArray removeObjectIdenticalTo:[[self.flagsListArray objectAtIndex:indexPath.row] valueForKey:@"backendTitle"]];
    self.numberOfFlagsSelected--;
    [self checkIfAnyFlagsSelected];
    NSLog(@"self.selectedFlagsArray: %@", self.selectedFlagsArray);
}

- (void)checkIfAnyFlagsSelected {
    if (self.numberOfFlagsSelected > 0) {
        [self.confirmButton setBackgroundImage:Green_Accent_Image forState:UIControlStateNormal];
    } else {
        [self.confirmButton setBackgroundImage:Pink_Accent_Image forState:UIControlStateNormal];
    }
}


#pragma mark - Confirm Button Pressed
- (IBAction)onConfirmButtonPressed:(id)sender {
  
  
    self.alert = [SCLAlertCreator createSCLAlertViewWithColor:Green_Accent_Color];
    self.alert.backgroundType = Blur;
    [self.alert setShouldDismissOnTapOutside:YES];
    [self.alert setButtonsTextFontFamily:@"HelveticaNeue-Light" withSize:19.0];
    [self.alert addButton:@"Submit" target:self selector:@selector(confirmAlertViewButton)];
    [self.alert showCustom:self
                     image:[UIImage imageNamed:@"FlowhubLogo"]
                     color:Green_Accent_Color
                     title:@"Confirm?"
                  subTitle:[NSString stringWithFormat:@"Flag Plant"]
          closeButtonTitle:@"Cancel"
                  duration:0.0];
}

- (void)confirmAlertViewButton {
    self.alert.hideAnimationType = SlideOutToBottom;
    [self.alert hideView];

    SCLAlertView *alert = [SCLAlertCreator createSCLAlertViewWithColor:[UIColor whiteColor]];
    [alert showWaiting:self title:@"Completing Move" subTitle:nil closeButtonTitle:nil duration:0.0f];
    
    FlowhubAPIHandler *handler = [FlowhubAPIHandler new];
    [handler updatePlantsFlagsForScannedPlants:self.scannedPlantsArray WithFlags:self.selectedFlagsArray WithCompletion:^(NSString *errorString) {
        [alert hideView];
        
        double delayInSeconds = 0.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self performSegueWithIdentifier:@"unwindToHomeScreen" sender:self];
        });
    }];
}

- (void)setupFlagObjectsAndArray {
    Flag *bugs = [Flag new];
    bugs.displayedTitle = @"Bugs";
    bugs.backendTitle = @"bugs";
    bugs.flagDescription = @"Mites or other pests";
    
    Flag *mildew = [Flag new];
    mildew.displayedTitle = @"Powdery Mildew";
    mildew.backendTitle = @"mildew";
    mildew.flagDescription = @"White powder covering plants";
    
    Flag *mold = [Flag new];
    mold.displayedTitle = @"Mold";
    mold.backendTitle = @"mold";
    mold.flagDescription = @"Any type of mold covering the plant or bud";
    
    Flag *runt = [Flag new];
    runt.displayedTitle = @"Runt / Low Yielder";
    runt.backendTitle = @"runt";
    runt.flagDescription = @"Plant isn't producing much bud";
    
    Flag *male = [Flag new];
    male.displayedTitle = @"Male";
    male.backendTitle = @"male";
    male.flagDescription = @"Plant has hermied";
    
    self.flagsListArray = [[NSArray alloc] initWithObjects:bugs, mildew, mold, runt, male, nil];
}

@end
