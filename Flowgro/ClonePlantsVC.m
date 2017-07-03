//
//  ClonePlantsVC.m
//  Flowgro
//
//  Created by Wade Sellers on 9/4/15.
//  Copyright (c) 2015 Flowhub. All rights reserved.
//  Please adhere to the coding style
//  Coding style can be found at https://github.com/raywenderlich/objective-c-style-guide


#import "ClonePlantsVC.h"
#import "FlowhubAPIHandler.h"
#import "Captuvo.h"
#import "SCLAlertView.h"
#import "Constants.h"
#import "SCLAlertCreator.h"

#import <QuartzCore/QuartzCore.h>

@interface ClonePlantsVC () <CaptuvoEventsProtocol, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *instructionAndStrainLabel;
@property (weak, nonatomic) IBOutlet UITableView *plantRoomsTableView;
@property (strong, nonatomic) NSArray *roomArray;
@property (weak, nonatomic) IBOutlet UIButton *createCloneButton;
@property Room* selectedRoom;


@end

@implementation ClonePlantsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupClonePlantsScreen];
}

#pragma mark - Setup Clone Plants Screen
- (void)setupClonePlantsScreen {
    self.roomArray = [self getEncondedUserRooms];
    self.plantRoomsTableView.backgroundColor = Main_Background_Color;
    self.createCloneButton.alpha = 0.5f;
    self.motherPlant = [self getMotherPlant];
  
}

#pragma mark - Get Methods for room and mother plants
- (Plant *)getMotherPlant {
  Plant *motherPlant = [self.scannedPlantsArray firstObject];
  return motherPlant;
}

- (NSArray *)getEncondedUserRooms {
  
  NSArray *roomArray = [[NSArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"encodedUserRooms"]]];
  
  return roomArray;
}

- (void)createClonesOnYesAlertButtonPressed {
    if(self.selectedRoom != NULL && self.motherPlant != nil) {
      
      FlowhubAPIHandler *handler = [FlowhubAPIHandler new];
      NSLog(@"The mother plant is %@", self.motherPlant);
      NSLog(@"The selected room is %@", self.selectedRoom);
    
      [handler postNewClonesFromMother:self.motherPlant inRoom:self.selectedRoom withQuantity:self.numberOfClones WithCompletion:^(NSString *errorString) {
        if (errorString) {
          NSLog(@"Clone api call Error String: %@", errorString);
          SCLAlertView *alert = [SCLAlertCreator createSCLAlertViewWithColor:Green_Accent_Color];
          
          [alert showNotice:self title:@"Error" subTitle:@"No network connection, please try again" closeButtonTitle:@"Okay" duration:2.0f];
        } else {
            NSLog(@"The Clones have been successfully added");
            [self performSegueWithIdentifier:@"unwindToMainMenu" sender:self];
        }
        
      }];
    } else {
        SCLAlertView *alert = [SCLAlertCreator createSCLAlertViewWithColor:Green_Accent_Color];
      
       [alert showNotice:self title:nil subTitle:@"Please select a room" closeButtonTitle:@"Okay" duration:5.0f];
    }
  
}

#pragma mark - createClonesButtonPressed
- (IBAction)createClonesButtonPressed:(UIButton *)sender {
    NSString *alertMessageOfClones = [NSString stringWithFormat:@"You are about to add %lu clones to %@. Is this okay?", (long)self.numberOfClones, self.selectedRoom.roomName];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                   message:alertMessageOfClones
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesAddClonesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                            [self createClonesOnYesAlertButtonPressed];
                                                          }];
    
    UIAlertAction* cancelButtonAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                            
                                                          }];
    [alert addAction:cancelButtonAction];
    [alert addAction:yesAddClonesAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [[Captuvo sharedCaptuvoDevice] addCaptuvoDelegate:self];
    [[Captuvo sharedCaptuvoDevice] startDecoderHardware];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[Captuvo sharedCaptuvoDevice] removeCaptuvoDelegate:self];
    [[Captuvo sharedCaptuvoDevice] stopDecoderHardware];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma TableView Delegate Methods
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    UITableViewCell *cell = [self.plantRoomsTableView dequeueReusableCellWithIdentifier:@"CellID"];
    Room *roomForCell = [self.roomArray objectAtIndex:indexPath.row];

    if([self.selectedRoom isEqual:roomForCell]) {
      cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
      cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSString *roomName = roomForCell.roomName;
    cell.textLabel.text = roomName;
    cell.backgroundColor = Main_Background_Color;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.roomArray.count;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedRoom = [self.roomArray objectAtIndex:indexPath.row];
}

//taken from http://stackoverflow.com/questions/2797165/uitableviewcell-checkmark-change-on-select
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
    NSIndexPath *oldIndex = [self.plantRoomsTableView indexPathForSelectedRow];
    [self.plantRoomsTableView cellForRowAtIndexPath:oldIndex].accessoryType = UITableViewCellAccessoryNone;
    [self.plantRoomsTableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;

    self.createCloneButton.alpha = 1.0f;
    self.createCloneButton.layer.cornerRadius = 2;
    self.createCloneButton.layer.borderWidth = 1;
    self.createCloneButton.layer.borderColor = [UIColor whiteColor].CGColor;

    return indexPath;
}

@end
