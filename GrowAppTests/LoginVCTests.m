//
//  LoginVCTests.m
//  Flowgro
//
//  Created by Alex Moller on 11/2/15.
//  Copyright © 2015 Flowhub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LoginViewController.h"
#import "FlowhubAPIHandler.h"
@interface LoginVCTests : XCTestCase
@property LoginViewController *loginViewControllerTestObject;
@property FlowhubAPIHandler *apiHandler;

@end

@implementation LoginVCTests

- (void)setUp {
    [super setUp];
  
  
  //SO IMPORTANT FOR INSTANTIATING VIEW CONTROLLERS FOR TESTIN
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.loginViewControllerTestObject = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self.loginViewControllerTestObject performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];
    [self.loginViewControllerTestObject performSelectorOnMainThread:@selector(viewDidLoad) withObject:nil waitUntilDone:YES];
  
    self.apiHandler = [[FlowhubAPIHandler alloc]init];
  
}

- (void)tearDown {
    [super tearDown];
}

- (void)testBadgeIDTextFieldIsBlank {
    XCTAssertEqualObjects(self.loginViewControllerTestObject.badgeIDTextField.text,
                          @"");
  
}

- (void)testPasswordTextFieldIsBlank {
    XCTAssertEqualObjects(self.loginViewControllerTestObject.passwordTextField.text,
                          @"");
}

- (void)testErrorInfoLabelIsBlank {
    XCTAssertEqualObjects(self.loginViewControllerTestObject.errorInfoLabel.text,
                          @"");

}

- (void)testLoginIntoDevFlowHubServer {
  XCTestExpectation *completionExpectation = [self expectationWithDescription:@"Login into app dev sucessfully"];
  [self.apiHandler loginWithBadgeID:@"M72364" andPassword:@"password1234!" WithCompletion:^(NSString *error) {
    
      XCTAssertFalse(error);
      [completionExpectation fulfill];
  }];
  
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
  
}


@end
