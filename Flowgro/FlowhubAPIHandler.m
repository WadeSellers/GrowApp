//
//  FlowhubAPIHandler.m
//  Flowgro
//
//  Created by Wade Sellers on 3/23/15.
//  Copyright (c) 2015 Flowhub. All rights reserved.
//

#import "FlowhubAPIHandler.h"
#import "AFNetworking.h"
#import "NSLogger.h"
#import "SCLAlertView.h"
#import "Constants.h"
#import "Room.h"
#import "Version.h"

//Should be commented out UNLESS PUSHING NEW VERSION or testing production server only
static NSString *const ProductionBaseLoginURLString = @"removed to protect source";
static NSString *const ProductionBaseBackendURLString = @"removed to protect source";
static NSString *const ProductionBaseActiveHarvestsURLString = @"removed to protect source";
static NSString *const ProductionBaseNewHarvestURLString = @"removed to protect source";

//Should be used exclusively for development purposes.
//*** COMMENT THESE ROUTES OUT PRIOR TO PUSHING A PRODUCTION APP UPDATE ***
//static NSString *const ProductionBaseLoginURLString = @"removed to protect source";
//static NSString *const ProductionBaseBackendURLString = @"removed to protect source";
//static NSString *const ProductionBaseActiveHarvestsURLString = @"removed to protect source;
//static NSString *const ProductionBaseNewHarvestURLString = @"removed to protect source";


static NSString *const DemoBaseLoginURLString = @"removed to protect source";
static NSString *const DemoBaseBackendURLString = @"removed to protect source";
static NSString *const DemoBaseActiveHarvestsURLString = @"removed to protect source";
static NSString *const DemoBaseNewHarvestURLString = @"removed to protect source";

@implementation FlowhubAPIHandler

#pragma mark - Server URL String Helper Method
- (NSString *)setupServerBaseUrlString {
    //When logging in, the badgeId will route to certain server and a string will be saved based on server.
    //String will either be "demo" or "production"
    NSString *server = [[NSUserDefaults standardUserDefaults] valueForKey:@"server"];
    if ([server isEqualToString:@"demo"]) {
        return DemoBaseBackendURLString;
    }
    else {
        return ProductionBaseBackendURLString;
    }
}

#pragma mark - Login Call
- (void)loginWithBadgeID:(NSString *)badgeID andPassword:(NSString *)password WithCompletion:(void (^)(NSString *errorString))completion {
    NSString *urlString = [[NSString alloc] initWithString:[self setupServerBaseUrlString]];
    NSString *loginUrlString = [NSString stringWithFormat:@"%@users/login", urlString];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"email" : badgeID, @"password" : password, @"method" : @"mobile"};
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:loginUrlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        [[NSUserDefaults standardUserDefaults] setObject:[responseObject objectForKey:@"token"] forKey:@"token"];
        [[NSUserDefaults standardUserDefaults] setObject:[responseObject objectForKey:@"_id"] forKey:@"badgeId"];
        [[NSUserDefaults standardUserDefaults] setObject:[responseObject objectForKey:@"licenses"] forKey:@"userLicenses"];
        [[NSUserDefaults standardUserDefaults] setObject:[responseObject objectForKey:@"name"] forKey:@"name"];
        NSDictionary *clientDict = [responseObject objectForKey:@"client"];
        [[NSUserDefaults standardUserDefaults] setObject:[clientDict objectForKey:@"_id"] forKey:@"clientId"];
        NSLog(@"NSUSerDefaults token: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"token"]);
        NSLog(@"NSUserDefaults badgeId: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"badgeId"]);
        NSLog(@"NSUserDefaults userLicenses: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userLicenses"]);
        NSLog(@"NSUserDefaults name: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"name"]);
        NSLog(@"NSUserDefaults clientId: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"clientId"]);
        completion(nil);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completion([NSString stringWithFormat:@"%ld", (long)operation.response.statusCode]);
    }];
}

#pragma mark - Plant Calls
- (void)fetchOnePlant:(NSString *)plantID WithCompletion:(void(^)(NSDictionary *plantJSON, NSError *errorString))completionBlock {
    NSString * urlString = [[NSString alloc] initWithString:[self setupServerBaseUrlString]];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"access_token" : [[NSUserDefaults standardUserDefaults] objectForKey:@"token"]};
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@plants/%@", urlString, plantID] parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"plant Object in API CALL: %@", responseObject);
             completionBlock (responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error from api call: %@", error.localizedDescription);
        completionBlock (nil, error);
    }];
}

