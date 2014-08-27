//
//  Photos.h
//  MyPhotoLibrary
//
//  Created by WozniBob on 8/26/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Folders, FullSize;

@interface Photos : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * thumb;
@property (nonatomic, retain) NSNumber * isVideo;
@property (nonatomic, retain) FullSize *full;
@property (nonatomic, retain) Folders *photoAlbum;

@end
