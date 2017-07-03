//
//  MoveWhereViewController.m
//  Flowgro
//
//  Created by Wade Sellers on 12/30/14.
//  Copyright (c) 2014 Flowhub. All rights reserved.
//  Please adhere to the coding style
//  Coding style can be found at https://github.com/raywenderlich/objective-c-style-guide


#import "MoveWhereVC.h"
#import "MainMenuVC.h"
#import "SCLAlertView.h"
#import "Constants.h"
#import "FlowhubAPIHandler.h"

@interface MoveWhereVC () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *roomTableView;
@property UIVisualEffectView *blurredEffectView;
@property SCLAlertView *alert;
@property NSString *selectedRoomID;
@property NSString *selectedRoomName;
@property NSArray *decodedUserRooms;
@property int attemptedCompletionTrials;
@property (strong, nonatomic) UIView *operationView;
@property (strong, nonatomic) UILabel *plantsRemainingLabel;

@end

@implementation MoveWhereVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = Main_Background_Color;

    self.decodedUserRooms = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"encodedUserRooms"]];
    NSLog(@"Saved Room Array: %@", self.decodedUserRooms);

    self.roomTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self navBarSetup];
    
    [self reloadData:YES];

    self.attemptedCompletionTrials = 0;
    [self.view addSubview:self.operationView];


}

- (void)viewWillAppear:(BOOL)animated {
    self.operationView.hidden = YES;
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

- (void)viewDidDisappear:(BOOL)animated {
    self.navigationController.navigationBar.topItem.backBarButtonItem.title = @"Move";
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.decodedUserRooms.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell" forIndexPath:indexPath];
    NSString *roomName = [[self.decodedUserRooms objectAtIndex:indexPath.row] valueForKey:@"roomName"];
    
    UIView *cellBGColorView = [UIView new];
    cellBGColorView.backgroundColor = Button_Selected_Color;
    [cell setSelectedBackgroundView:cellBGColorView];
    
    cell.textLabel.text = roomName;
    [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:19.0];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedRoomID = [[self.decodedUserRooms objectAtIndex:indexPath.row] valueForKey:@"roomId"];
    self.selectedRoomName = [[self.decodedUserRooms objectAtIndex:indexPath.row] valueForKey:@"roomName"];
    
    for (Plant *plant in self.plantsToMoveArray) {
        plant.moveToRoomId = self.selectedRoomID;
        plant.moveToRoomName = self.selectedRoomName;
    }

    [tableView deselectRowAtIndexPath:[self.roomTableView indexPathForSelectedRow] animated:YES];

    self.alert = [[SCLAlertView alloc] init];
    self.alert.backgroundType = Blur;
    self.alert.soundURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/right_answer.mp3", [[NSBundle mainBundle] resourcePath]]];
    [self.alert setShouldDismissOnTapOutside:YES];
    [self.alert setButtonsTextFontFamily:@"HelveticaNeue-Light" withSize:19.0];
    [self.alert addButton:@"Submit" target:self selector:@selector(confirmAlertViewButton)];
    [self.alert showCustom:self
                image:[UIImage imageNamed:@"FlowhubLogo"]
                color:Green_Accent_Color
                title:@"Confirm Move"
             subTitle:[NSString stringWithFormat:@"Move %lu Plants to %@?", (unsigned long) self.numberScanned, [[self.decodedUserRooms objectAtIndex:indexPath.row] valueForKey:@"roomName"]]
     closeButtonTitle:@"Cancel"
             duration:0.0];
}

#pragma mark - Confirm Alert View Button
- (void)confirmAlertViewButton {
    self.alert.hideAnimationType = SlideOutToBottom;
    [self.alert hideView];

    [self performMovePlantOperations];
}

- (void)performMovePlantOperations {
    if (self.plantsToMoveArray.count > 0) {
        self.operationView.hidden = NO;
        self.plantsRemainingLabel.text = [NSString stringWithFormat:@"Plants remaining: %lu", (unsigned long)self.plantsToMoveArray.count];
        dispatch_queue_t queue = dispatch_get_main_queue();
        dispatch_group_t group = dispatch_group_create();

        FlowhubAPIHandler *newHandler = [FlowhubAPIHandler new];

        for (Plant *plant in self.plantsToMoveArray) {
            dispatch_group_enter(group);
            dispatch_group_async(group, queue, ^{
                [newHandler updatePlantCurrentRoom:plant IntoRoom:self.selectedRoomID WithRoomName:self.selectedRoomName WithCompletion:^(NSString *errorString) {
                    if (errorString != nil) {
                        NSLog(@"Error occurred");
                        dispatch_group_leave(group);
                    } else {
                        [self.plantsToMoveArray removeObjectIdenticalTo:plant];
                        self.plantsRemainingLabel.text = [NSString stringWithFormat:@"Plants remaining: %lu", (unsigned long)self.plantsToMoveArray.count];
                        NSLog(@"No Error");
                        dispatch_group_leave(group);
                    }
                }];

            });
        }
        dispatch_group_notify(group, queue, ^{
            if (self.plantsToMoveArray.count == 0) {
                [self performSegueWithIdentifier:@"unwindToHomeScreen" sender:self];
            } else {
                self.attemptedCompletionTrials++;
                NSLog(@"attempted Completion Trials: %d", self.attemptedCompletionTrials);
                if (self.attemptedCompletionTrials <= 3) {
                    self.operationView.hidden = YES;
                    [self performMovePlantOperations];
                } else {
                    self.operationView.hidden = YES;
                    [self retryMoveAlertAndOperation];
                }
            }
        });
    }
}

- (void)retryMoveAlertAndOperation {
    SCLAlertView *retryAlert = [[SCLAlertView alloc] init];
    [retryAlert setBackgroundViewColor:[UIColor whiteColor]];
    retryAlert.backgroundType = Blur;
    retryAlert.customViewColor = Green_Accent_Color;
    retryAlert.soundURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/right_answer.mp3", [[NSBundle mainBundle] resourcePath]]];
    [retryAlert addButton:@"Retry" actionBlock:^{
        self.attemptedCompletionTrials = 0;
        [self performMovePlantOperations];
    }];
    [retryAlert showNotice:self title:@"All moves not completed" subTitle:@"find better cell/wifi reception and tap retry" closeButtonTitle:nil duration:0.0];
}

- (void)reloadData:(BOOL)animated {
    [self.roomTableView reloadData];

    if (animated) {
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFade];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [animation setFillMode:kCAFillModeBoth];
        [animation setDuration:1.0];
        [[self.roomTableView layer] addAnimation:animation forKey:@"UITableViewReloadDataAnimationKey"];
    }
}

