//
//  Plant.m
//  Flowgro
//
//  Created by WADE SELLERS on 5/19/15.
//  Copyright (c) 2015 Flowhub. All rights reserved.
//

#import "Plant.h"

@implementation Plant

- (Plant *)initWithJSON:(NSDictionary *)json {
    self = [super init];
    
    if (self) {
        self.tagId = json[@"_id"];
        self.currentRoomId = json[@"room"][@"_id"];
        self.currentRoomName = json[@"room"][@"name"];
        self.currentRoomId = json[@"room"][@"_id"];
        self.clientId = json[@"client"][@"_id"];
        self.license = json[@"license"];
        self.strain = json[@"strain"][@"name"];
        self.strainId = json[@"strain"][@"_id"];
        self.state = json[@"state"][@"state"];
        self.flowerDateString = json[@"flowerDate"];
        self.species = json[@"strain"][@"species"];
        self.flags = json[@"flags"];
        self.daysInState = [self daysBetweenNowAndDate:self.flowerDateString];
        self.wetWeight = json[@"wetWeight"];
        self.harvestId = json[@"harvestId"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        NSDate *plantingDate = [dateFormatter dateFromString:[json valueForKey:@"plantingDate"]];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        [dateFormatter setDateFormat:@"M/d/yy 'at' h:mma"];
        NSString *displayingTime = [dateFormatter stringFromDate:plantingDate];
        self.startDate = displayingTime;
        
// Testing Output statements
//        NSLog(@"plant tagId: %@", self.tagId);
//        NSLog(@"plant currentRoomId: %@", self.currentRoomId);
//        NSLog(@"plant currentRoomName: %@", self.currentRoomName);
//        NSLog(@"plant clientId: %@", self.clientId);
//        NSLog(@"plant license: %@", self.license);
//        NSLog(@"plant flags: %@", self.flags);
//        NSLog(@"daysInState: %ld", (long)self.daysInState);
//        NSLog(@"Harvest Id: %@", self.harvestId);
//        NSLog(@"plant strain: %@", self.strain);
//        NSLog(@"plant strainId: %@", self.strainId);

    }

    return self;
}

- (NSInteger)daysBetweenNowAndDate:(NSString *)fromDateTime {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
    
    NSDate *fromDate = [NSDate new];
    fromDate = [formatter dateFromString:self.flowerDateString];
    
    NSDate *toDate = [NSDate new];
    NSString *currentDateString = [formatter stringFromDate:[NSDate date]];
    toDate = [formatter dateFromString:currentDateString];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDate];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDate];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

@end
