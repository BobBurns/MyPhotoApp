//
//  Faulter.h
//  MyPhotoLibrary
//
//  Created by WozniBob on 8/7/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Faulter : NSObject

+ (void)faultObjectWithID:(NSManagedObjectID *)objectID
                inContext:(NSManagedObjectContext *)context;

@end
