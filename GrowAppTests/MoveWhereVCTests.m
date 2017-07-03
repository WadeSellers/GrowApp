//
//  MoveWhereVCTests.m
//  Flowgro
//
//  Created by Wade Sellers on 11/18/15.
//  Copyright © 2015 Flowhub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MoveWhereVC.h"
#import "Constants.h"

@interface MoveWhereVC (Test) <UITableViewDataSource, UITableViewDelegate>
@property UITableView *roomTableView;
@property NSArray *decodedUserRooms;

@end

@interface MoveWhereVCTests : XCTestCase
@property MoveWhereVC *moveWhereVCTestObject;

@end

@implementation MoveWhereVCTests

- (void)setUp {
    [super setUp];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.moveWhereVCTestObject = [storyBoard instantiateViewControllerWithIdentifier:@"MoveWhereViewController"];
    [self.moveWhereVCTestObject performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];
    [self.moveWhereVCTestObject performSelectorOnMainThread:@selector(viewDidLoad) withObject:nil waitUntilDone:YES];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBackgroundColor {
    XCTAssertEqualObjects(self.moveWhereVCTestObject.view.backgroundColor, Main_Background_Color);
}

- (void)testParentViewHasTableView {
    NSArray *subviews = self.moveWhereVCTestObject.view.subviews;
    XCTAssertTrue([subviews containsObject:self.moveWhereVCTestObject.roomTableView], @"View does not have a table subview");
}

- (void)testThatTableViewLoads {
    XCTAssertNotNil(self.moveWhereVCTestObject.roomTableView, @"TableView not initiated");
}


- (void)testThatViewConformsToUITableViewDataSource
{
    XCTAssertTrue([self.moveWhereVCTestObject conformsToProtocol:@protocol(UITableViewDataSource) ], @"View does not conform to UITableView datasource protocol");
}

- (void)testThatTableViewHasDataSource
{
    XCTAssertNotNil(self.moveWhereVCTestObject.roomTableView.dataSource, @"Table datasource cannot be nil");
}

- (void)testThatViewConformsToUITableViewDelegate
{
    XCTAssertTrue([self.moveWhereVCTestObject conformsToProtocol:@protocol(UITableViewDelegate) ], @"View does not conform to UITableView delegate protocol");
}

- (void)testTableViewIsConnectedToDelegate
{
    XCTAssertNotNil(self.moveWhereVCTestObject.roomTableView.delegate, @"Table delegate cannot be nil");
}

- (void)testTableViewNumberOfRowsInSection
{
    NSInteger expectedRows = self.moveWhereVCTestObject.decodedUserRooms.count;
    XCTAssertTrue([self.moveWhereVCTestObject tableView:self.moveWhereVCTestObject.roomTableView numberOfRowsInSection:0]==expectedRows, @"Table has %ld rows but it should have %ld", (long)[self.moveWhereVCTestObject tableView:self.moveWhereVCTestObject.roomTableView numberOfRowsInSection:0], (long)expectedRows);
}






@end
