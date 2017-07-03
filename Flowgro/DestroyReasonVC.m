//
//  DestroyReasonVC.m
//  Flowgro
//
//  Created by Wade Sellers on 8/28/15.
//  Copyright (c) 2015 Flowhub. All rights reserved.
//  Please adhere to the coding style
//  Coding style can be found at https://github.com/raywenderlich/objective-c-style-guide


#import "DestroyReasonVC.h"
#import "SCLAlertView.h"
#import "Constants.h"
#import "FlowhubAPIHandler.h"

@interface DestroyReasonVC () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *DestroyReasonsTableView;
@property SCLAlertView *alert;
@property NSArray *destroyReasonsArray;
@property NSString *reasonSelectedString;

@end

@implementation DestroyReasonVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.destroyReasonsArray = [[NSArray alloc] initWithObjects:@"Bugs", @"Poor Growth", @"Disease", @"Wilt", @"Killed Strain", nil];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.destroyReasonsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell" forIndexPath:indexPath];

    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    UIView *cellBGColorView = [UIView new];
    cellBGColorView.backgroundColor = Button_Selected_Color;
    [cell setSelectedBackgroundView:cellBGColorView];

    cell.textLabel.text = [self.destroyReasonsArray objectAtIndex:indexPath.row];
    [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:19.0];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.reasonSelectedString = [self.destroyReasonsArray objectAtIndex:indexPath.row];

    self.alert = [[SCLAlertView alloc] init];
    self.alert.backgroundType = Blur;
    self.alert.soundURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/right_answer.mp3", [[NSBundle mainBundle] resourcePath]]];
    [self.alert setShouldDismissOnTapOutside:YES];
    [self.alert setButtonsTextFontFamily:@"HelveticaNeue-Light" withSize:19.0];
    [self.alert addButton:@"Submit" target:self selector:@selector(confirmDeleteTagsAlertViewButtonPressed)];
    [self.alert showCustom:self
                     image:[UIImage imageNamed:@"FlowhubLogo"]
                     color:Green_Accent_Color
                     title:[NSString stringWithFormat:@"Destroy %lu Plants?", (unsigned long) self.plantsToDestroyArray.count]
                  subTitle:[NSString stringWithFormat:@"Reason: %@", self.reasonSelectedString]
          closeButtonTitle:@"Cancel"
                  duration:0.0];
}

- (void)confirmDeleteTagsAlertViewButtonPressed {

    self.alert.hideAnimationType = SlideOutToBottom;
    [self.alert hideView];

    FlowhubAPIHandler *handler = [FlowhubAPIHandler new];
    [handler deleteScannedPlants:self.plantsToDestroyArray WithReason:self.reasonSelectedString WithCompletion:^(NSString *errorString) {
      
        if (!(errorString)) {
          
//          SCLAlertView *alert = [[SCLAlertView alloc] init];
//          [alert setBackgroundViewColor:[UIColor whiteColor]];
//          alert.backgroundType = Blur;
//          alert.customViewColor = Green_Accent_Color;
//          alert.soundURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/right_answer.mp3", [[NSBundle mainBundle] resourcePath]]];
//          [alert showNotice:self title:@"Destroy Complete" subTitle:nil closeButtonTitle:@"Ok" duration:2.0f];

            self.alert.hideAnimationType = SlideOutToBottom;
          
          //sloppy code but it'll do for now
          double delayInSeconds = 2.0;
          dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
          dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.DestroyReasonsTableView reloadData];
            [self performSegueWithIdentifier:@"unwindToHomeScreen" sender:self];
          });

        }
      
        else {
          
          SCLAlertView *alert = [[SCLAlertView alloc] init];
          [alert setBackgroundViewColor:[UIColor whiteColor]];
          alert.backgroundType = Blur;
          alert.customViewColor = Green_Accent_Color;
          alert.soundURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/right_answer.mp3", [[NSBundle mainBundle] resourcePath]]];
          [alert showNotice:self title:@"Error" subTitle:@"Network connectivitity error, please try again" closeButtonTitle:@"Ok" duration:3.0f];
          
        }
      
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