// PUT new room to all plants scanned
#pragma mark - Updat plants current room
- (void)updatePlantsCurrentRoomAndStateForScannedPlants:(NSArray *)plantsToMoveArray IntoRoom:(NSString *)roomId WithRoomName:(NSString *)roomName WithCompletion:(void (^)(NSString *errorString))completionBlock {
    NSString *urlString = [[NSString alloc] initWithString:[self setupServerBaseUrlString]];
    
    NSLog(@"tagsToMoveArray: %@", plantsToMoveArray);
    
    for (Plant *plant in plantsToMoveArray) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

        [manager.requestSerializer setValue:@"movePlant" forHTTPHeaderField:@"x-flowhub-operation"];
        [manager.requestSerializer setValue:@"plants" forHTTPHeaderField:@"x-flowhub-context"];
        [manager.requestSerializer setValue:plant.clientId forHTTPHeaderField:@"x-flowhub-clientId"];
        [manager.requestSerializer setValue:plant.license forHTTPHeaderField:@"x-flowhub-license"];

        NSDictionary *infoDictionary = @{@"tagId": plant.tagId, @"roomFrom": plant.currentRoomName, @"roomTo": plant.moveToRoomName};

        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDictionary options:0 error:&error];
        if (! jsonData) {
            NSLog(@"Got an error with jsonData: %@", error);
        } else {
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"JSON String: %@", jsonString);
            [manager.requestSerializer setValue:jsonString forHTTPHeaderField:@"x-flowhub-info"];
        }
        
        NSDictionary *parameters = @{
                                     @"roomId": roomId,
                                     @"plantId": plant.tagId
                                     };

        [manager PUT:[NSString stringWithFormat:@"%@plants/%@?access_token=%@", urlString, plant.tagId, [[NSUserDefaults standardUserDefaults] objectForKey:@"token"]] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"responseObject: %@", responseObject);
            completionBlock(nil);
        }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error: %@", error);
            NSLog(@"request headers: %@", manager.requestSerializer.HTTPRequestHeaders);
            completionBlock(error.localizedDescription);
        }];
    }
}

// PUT harvest a scanned plant
- (void)harvestPlant:(Plant *)plant WithCompletion:(void (^)(NSString *errorString))completionBlock {
    NSString * urlString = [[NSString alloc] initWithString:[self setupServerBaseUrlString]];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"harvestPlant" forHTTPHeaderField:@"x-flowhub-operation"];
    [manager.requestSerializer setValue:@"plants" forHTTPHeaderField:@"x-flowhub-context"];
    [manager.requestSerializer setValue:plant.clientId forHTTPHeaderField:@"x-flowhub-clientId"];
    [manager.requestSerializer setValue:plant.license forHTTPHeaderField:@"x-flowhub-license"];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSDictionary *infoDictionary = @{@"tagId": plant.tagId, @"wetWeight": plant.wetWeight, @"strainName": plant.strain, @"roomName": plant.currentRoomName};
        
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDictionary
                                                           options:0
                                                             error:&error];
    if (! jsonData) {
        NSLog(@"Got an error with jsonData: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"JSON String: %@", jsonString);
        [manager.requestSerializer setValue:jsonString forHTTPHeaderField:@"x-flowhub-info"];
    }
        
    NSDictionary *parameters = @{
                                     @"wetWeight": plant.wetWeight
                                     };
    
    [manager PUT:[NSString stringWithFormat:@"%@plants/%@?access_token=%@", urlString, plant.tagId, [[NSUserDefaults standardUserDefaults] objectForKey:@"token"]] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"responseObject: %@", responseObject);
        completionBlock(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", error);
        NSLog(@"request headers: %@", manager.requestSerializer.HTTPRequestHeaders);
        completionBlock(error.localizedDescription);
    }];
}


