//
//  NumberOfClonesVCTests.m
//  Flowgro
//
//  Created by Alex Moller on 11/9/15.
//  Copyright © 2015 Flowhub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NumberOfClonesVC.h"
#import "Plant.h"

@interface NumberOfClonesVCTests : XCTestCase
@property NumberOfClonesVC *numberOfClonesVCTestObject;
@property Plant *fakePlant;


@end

@implementation NumberOfClonesVCTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
  
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.numberOfClonesVCTestObject = [storyboard instantiateViewControllerWithIdentifier:@"NumberOfClonesVC"];
    [self.numberOfClonesVCTestObject performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];
    [self.numberOfClonesVCTestObject performSelectorOnMainThread:@selector(viewDidLoad) withObject:nil waitUntilDone:YES];
  
    self.fakePlant = [[Plant alloc]init];
    self.fakePlant.tagId = @"1A4000400266F3D000000557";
    self.fakePlant.strain = @"Test Strain";
    self.fakePlant.species = @"sativa";
    self.fakePlant.state = @"vegetative";
    self.fakePlant.license = @"403-23456";
  
  
}

- (void)testCheckScannedPlantIsNill {
  
  //nothing has been put in yet
  Plant *scannedPlant = [self.numberOfClonesVCTestObject getFirstPlantObject];
  XCTAssertNil(scannedPlant);
  
}

- (void)testGettingPlantData {
  
  //adding the fake scanned plant to the array
  self.numberOfClonesVCTestObject.scannedPlantsArray = [[NSMutableArray alloc]init];
  
  [self.numberOfClonesVCTestObject.scannedPlantsArray addObject:self.fakePlant];

  XCTAssertNotNil([self.numberOfClonesVCTestObject getFirstPlantObject]);
  
}

- (void)testCheckForNilNumberOfClones {
  
  XCTAssertFalse([self.numberOfClonesVCTestObject checkForCorrectNumberOfClones]);
  
}

- (void)testCheckCorrectNumberOfClones {
  
  self.numberOfClonesVCTestObject.numberOfClonesTextField.text = @"5";
  
  XCTAssertTrue([self.numberOfClonesVCTestObject checkForCorrectNumberOfClones]);
  
  
}

- (void)testCheckForIncorrectNumberOfClones {
  
  self.numberOfClonesVCTestObject.numberOfClonesTextField.text = @"105";
  
  XCTAssertFalse([self.numberOfClonesVCTestObject checkForCorrectNumberOfClones]);
  
}


- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


@end
