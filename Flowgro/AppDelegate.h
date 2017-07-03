//
//  AppDelegate.h
//  Flowgro
//
//  Created by Wade Sellers on 12/12/14.
//  Copyright (c) 2014 Flowhub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Captuvo.h"




@interface AppDelegate : UIResponder <UIApplicationDelegate, CaptuvoEventsProtocol>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) UIView *inputAccessoryView;



- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

