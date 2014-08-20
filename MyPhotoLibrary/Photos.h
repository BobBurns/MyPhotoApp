//
//  Photos.h
//  MyPhotoLibrary
//
//  Created by WozniBob on 8/20/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Folders, FullSize;

@interface Photos : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * photo;
@property (nonatomic, retain) NSData * thumb;
@property (nonatomic, retain) Folders *photoAlbum;
@property (nonatomic, retain) FullSize *full;

@end
