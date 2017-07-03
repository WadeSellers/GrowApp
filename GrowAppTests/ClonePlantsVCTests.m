//
//  ClonePlantsVCTests.m
//  Flowgro
//
//  Created by Alex Moller on 11/9/15.
//  Copyright © 2015 Flowhub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ClonePlantsVC.h"

@interface ClonePlantsVCTests : XCTestCase
@property ClonePlantsVC *clonePlantsVCTestObject;


@end

@implementation ClonePlantsVCTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
  
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  self.clonePlantsVCTestObject = [storyboard instantiateViewControllerWithIdentifier:@"ClonePlantsVC"];
  [self.clonePlantsVCTestObject performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];
  [self.clonePlantsVCTestObject performSelectorOnMainThread:@selector(viewDidLoad) withObject:nil waitUntilDone:YES];

}

- (void)testRoomArrayIsNotNil {
  XCTAssertNotNil([self.clonePlantsVCTestObject getEncondedUserRooms]);
}

//- (void)testMotherPlantIsNotNil {
//  
////  XCTAssertNotNil([self.clonePlantsVCTestObject getMotherPlant]);
//}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



@end
