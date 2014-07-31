//
//  Folders.h
//  MyPhotoLibrary
//
//  Created by WozniBob on 7/30/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photos;

@interface Folders : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSSet *images;
@end

@interface Folders (CoreDataGeneratedAccessors)

- (void)addImagesObject:(Photos *)value;
- (void)removeImagesObject:(Photos *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

@end
