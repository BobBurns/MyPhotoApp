//
//  ViewController.m
//  MyPhotoLibrary
//
//  Created by WozniBob on 7/25/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//


//#import <LocalAuthentication/LocalAuthentication.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "ViewController.h"
#import "RBLibraryTableViewCell.h"
#import "RBGroupViewController.h"
#import "PasswordViewController.h"

#define kGroupLabelText @"groupLabelText"
#define kGroupInfoText @"groupInfoText"
#define kGroupURL @"groupURL"
#define kGroupPosterImage @"groupPosterImage"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UILabel *label;
@property (nonatomic, strong) UITextField *passText;

@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Albums";
    
    [self setUp];
    // TouchId calls to authenticate.
    // needs switch to handle return error codes
    /*
    LAContext *myContext = [[LAContext alloc] init];
    NSError *authError = nil;
    NSString *myLocalizedReasonString = @"You must authenticate before using this app";
    
    if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
        [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                  localizedReason:myLocalizedReasonString
                            reply:^(BOOL success, NSError *error) {
                                if (success) {
                                    [self doSomethingInteresting];
                                } else {
                                    abort(); // User did not authenticate successfully, look at error and take appropriate action
                                }
                            }];
    } else {
        NSString *msgError;
        switch (authError.code) {
                
            case LAErrorAuthenticationFailed:
                msgError = @"Authentication Failed";
                break;
                
            case LAErrorUserCancel:
                msgError = @"User pressed Cancel button";
                break;
                
            case LAErrorUserFallback:
                msgError = @"User pressed Enter Password";
                break;
            case kLAErrorTouchIDNotAvailable:
                msgError = @"Device doesn't support TouchId";
                break;
                
            default:
                msgError = @"Touch ID is not configured";
                break;
        }
        
        NSLog(@"Authentication Fails: %@", msgError);
        
    
        NSLog(@"error getting authentication %@", authError.description);
        // get password manually
        
         SecondViewController *secondViewController =
         [self.storyboard instantiateViewControllerWithIdentifier:@"secondViewController"];
         [self presentModalViewController:secondViewController animated:YES];
         
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PasswordViewController *passVC = (PasswordViewController*)[storyboard instantiateViewControllerWithIdentifier:@"passwordStory"];
        [self presentViewController:passVC animated:YES completion:^{
            [self setUp];
        }];

        //[self setUp]; // for now
        // Could not evaluate policy; look at authError and present an appropriate message to user
     
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TouchId not enabled"
                                                        message:@"Please enter password"
                                                       delegate:(id)self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
        alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        
        _passText = [alert textFieldAtIndex:0];
        _passText.clearButtonMode = UITextFieldViewModeWhileEditing;
        _passText.keyboardAppearance = UIKeyboardTypeDecimalPad;
        [alert show];
    }
    */
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)//OK button
    {
        NSLog(@"Password: %@", _passText.text);
        if ([_passText.text isEqual:@"1234"]) {
            [self setUp];
        }
        else {
            NSLog(@"password incorrect");
            // do more stuff
        }
    }
}

- (void)setUp
{
    ALAssetsLibrary *al =
    [[ALAssetsLibrary alloc] init];
    
    NSMutableArray *setupArray = [[NSMutableArray alloc] init];
    
    void (^enumerateAssetGroupsBlock)(ALAssetsGroup*, BOOL*) =
    ^(ALAssetsGroup* group, BOOL* stop) {
        if (group)
        {
            NSUInteger numAssets = [group numberOfAssets];
            
            NSString *groupName =
            [group valueForProperty:ALAssetsGroupPropertyName];
            NSLog(@"Group: %@, editable: %d",groupName, [group isEditable]);
            
            NSURL *groupURL =
            [group valueForProperty:ALAssetsGroupPropertyURL];
            
            NSString *groupLabelText =
            [NSString stringWithFormat:@"%@ (%lu)",groupName, (unsigned long)numAssets];
            
            UIImage *posterImage =
            [UIImage imageWithCGImage:[group posterImage]];
            
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            NSInteger groupPhotos = [group numberOfAssets];
            
            [group setAssetsFilter:[ALAssetsFilter allVideos]];
            NSInteger groupVideos = [group numberOfAssets];
            
            NSString *info = @"%d photos, %d videos in group";
            NSString *groupInfoText =
            [NSString stringWithFormat:info ,groupPhotos, groupVideos];
            
            NSDictionary *groupDict =
            @{kGroupLabelText: groupLabelText,
              kGroupURL:groupURL,
              kGroupPosterImage:posterImage,
              kGroupInfoText:groupInfoText};
            
            [setupArray addObject:groupDict];
        }
        else
        {
            [self setAssetGroupArray:
             [NSArray arrayWithArray:setupArray]];
            
            [_assetGroupTableView reloadData];
        }
    };
    
    void (^assetGroupEnumErrorBlock)(NSError*) =
    ^(NSError* error) {
        
        NSString *msgError =
        @"Cannot access photo library. \n"
        "Please check photo permissions in settings.";
        
        UIAlertView* alertView =
        [[UIAlertView alloc] initWithTitle:nil
                                   message:msgError
                                  delegate:self
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        
        [alertView show];
    };
    
    [al enumerateGroupsWithTypes:ALAssetsGroupAll
                      usingBlock:enumerateAssetGroupsBlock
                    failureBlock:assetGroupEnumErrorBlock];
    
}
#pragma mark - Table methods
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    NSInteger returnCount = 0;
    
    if (_assetGroupArray) {
        returnCount = [_assetGroupArray count];
    }
    return returnCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = @"RBLibraryTableViewCell";
    RBLibraryTableViewCell *cell = (RBLibraryTableViewCell *)
    [tableView dequeueReusableCellWithIdentifier:cellID];
    
    NSDictionary *cellDict =
    [_assetGroupArray objectAtIndex:indexPath.row];
    
    [cell.assetGroupNameLabel
     setText:[cellDict objectForKey:kGroupLabelText]];
    
    [cell.assetGroupInfoLabel
     setText:[cellDict objectForKey:kGroupInfoText]];
    
    [cell.assetGroupTopImageView
     setImage:[cellDict objectForKey:kGroupPosterImage]];
    
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GroupView"])
    {
        NSIndexPath *indexPath =
        [_assetGroupTableView indexPathForSelectedRow];
        
        NSDictionary *selectedDict =
        [_assetGroupArray objectAtIndex:indexPath.row];
        
        [self setSelectedGroupURL:
         [selectedDict objectForKey:kGroupURL]];
        
        RBGroupViewController *groupVC =
        segue.destinationViewController;
        
        [groupVC setAssetGroupURL:[self selectedGroupURL]];
        
        [groupVC setAssetGroupName:
         [selectedDict objectForKey:kGroupLabelText]];
        
        [_assetGroupTableView
         deselectRowAtIndexPath:indexPath animated:NO];
    }
}


- (void)doSomethingInteresting
{
    
}

@end