// PUT new flags for plants
- (void)updatePlantsFlagsForScannedPlants:(NSArray *)plantsToFlagArray WithFlags:(NSArray *)flagsArray WithCompletion:(void (^)(NSString *errorString))completionBlock {
    NSString * urlString = [[NSString alloc] initWithString:[self setupServerBaseUrlString]];
    
    NSLog(@"tagsToMoveArray: %@", plantsToFlagArray);
    NSLog(@"flags: %@", flagsArray);

    for (Plant *plant in plantsToFlagArray) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        [manager.requestSerializer setValue:@"flagPlant" forHTTPHeaderField:@"x-flowhub-operation"];
        [manager.requestSerializer setValue:@"plants" forHTTPHeaderField:@"x-flowhub-context"];
        [manager.requestSerializer setValue:plant.clientId forHTTPHeaderField:@"x-flowhub-clientId"];
        [manager.requestSerializer setValue:plant.license forHTTPHeaderField:@"x-flowhub-license"];
        
        NSDictionary *infoDictionary = @{@"tagId": plant.tagId, @"flags": flagsArray};
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDictionary
                                                           options:0
                                                             error:&error];
        if (! jsonData) {
            NSLog(@"Got an error with jsonData: %@", error);
        }
        else {
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"JSON String: %@", jsonString);
            [manager.requestSerializer setValue:jsonString forHTTPHeaderField:@"x-flowhub-info"];
        }

        NSDictionary *parameters = @{
                                     @"flags" : flagsArray,
                                     };
        
        [manager PUT:[NSString stringWithFormat:@"%@plants/%@?access_token=%@", urlString, plant.tagId, [[NSUserDefaults standardUserDefaults] objectForKey:@"token"]] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"responseObject: %@", responseObject);
            completionBlock(nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error: %@", error);
            NSLog(@"error: %@", error.localizedDescription);
            NSLog(@"operation: %@", operation);

            completionBlock(error.localizedDescription);
        }];
    }
}

// DELETE plants to destroy
- (void)deleteScannedPlants:(NSArray *)plantsToDestroyArray WithReason:(NSString *)reason WithCompletion:(void (^)(NSString *errorString))completionBlock {
    NSString * urlString = [[NSString alloc] initWithString:[self setupServerBaseUrlString]];

    NSLog(@"tagsToDestroyArray: %@", plantsToDestroyArray);
    for (Plant *plant in plantsToDestroyArray) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [manager.requestSerializer setValue:@"destroyPlant" forHTTPHeaderField:@"x-flowhub-operation"];
        [manager.requestSerializer setValue:@"plants" forHTTPHeaderField:@"x-flowhub-context"];
        [manager.requestSerializer setValue:plant.clientId forHTTPHeaderField:@"x-flowhub-clientId"];
        [manager.requestSerializer setValue:plant.license forHTTPHeaderField:@"x-flowhub-license"];

        NSDictionary *infoDictionary = @{
                                         @"tagId": plant.tagId,
                                         @"reason": reason
                                         };
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDictionary
                                                           options:0
                                                             error:&error];
        if (! jsonData) {
            NSLog(@"Got an error with jsonData: %@", error);
        }
        else {
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [manager.requestSerializer setValue:jsonString forHTTPHeaderField:@"x-flowhub-info"];
        }
        NSDictionary *parameters = @{@"state": @{@"state": @"destroyed"}};
        NSLog(@"plant.tagID: %@", plant.tagId);
        NSLog(@"Token: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"token"]);
        [manager DELETE:[NSString stringWithFormat:@"%@plants/%@?access_token=%@", urlString, plant.tagId, [[NSUserDefaults standardUserDefaults] objectForKey:@"token"]] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"responseObject: %@", responseObject);
            completionBlock(nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error: %@", error);
            completionBlock(error.localizedDescription);
        }];
    }
}

#pragma mark - Room Calls
// GET rooms user can access
- (void)getUsersRoomsWithCompletion:(void (^)(NSArray *roomArray, NSString *errorString))completionBlock {
    NSString * urlString = [[NSString alloc] initWithString:[self setupServerBaseUrlString]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSDictionary *parameters = @{@"access_token" : [[NSUserDefaults standardUserDefaults] valueForKey:@"token"]};
    
    [manager GET:[NSString stringWithFormat:@"%@rooms", urlString] parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Response Object: %@", responseObject);
            NSMutableArray *roomArray = [[NSMutableArray alloc] init];
                
             for (NSDictionary *jsonRoomObject in responseObject) {
                 Room *room = [[Room alloc] init];
                 room.roomId = [jsonRoomObject valueForKey:@"_id"];
                 room.roomName = [jsonRoomObject valueForKey:@"name"];
                 
                 [roomArray addObject:room];
             }
             //Take the Mutable and set it to an immutable array
             NSArray *roomsArray = [[NSArray alloc] initWithArray:roomArray];
             //encode the data since it's custom objects
             NSData *data = [NSKeyedArchiver archivedDataWithRootObject:roomsArray];
             //store them here
             [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"encodedUserRooms"];
             //This is an example of how to decode the data for use later
             NSArray *decodedUserRooms = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"encodedUserRooms"]];
             NSLog(@"Saved Room Array: %@", decodedUserRooms);
             
         completionBlock(decodedUserRooms, nil);
    }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", error.localizedDescription);
             completionBlock(nil, error.localizedDescription);
    }];
}

