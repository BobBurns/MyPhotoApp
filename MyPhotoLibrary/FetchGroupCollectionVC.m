//
//  FetchGroupCollectionVC.m
//  MyPhotoLibrary
//
//  Created by WozniBob on 8/14/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import "FetchGroupCollectionVC.h"
#import "CDDetailViewController.h"

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
    
    // Fetch objects
    [self performFetch];
    
}
- (void)performFetch {
    NSError *error = nil;
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    
    
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
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photos"];
    
    request.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"photoAlbum"
                                                                                      ascending:YES],
                               [NSSortDescriptor sortDescriptorWithKey:@"date"
                                                             ascending:YES],
                               nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"photoAlbum.name = 'defaultFolder'"];
    [request setPredicate:predicate];
    
    
    
    _resultArray = [cdh.context executeFetchRequest:request error:&error];
    
    if (!_resultArray) {
        NSLog(@"Error = %@", error);
    } else {
        NSLog(@"got object array");
        
        [self.collectionView reloadData]; // incase of any changes
    }
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

    NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
    Photos *selPhoto = [self.resultArray objectAtIndex:indexPath.row];
    _selectedPhotoID = selPhoto.objectID;

    if ([segue.identifier isEqualToString:@"showPhoto"]) {
        
        CDDetailViewController *detailVC = segue.destinationViewController;
        [self.collectionView reloadData];
        [detailVC setPhotoID:self.selectedPhotoID];
        
        //_resultArray = nil;
    }
}


#pragma mark <UICollectionViewDataSource>



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return _resultArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell
    if (debug == 1) {
        NSLog(@"running %@ '%@'", self.class , NSStringFromSelector(_cmd));
    }
    CDGroupCell *myCell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    //CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    
    
    Photos *photoObject = [self.resultArray objectAtIndex:indexPath.row];
    UIImage *groupImage = [UIImage imageWithData:photoObject.photo];
    // UIImage *thumbImage = [self createThumbnail:groupImage];
    
    myCell.thumbnailImage = groupImage;
    
    return myCell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (debug == 1) {
        NSLog(@"running %@ '%@'", self.class , NSStringFromSelector(_cmd));
    }
    NSLog(@"Item selected");
    Photos *selPhoto = [self.resultArray objectAtIndex:indexPath.row];
    _selectedPhotoID = selPhoto.objectID;
    
}



@end
