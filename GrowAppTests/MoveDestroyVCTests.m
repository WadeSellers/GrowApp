//
//  MoveDestroyVCTests.m
//  Flowgro
//
//  Created by Wade Sellers on 11/9/15.
//  Copyright © 2015 Flowhub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MoveDestroyVC.h"

@interface MoveDestroyVC (Test) <UITableViewDelegate, UITableViewDataSource>
@property (strong) UIButton *actionButton;
@property UITableView *tagTableView;
@property NSMutableArray *scannedPlantsArray;
- (void)clearAllButtonPressed;
- (void)onBackButtonPressed:(id)sender;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
- (void)navBarSetup;

@end

@interface MoveDestroyVCTests : XCTestCase
@property MoveDestroyVC *moveDestroyVCTestObject;

@end

@implementation MoveDestroyVCTests

- (void)setUp {
    [super setUp];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.moveDestroyVCTestObject = [storyBoard instantiateViewControllerWithIdentifier:@"MovePlantsViewController"];
    [self.moveDestroyVCTestObject performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];
    [self.moveDestroyVCTestObject performSelectorOnMainThread:@selector(viewDidLoad) withObject:nil waitUntilDone:YES];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testActionButtonExclusiveSet {
    XCTAssertTrue(self.moveDestroyVCTestObject.actionButton.exclusiveTouch, @"actionButton has not had exclusive touch set to YES");
}

- (void)testUIBarButtonItemInstantiation {
    UIBarButtonItem *clearAll = [[UIBarButtonItem alloc] initWithTitle:@"Clear All" style:UIBarButtonItemStylePlain target:self action:@selector(clearAllButtonPressed)];
    self.moveDestroyVCTestObject.navigationItem.rightBarButtonItem = clearAll;

    XCTAssertEqualObjects(self.moveDestroyVCTestObject.navigationItem.rightBarButtonItem, clearAll, @"rightBarButtonItem not equal to instantiated clearAll UIBarButtonItem");
}

- (void)testUIBarButtonBackButtonInstantiation {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(onBackButtonPressed:)];
    self.moveDestroyVCTestObject.navigationItem.leftBarButtonItem = backButton;

    XCTAssertEqualObjects(self.moveDestroyVCTestObject.navigationItem.leftBarButtonItem, backButton, @"leftBarButtonItem not equal to instantitated clearAll UIBarButtonItem");
}

- (void)testParentViewHasTableView {
    NSArray *subviews = self.moveDestroyVCTestObject.view.subviews;
    XCTAssertTrue([subviews containsObject:self.moveDestroyVCTestObject.tagTableView], @"View does not have a table subview");
}

- (void)testThatTableViewLoads {
    XCTAssertNotNil(self.moveDestroyVCTestObject.tagTableView, @"TableView not initiated");
}


- (void)testThatViewConformsToUITableViewDataSource
{
    XCTAssertTrue([self.moveDestroyVCTestObject conformsToProtocol:@protocol(UITableViewDataSource) ], @"View does not conform to UITableView datasource protocol");
}

- (void)testThatTableViewHasDataSource
{
    XCTAssertNotNil(self.moveDestroyVCTestObject.tagTableView.dataSource, @"Table datasource cannot be nil");
}

- (void)testThatViewConformsToUITableViewDelegate
{
    XCTAssertTrue([self.moveDestroyVCTestObject conformsToProtocol:@protocol(UITableViewDelegate) ], @"View does not conform to UITableView delegate protocol");
}

- (void)testTableViewIsConnectedToDelegate
{
    XCTAssertNotNil(self.moveDestroyVCTestObject.tagTableView.delegate, @"Table delegate cannot be nil");
}

- (void)testTableViewNumberOfRowsInSection
{
    NSInteger expectedRows = self.moveDestroyVCTestObject.scannedPlantsArray.count;
    XCTAssertTrue([self.moveDestroyVCTestObject tableView:self.moveDestroyVCTestObject.tagTableView numberOfRowsInSection:0]==expectedRows, @"Table has %ld rows but it should have %ld", (long)[self.moveDestroyVCTestObject tableView:self.moveDestroyVCTestObject.tagTableView numberOfRowsInSection:0], (long)expectedRows);
}

- (void)testTableViewHeightForFooter {
    NSInteger expectedHeight = 0.01;
    NSInteger actualHeight = [self.moveDestroyVCTestObject tableView:self.moveDestroyVCTestObject.tagTableView heightForFooterInSection:0];

    XCTAssertEqual(expectedHeight, actualHeight, @"TableView footer height is not 0.01");
}

- (void)testNavBarTitleSetupForMove {
    self.moveDestroyVCTestObject.operation = @"move";
    [self.moveDestroyVCTestObject navBarSetup];
    NSString *expectedTitle = @"MOVE";
    XCTAssertEqualObjects(self.moveDestroyVCTestObject.navigationItem.title, expectedTitle, @"NavItem Title is not MOVE");
}

- (void)testNavBarTitleSetupForDestroy {
    self.moveDestroyVCTestObject.operation = @"destroy";
    [self.moveDestroyVCTestObject navBarSetup];
    NSString *expectedTitle = @"DESTROY";
    XCTAssertEqualObjects(self.moveDestroyVCTestObject.navigationItem.title, expectedTitle, @"NavItem Title is not DESTROY");
}

- (void)testNavBarTitleSetupForClone {
    self.moveDestroyVCTestObject.operation = @"clone";
    [self.moveDestroyVCTestObject navBarSetup];
    NSString *expectedTitle = @"CLONE";
    XCTAssertEqualObjects(self.moveDestroyVCTestObject.navigationItem.title, expectedTitle, @"NavItem Title is not CLONE");
}

- (void)testNavBarIsVisible {
    self.moveDestroyVCTestObject.operation = @"move";
    [self.moveDestroyVCTestObject navBarSetup];

    XCTAssertFalse(self.moveDestroyVCTestObject.navigationController.navigationBar.hidden);
}






@end