#pragma mark - POST new immature clones
- (void)postNewClonesFromMother:(Plant *)motherPlant inRoom:(Room *)room withQuantity:(NSInteger )quantity WithCompletion:(void (^)(NSString *errorString))completionBlock {
        NSString * urlString = [[NSString alloc] initWithString:[self setupServerBaseUrlString]];

        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  
        //always set up the request serializer or you will get errors all day
        manager.requestSerializer = [AFJSONRequestSerializer serializer];

        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [manager.requestSerializer setValue:@"newImmature" forHTTPHeaderField:@"x-flowhub-operation"];
        [manager.requestSerializer setValue:@"immatures" forHTTPHeaderField:@"x-flowhub-context"];

        NSDictionary *infoDictionary = @{@"motherPlantTag" : motherPlant.tagId,
                                         @"quantity" : [NSNumber numberWithInteger:quantity],
                                         @"roomName" : room.roomName,
                                         @"strainName" : motherPlant.strain
                                         
                                         };

        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDictionary
                                                       options:0
                                                         error:&error];
        if (! jsonData) {
            NSLog(@"Got an error with jsonData: %@", error);
        } else {
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"JSON String: %@", jsonString);
          
            [manager.requestSerializer setValue:jsonString forHTTPHeaderField:@"x-flowhub-info"];
        }

        NSDictionary *parameters = @{@"roomId" : room.roomId,
                                     @"licenseId" : motherPlant.license,
                                     @"strainId" : motherPlant.strainId,
                                     @"quantity" : [NSNumber numberWithInteger:quantity],
                                     @"motherId" : motherPlant.tagId,
                                     @"clientId" : [[NSUserDefaults standardUserDefaults] objectForKey:@"clientId"]
                                     };
  
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
  
        [manager POST:[NSString stringWithFormat:@"%@immatures/?access_token=%@", urlString, token] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

            NSLog(@"JSON: %@", responseObject);

            completionBlock(nil);

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          
          
            NSLog(@"The error is: %@", error);
          
            completionBlock([NSString stringWithFormat:@"%ld", (long)operation.response.statusCode]);
        }];
  
}

//#pragma mark - Version Calls
// GET current verion
- (void) getCurrentVersionWithCompletion:(void (^)(Version *versionObject, NSString *errorString))completionBlock {

    NSString *urlString = ProductionBaseBackendURLString;

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    [manager GET:[NSString stringWithFormat:@"%@versions/mobile", urlString] parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {

             NSLog(@"Response Object: %@", responseObject);

             Version *versionObject = [Version new];
             versionObject.versionNumber = [responseObject valueForKey:@"number"];
             versionObject.versionDescription = [responseObject valueForKey:@"text"];
             versionObject.versionUrl = [responseObject valueForKey:@"url"];

             completionBlock(versionObject, nil);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Get Version error: %@", error.localizedDescription);
             completionBlock(nil, error.localizedDescription);
         }];

}

// PUT new room to all plants scanned
#pragma mark - Updat plants current room
- (void)updatePlantCurrentRoom:(Plant *)plant IntoRoom:(NSString *)roomId WithRoomName:(NSString *)roomName WithCompletion:(void (^)(NSString *errorString))completionBlock {
    NSString *urlString = [[NSString alloc] initWithString:[self setupServerBaseUrlString]];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    [manager.requestSerializer setValue:@"movePlant" forHTTPHeaderField:@"x-flowhub-operation"];
    [manager.requestSerializer setValue:@"plants" forHTTPHeaderField:@"x-flowhub-context"];
    [manager.requestSerializer setValue:plant.clientId forHTTPHeaderField:@"x-flowhub-clientId"];
    [manager.requestSerializer setValue:plant.license forHTTPHeaderField:@"x-flowhub-license"];

    NSDictionary *infoDictionary = @{@"tagId": plant.tagId, @"roomFrom": plant.currentRoomName, @"roomTo": plant.moveToRoomName};

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDictionary options:0 error:&error];
    if (! jsonData) {
        NSLog(@"Got an error with jsonData: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"JSON String: %@", jsonString);
        [manager.requestSerializer setValue:jsonString forHTTPHeaderField:@"x-flowhub-info"];
    }

    NSDictionary *parameters = @{
                                 @"roomId": roomId,
                                 @"plantId": plant.tagId
                                 };

    [manager PUT:[NSString stringWithFormat:@"%@plants/%@?access_token=%@", urlString, plant.tagId, [[NSUserDefaults standardUserDefaults] objectForKey:@"token"]] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"responseObject: %@", responseObject);
        completionBlock(nil);
    }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"error: %@", error);
             NSLog(@"request headers: %@", manager.requestSerializer.HTTPRequestHeaders);
             completionBlock(error.localizedDescription);
         }];
}


#pragma mark - API Methods for testing 


















@end