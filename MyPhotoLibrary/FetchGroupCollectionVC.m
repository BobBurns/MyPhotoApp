//
//  FetchGroupCollectionVC.m
//  MyPhotoLibrary
//
//  Created by WozniBob on 8/14/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import "FetchGroupCollectionVC.h"
#import "CDDetailViewController.h"
@import LocalAuthentication;

#import "AppDelegate.h"
#import "CoreDataHelper.h"
#import "Folders.h"
#import "Photos.h"
#import "Faulter.h"

#import "CDGroupCell.h"

#define debug 1

@interface FetchGroupCollectionVC ()

@property (nonatomic, strong) NSManagedObjectID *selectedPhotoID;

@end

@implementation FetchGroupCollectionVC

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    //[self.collectionView registerClass:[CDGroupCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(performFetch)
                                                 name:@"SomethingChanged"
                                               object:nil];
    self.collectionView.allowsMultipleSelection = NO;
    
    // Fetch objects
    [self performFetch];
    
    
}
- (void)viewDidAppear:(BOOL)animated {
    self.navigationItem.title = @"Photos";
    if (!_resultArray) {
        [self performFetch];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
   //[self faultObjects];
   // _resultArray = nil;
    NSLog(@"view will disapear");
}
- (void)dealloc {
    _resultArray = nil;
}

- (void)performFetch {
    NSError *error = nil;
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    
    /*
    NSFetchRequest *folderRequest = [NSFetchRequest fetchRequestWithEntityName:@"Folders"];
    folderRequest.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                            ascending:YES],
                                     nil];
    
    NSPredicate *folderPredicate = [NSPredicate predicateWithFormat:@"name == 'defaultFolder'"];
    [folderRequest setPredicate:folderPredicate];
    self.navigationItem.title = @"Photos";
    
    NSArray *folderFetch = [cdh.context executeFetchRequest:folderRequest error:&error];
    if (!folderFetch) {
        NSLog(@"Error fetching defaultFolder %@ '%@'", error, error.description);
    }
    NSLog(@"folder count: %lu", (unsigned long)[folderFetch count]);
    */
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photos"];
    
    request.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"photoAlbum"
                                                                                      ascending:YES],
                               [NSSortDescriptor sortDescriptorWithKey:@"date"
                                                             ascending:YES],
                               nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"photoAlbum.name = 'defaultFolder'"];
    [request setPredicate:predicate];
    [request setFetchBatchSize:30];
    /*
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                   managedObjectContext:cdh.context
                                                     sectionNameKeyPath:nil
                                                              cacheName:nil];
    NSLog(@" fetched objects = %lu", (unsigned long)self.frc.fetchedObjects.count);
    self.frc.delegate = (id)self;
    
    if (self.frc) {
        [self.frc.managedObjectContext performBlockAndWait:^{
            NSError *error = nil;
            if (![self.frc performFetch:&error]) {
                NSLog(@"Failed to perform fetch: %@", [error localizedDescription]);
            }
            [self.collectionView reloadData];
        }];
    } else {
        NSLog(@"Failed to fetch, the fetched results controller is nil.");
    }
    */
    
    [cdh.context performBlockAndWait:^{
        NSError *fetchError = nil;
        _resultArray = [cdh.context executeFetchRequest:request error:&fetchError];
        
        if (!_resultArray) {
            NSLog(@"Error = %@", error);
        } else {
            NSLog(@"got object array");
            
            
        }
    }];
    
    [self.collectionView reloadData]; // incase of any changes
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (debug == 1) {
        NSLog(@"running %@ '%@'", self.class , NSStringFromSelector(_cmd));
    }

    

    if ([segue.identifier isEqualToString:@"showPhoto"]) {
        
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        Photos *selPhoto = [_resultArray objectAtIndex:indexPath.row];
        
        CDDetailViewController *detailVC = segue.destinationViewController;
        //[self.collectionView reloadData];
        detailVC.displayPhoto = [UIImage imageWithData:selPhoto.photo];
        detailVC.photoID = selPhoto.objectID;
        detailVC.displayDate = selPhoto.date;
        
        
        //_resultArray = nil;
    }
}


#pragma mark <UICollectionViewDataSource>



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return _resultArray.count;
    //NSInteger objects = [[self.frc fetchedObjects] count];
    //return objects;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell
    if (debug == 1) {
        NSLog(@"running %@ '%@'", self.class , NSStringFromSelector(_cmd));
    }
    CDGroupCell *myCell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    
    //Photos *photoObject = [self.frc.fetchedObjects objectAtIndex:indexPath.row];
    
    Photos *photoObject = [self.resultArray objectAtIndex:indexPath.row];
    //UIImage *groupImage = [UIImage imageWithData:photoObject.photo];
    UIImage *thumbImage = [self createThumbnail:[UIImage imageWithData:photoObject.photo]];
    
    myCell.thumbnailImage = thumbImage;
    // try to increase fps
    myCell.layer.shouldRasterize = YES;
    myCell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    // try and save memory with faulting
    [Faulter faultObjectWithID:photoObject.objectID inContext:cdh.context];
    
    //release the image pointer
    thumbImage = nil;
    
    return myCell;
}
- (UIImage *)createThumbnail:(UIImage *)inPhoto {
    CGSize size = CGSizeMake(80.0, 80.0);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [inPhoto drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return thumbnail;
}

#pragma mark <UICollectionViewDelegate>



#pragma mark - fault objects

- (void)faultObjects {
    
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];

    for (Photos *photo in self.resultArray) {
        [Faulter faultObjectWithID:photo.objectID inContext:cdh.context];
    }
}



@end
