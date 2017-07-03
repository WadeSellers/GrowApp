//
//  FlowhubAPIHandler.h
//  Flowgro
//
//  Created by Wade Sellers on 3/23/15.
//  Copyright (c) 2015 Flowhub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Plant.h"
#import "Room.h"
#import "Version.h"

@interface FlowhubAPIHandler : NSObject

- (void)loginWithBadgeID:(NSString *)badgeID andPassword:(NSString *)password WithCompletion:(void (^)(NSString *error))completion;

- (void)fetchOnePlant:(NSString *)plantID WithCompletion:(void(^)(NSDictionary *plantJSON, NSError *errorString))completionBlock;

- (void)getUsersRoomsWithCompletion:(void (^)(NSArray *roomArray, NSString *errorString))completion;

- (void)updatePlantsCurrentRoomAndStateForScannedPlants:(NSArray *)plantsToMoveArray IntoRoom:(NSString *)roomId WithRoomName:(NSString *)roomName WithCompletion:(void (^)(NSString *errorString))completionBlock;

- (void)updatePlantsFlagsForScannedPlants:(NSArray *)plantsToFlagArray WithFlags:(NSArray *)flagsArray WithCompletion:(void (^)(NSString *errorString))completionBlock;

- (void)deleteScannedPlants:(NSArray *)tagsToDestroyArray WithReason:(NSString *)reason WithCompletion:(void (^)(NSString *errorString))completionBlock;

- (void)harvestPlant:(Plant *)plant WithCompletion:(void (^)(NSString *errorString))completionBlock;

- (void)postNewClonesFromMother:(Plant *)motherPlant inRoom:(Room *)room withQuantity:(NSInteger)quantity WithCompletion:(void (^)(NSString *errorString))completionBlock;

- (void) getCurrentVersionWithCompletion:(void (^)(Version *versionObject, NSString *errorString))completionBlock;

- (void)updatePlantCurrentRoom:(Plant *)plant IntoRoom:(NSString *)roomId WithRoomName:(NSString *)roomName WithCompletion:(void (^)(NSString *errorString))completionBlock;



@end
