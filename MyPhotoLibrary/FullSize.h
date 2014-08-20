//
//  FullSize.h
//  MyPhotoLibrary
//
//  Created by WozniBob on 8/20/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photos;

@interface FullSize : NSManagedObject

@property (nonatomic, retain) NSData * fullsizeImage;
@property (nonatomic, retain) Photos *full;

@end
