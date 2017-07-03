//
//  FlowgroUITests.m
//  FlowgroUITests
//
//  Created by Alex Moller on 11/19/15.
//  Copyright © 2015 Flowhub. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface FlowgroUITests : XCTestCase

@end

@implementation FlowgroUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCloneFunctionality {
    // Use recording to get started writing UI tests.
  
//  XCUIApplication *app = [[XCUIApplication alloc] init];
//  [app.buttons[@"Login"] tap];
//  [app.navigationBars[@"MainMenuVC"].buttons[@"FlowhubLogoNavBar"] tap];
//  [app.buttons[@"Clone"] tap];
//  [app.buttons[@"Clone this plant"] tap];
//  [[[[[[app.otherElements containingType:XCUIElementTypeNavigationBar identifier:@"NumberOfClonesVC"] childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeTextField].element typeText:@"5"];
//  [app.toolbars.buttons[@"Next"] tap];
//  [app.tables.staticTexts[@"Quarantine Room Client 2"] tap];
//  [app.buttons[@"Create Clones"] tap];
//  [app.alerts[@"Warning"].collectionViews.buttons[@"Yes"] tap];
//  // Use XCTAssert and related functions to verify your tests produce the correct resultsv
//  
}

@end