- (void)navBarSetup {
    self.navigationItem.title = @"Move Where";
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    //Makes nav bar translucent
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBarTintColor:Nav_Bar_Background_Color];
}

- (UIView *)operationView {
    if (!_operationView) {
        _operationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        _operationView.backgroundColor = Main_Background_Color;

        self.plantsRemainingLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, self.view.bounds.size.height * 0.3, self.view.bounds.size.width - 40, 60)];
        self.plantsRemainingLabel.textAlignment = NSTextAlignmentCenter;
        self.plantsRemainingLabel.numberOfLines = 3;
        self.plantsRemainingLabel.textColor = [UIColor whiteColor];
        [_operationView addSubview:self.plantsRemainingLabel];

        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        spinner.color = Green_Accent_Color;
        spinner.center = self.view.center;
        [spinner startAnimating];
        [_operationView addSubview:spinner];

        UILabel *noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, self.view.bounds.size.height * 0.6, self.view.bounds.size.width - 40, 50)];
        noticeLabel.textAlignment = NSTextAlignmentCenter;
        noticeLabel.numberOfLines = 3;
        noticeLabel.textColor = [UIColor whiteColor];
        noticeLabel.text = @"*Operation may take up to 1 minute";
        [_operationView addSubview:noticeLabel];
    }
    return _operationView;
}

@end
