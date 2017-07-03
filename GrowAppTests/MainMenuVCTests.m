//
//  MainMenuVCTests.m
//  Flowgro
//
//  Created by Alex Moller on 11/2/15.
//  Copyright © 2015 Flowhub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MainMenuVC.h"
#import "Constants.h"


@interface MainMenuVC (Test)
@property (strong) UIButton *cloneBurgerBarButton;
- (void)introAnimations;
- (void)animateBurgerBarInOut;

@end

@interface MainMenuVCTests : XCTestCase

@property MainMenuVC *mainMenuVCTestObject;

//- (void)setupMainMenuScreen;

@end

@implementation MainMenuVCTests

- (void)setUp {
    [super setUp];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.mainMenuVCTestObject = [storyboard instantiateViewControllerWithIdentifier:@"MainMenuViewController"];
    //[self.mainMenuVCTestObject performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];
    [self.mainMenuVCTestObject performSelectorOnMainThread:@selector(viewDidLoad) withObject:nil waitUntilDone:YES];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - viewDidLoad tests

- (void)testMovePlantButtonExclusiveTouchesSet {
    XCTAssertTrue(self.mainMenuVCTestObject.movePlantsButton.exclusiveTouch, @"Move button doesn't have exclusive touches set to YES");
}

- (void)testDestroyPlantButtonExclusiveTouchesSet {
    XCTAssertTrue(self.mainMenuVCTestObject.destroyPlantsButton.exclusiveTouch, @"Destroy button doesn't have exclusive touches set to YES");
}

- (void)testLookupPlantButtonExcluseiveTouchesSet {
    XCTAssertTrue(self.mainMenuVCTestObject.lookupPlantsButton.exclusiveTouch, @"Lookup button doesn't have exclusive touches set to YES");
}

- (void)testHarvestPlantButtonExclusiveTouchesSet {
    XCTAssertTrue(self.mainMenuVCTestObject.harvestPlantsButton.exclusiveTouch, @"Harvest button doesn't have exclusive touches set to YES");
}

- (void)testBackgroundColorSet {
    XCTAssertEqualObjects(self.mainMenuVCTestObject.view.backgroundColor, Main_Background_Color, @"Background Color and constant name for Main_Background_Color are not matching");
}

- (void)testProperTextInUserGreetingLabel {
    NSString *properGreetingIncludingNameFromAPICall = [NSString stringWithFormat:@"Hello, %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"name"]];
    XCTAssertEqualObjects(self.mainMenuVCTestObject.userGreetingLabel.text, properGreetingIncludingNameFromAPICall);
}

- (void)testBurgerBarWasAddedToVCViewAsSubView {
    XCTAssertNotNil(self.mainMenuVCTestObject.burgerBar, @"burgerBar is nil");
}

#pragma mark - viewWillAppear tests

- (void)testOperationStringIsEmpty {
    [self.mainMenuVCTestObject performSelectorOnMainThread:@selector(viewWillAppear:) withObject:nil waitUntilDone:YES];
    XCTAssertEqualObjects(self.mainMenuVCTestObject.operation, @"", @"Operation was not set to nil on viewWillAppear");
}

#pragma mark - navBarSetup tests

- (void)testNavBarIsHidden {
    [self.mainMenuVCTestObject performSelectorOnMainThread:@selector(viewWillAppear:) withObject:nil waitUntilDone:YES];
    XCTAssertFalse(self.mainMenuVCTestObject.navigationController.navigationBarHidden, @"Navigation Bar hidden is not hidden");
}

- (void)testNavBarTranslucentSetting {
    [self.mainMenuVCTestObject performSelectorOnMainThread:@selector(viewWillAppear:) withObject:nil waitUntilDone:YES];
    XCTAssertFalse(self.mainMenuVCTestObject.navigationController.navigationBar.translucent);
}

#pragma mark - Segue tests

- (void)testMoveButtonSegue {
    [UIApplication sharedApplication].keyWindow.rootViewController = self.mainMenuVCTestObject;
    [self.mainMenuVCTestObject performSegueWithIdentifier:@"segueMainToMove" sender:nil];
    XCTAssertNotNil(self.mainMenuVCTestObject.presentedViewController, @"The presentedViewController is nil");
}

- (void)testDestroyButtonSegue {
    [UIApplication sharedApplication].keyWindow.rootViewController = self.mainMenuVCTestObject;
    [self.mainMenuVCTestObject performSegueWithIdentifier:@"segueMainToDestroy" sender:nil];
    XCTAssertNotNil(self.mainMenuVCTestObject.presentedViewController, @"The presentedViewController is nil");
}

- (void)testLookupButtonSegue {
    [UIApplication sharedApplication].keyWindow.rootViewController = self.mainMenuVCTestObject;
    [self.mainMenuVCTestObject performSegueWithIdentifier:@"segueToLookupPlantsViewController" sender:nil];
    XCTAssertNotNil(self.mainMenuVCTestObject.presentedViewController, @"The presentedViewController is nil");
}

- (void)testHarvestButtonSegue {
    [UIApplication sharedApplication].keyWindow.rootViewController = self.mainMenuVCTestObject;
    [self.mainMenuVCTestObject performSegueWithIdentifier:@"segueMainToHarvest" sender:nil];
    XCTAssertNotNil(self.mainMenuVCTestObject.presentedViewController, @"The presentedViewController is nil");
}

- (void)testCloneButtonSegue {
    [UIApplication sharedApplication].keyWindow.rootViewController = self.mainMenuVCTestObject;
    [self.mainMenuVCTestObject performSegueWithIdentifier:@"segueMainToClone" sender:nil];
    XCTAssertNotNil(self.mainMenuVCTestObject.presentedViewController, @"The presentedViewController is nil");
}



#pragma mark - introAnimation tests
- (void)testMoveButtonEnabled {
    [self.mainMenuVCTestObject introAnimations];
    XCTAssertTrue(self.mainMenuVCTestObject.movePlantsButton.enabled, @"Move plants button is not enabled");
}

- (void)testDestroyButtonEnabled {
    [self.mainMenuVCTestObject introAnimations];
    XCTAssertTrue(self.mainMenuVCTestObject.destroyPlantsButton.enabled, @"Destroy plants button is not enabled");
}

- (void)testLookupButtonEnabled {
    [self.mainMenuVCTestObject introAnimations];
    XCTAssertTrue(self.mainMenuVCTestObject.lookupPlantsButton.enabled, @"Move plants button is not enabled");
}

- (void)testHarvestButtonEnabled {
    [self.mainMenuVCTestObject introAnimations];
    XCTAssertTrue(self.mainMenuVCTestObject.harvestPlantsButton.enabled, @"Move plants button is not enabled");
}

#pragma mark - burgerBar tests
- (void)testBurgerBarBackgroundColor {
    XCTAssertEqualObjects(self.mainMenuVCTestObject.burgerBar.backgroundColor, Nav_Bar_Background_Color, @"burgerBar backgroundColor is not set to Nav_Bar_Background_Color constant");
}

#pragma mark - cloneBurgerBarButton tests
- (void)testCloneBurgerBarButtonFrame {
    [self.mainMenuVCTestObject animateBurgerBarInOut];
    XCTAssertEqualObjects(self.mainMenuVCTestObject.cloneBurgerBarButton.backgroundColor, Green_Accent_Color);
}

- (void)testCloneBurgerBarButtonLabelText {
        XCTAssertEqualObjects(self.mainMenuVCTestObject.cloneBurgerBarButton.titleLabel.text, @"Clone", @"Title is not set to Clone");
}





@end
