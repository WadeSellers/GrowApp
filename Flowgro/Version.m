//
//  Version.m
//  Flowgro
//
//  Created by Wade Sellers on 9/11/15.
//  Copyright (c) 2015 Flowhub. All rights reserved.
//

#import "Version.h"

@implementation Version

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.versionNumber forKey:@"versionNumber"];
    [encoder encodeObject:self.versionDescription forKey:@"versionDescription"];
    [encoder encodeObject:self.versionUrl forKey:@"versionUrl"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.versionNumber = [decoder decodeObjectForKey:@"versionNumber"];
        self.versionDescription = [decoder decodeObjectForKey:@"versionDescription"];
        self.versionUrl = [decoder decodeObjectForKey:@"versionUrl"];
    }
    return self;
}

@end
