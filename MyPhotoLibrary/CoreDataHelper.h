//
//  CoreDataHelper.h
//  MyPhotoLibrary
//
//  Created by WozniBob on 7/29/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Folders.h"

@interface CoreDataHelper : NSObject

@property (nonatomic, readonly) NSManagedObjectContext *context;
@property (nonatomic, readonly) NSManagedObjectModel *model;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *coordinator;
@property (nonatomic, readonly) NSPersistentStore *store;
@property (nonatomic, strong) Folders *defaultFolder;

- (void)setupCoreData;
- (void)saveContext; // Thank you Tim Roadley

@end
