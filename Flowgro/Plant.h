//
//  Plant.h
//  Flowgro
//
//  Created by WADE SELLERS on 5/19/15.
//  Copyright (c) 2015 Flowhub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Plant : NSObject

@property NSString *tagId;
@property NSString *operationPerforming;
@property NSString *state;
@property NSString *harvestId;
@property NSNumber *wetWeight;
@property NSString *strain;
@property NSString *strainId;
@property NSString *currentRoomName;
@property NSString *currentRoomId;
@property NSString *moveToRoomId;
@property NSString *moveToRoomName;
@property NSString *clientId;
@property NSString *license;
@property NSString *startDate;
@property NSString *flowerDateString;
@property NSString *species;
@property NSArray *flags;
@property NSInteger daysInState;

- (Plant *)initWithJSON:(NSDictionary *)json;

- (NSInteger)daysBetweenNowAndDate:(NSString *)fromDateTime;

@end
