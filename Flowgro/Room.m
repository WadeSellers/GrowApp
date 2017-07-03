//
//  Room.m
//  Flowgro
//
//  Created by WADE SELLERS on 5/15/15.
//  Copyright (c) 2015 Flowhub. All rights reserved.
//

#import "Room.h"

@implementation Room

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.roomId forKey:@"roomId"];
    [encoder encodeObject:self.roomName forKey:@"roomName"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.roomId = [decoder decodeObjectForKey:@"roomId"];
        self.roomName = [decoder decodeObjectForKey:@"roomName"];
    }
    return self;
}

@end
