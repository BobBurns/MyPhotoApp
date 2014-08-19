//
//  AppDelegate.m
//  MyPhotoLibrary
//
//  Created by WozniBob on 7/25/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import "AppDelegate.h"

#define debug 1
#define kEnterExistingPinAlert 1
#define kEnterNewPinAlert 2

@interface AppDelegate ()

@end

@implementation AppDelegate

- (CoreDataHelper *)cdh {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (!_coreDataHelper) {
        static dispatch_once_t predicate;
        dispatch_once(&predicate, ^{
            _coreDataHelper = [CoreDataHelper new];
        });
        
       [_coreDataHelper setupCoreData];
    }
    return _coreDataHelper;
}

+ (void)initialize
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [NSNumber numberWithBool:YES], @"firstRun",
      nil]];
}

#pragma mark - touch id methods

- (void)canEvaluatePolicy
{
    LAContext *context = [[LAContext alloc] init];
    __block  NSString *msg;
    NSError *error;
    BOOL success;
    
    // test if we can evaluate the policy, this test will tell us if Touch ID is available and enrolled
    success = [context canEvaluatePolicy: LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    if (success) {
        msg =[NSString stringWithFormat:NSLocalizedString(@"TOUCH_ID_IS_AVAILABLE", nil)];
        [self evaluatePolicy];
    } else {
        
        /*old alert method
        msg =[NSString stringWithFormat:NSLocalizedString(@"TOUCH_ID_IS_NOT_AVAILABLE", nil)];
        self.noTouchAlert = [[UIAlertView alloc] initWithTitle:@"TouchId not enabled"
                                                       message:@"Please enter password"
                                                      delegate:(id)self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"OK", nil];
        self.noTouchAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        
        _passText = [self.noTouchAlert textFieldAtIndex:0];
        _passText.clearButtonMode = UITextFieldViewModeWhileEditing;
        //_passText.keyboardAppearance = UIKeyboardTypeDecimalPad;
        [self.noTouchAlert show];
         */
    }
    NSLog(@"%@", msg);
    [self usePasswordInstead];
    
}
- (void)evaluatePolicy
{
    LAContext *context = [[LAContext alloc] init];
    __block  NSString *msg;
    
    // show the authentication UI with our reason string
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:NSLocalizedString(@"You can only access this app through TouchID", nil) reply:
     ^(BOOL success, NSError *authenticationError) {
         if (success) {
             msg =[NSString stringWithFormat:NSLocalizedString(@"EVALUATE_POLICY_SUCCESS", nil)];
         } else {
             msg = [NSString stringWithFormat:NSLocalizedString(@"EVALUATE_POLICY_WITH_ERROR", nil), authenticationError.localizedDescription];
             NSLog(@"%@", msg);
             exit(1);
         }
         NSLog(@"%@", msg);
     }];
    
}
// old password alert
/*
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.noTouchAlert) {
        if (buttonIndex == 0) {
            NSLog(@"Canceled password");
            exit(1);
        }
        if(buttonIndex==1)//OK button
        {
            NSLog(@"Password: %@", _passText.text);
            if ([_passText.text isEqual:@"1234"]) {
                return;
            }
            else {
                NSLog(@"password incorrect");
                exit(1);
                // do more stuff
            }
        }
        
    }
}
*/
#pragma mark - KeyChain methods

- (void)usePasswordInstead {
    
    _pinWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"com.chefspecialapp.keychain.pin" accessGroup:nil];
    //[_pinWrapper resetKeychainItem];
    
    [_pinWrapper setObject:(__bridge id)(kSecAttrAccessibleWhenUnlocked) forKey: (__bridge id)kSecAttrAccessible];
    //[_pinWrapper setObject:@"pinIdentifer" forKey: (__bridge id)kSecAttrAccount];
    
    if([[_pinWrapper objectForKey:(__bridge id)(kSecValueData)] length] == 0)
    {
        UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:@"Enter New Pin" message:@"please enter password" delegate:(id)self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        dialog.tag = kEnterNewPinAlert;
        dialog.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        _pinField = [dialog textFieldAtIndex:0];
        [_pinField setPlaceholder:@"Enter PIN"];
        [_pinField setSecureTextEntry: YES];
        [_pinField setKeyboardType:UIKeyboardTypeNumberPad];
        [_pinField setBackgroundColor:[UIColor whiteColor]];
        
        _repeatPinField = [dialog textFieldAtIndex:1];
        [_repeatPinField setPlaceholder:@"Repeat PIN"];
        [_repeatPinField setSecureTextEntry: YES];
        [_repeatPinField setKeyboardType:UIKeyboardTypeNumberPad];
        [_repeatPinField setBackgroundColor:[UIColor whiteColor]];
        
        [dialog show];
        
        [_pinField becomeFirstResponder];
    }
    //pin already set
    else
    {
        UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:@"Enter Pin" message:nil delegate:(id)self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        dialog.tag = kEnterExistingPinAlert;
        dialog.alertViewStyle = UIAlertViewStyleSecureTextInput;
        _pinField = [dialog textFieldAtIndex:0];
        [_pinField setPlaceholder:@"Enter PIN"];
        //[_pinField setSecureTextEntry: YES];
        [_pinField setKeyboardType:UIKeyboardTypeNumberPad];
        [_pinField setBackgroundColor:[UIColor whiteColor]];
       // [dialog addSubview:_pinField];
        
        [dialog show];
        
        [_pinField becomeFirstResponder];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == kEnterExistingPinAlert)
    {
        //pin number entered was correct
        if([_pinField.text isEqualToString: [_pinWrapper objectForKey:(__bridge id)(kSecValueData)]])
        {
            KeychainItemWrapper *secureDataKeychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"com.chefspecialapp.keychain.securedData" accessGroup:nil];
            NSString *secureDataString = [secureDataKeychain objectForKey:(__bridge id)(kSecValueData)];
            
            //we have stored data for this keychain
            if([secureDataString length] != 0)
            {
                
                NSLog(@"Got Access");
                return;
            }
            
            else
            {
                NSLog(@"No keychain data stored yet");
            }
        }
        
        //pin entered was incorrect
        else
        {
            UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:@"Incorrect Pin!" message:nil delegate:(id)self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            dialog.tag = kEnterExistingPinAlert;
            
            _pinField = [dialog textFieldAtIndex:0];
            [_pinField setPlaceholder:@"Enter PIN"];
            [_pinField setSecureTextEntry: YES];
            [_pinField setKeyboardType:UIKeyboardTypeNumberPad];
            [_pinField setBackgroundColor:[UIColor whiteColor]];
            //[dialog addSubview:_pinField];
            
            [dialog show];
            
            [_pinField becomeFirstResponder];
        }
    }
    
    else
    {
        if([_pinField.text isEqualToString: _repeatPinField.text])
        {
            [_pinWrapper setObject:[_pinField text] forKey:(__bridge id)(kSecValueData)];
        }
        
        else
        {
            UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:@"Pins Did Not Match" message:nil delegate:(id)self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            dialog.tag = kEnterNewPinAlert;
            
            _pinField = [dialog textFieldAtIndex:0];
            [_pinField setPlaceholder:@"Enter PIN"];
            [_pinField setSecureTextEntry: YES];
            [_pinField setKeyboardType:UIKeyboardTypeNumberPad];
            [_pinField setBackgroundColor:[UIColor whiteColor]];
            //[dialog addSubview:_pinField];
            
            _repeatPinField = [dialog textFieldAtIndex:1];
            [_repeatPinField setPlaceholder:@"Repeat PIN"];
            [_repeatPinField setSecureTextEntry: YES];
            [_repeatPinField setKeyboardType:UIKeyboardTypeNumberPad];
            [_repeatPinField setBackgroundColor:[UIColor whiteColor]];
            //[dialog addSubview:_repeatPinField];
            
            [dialog show];
            
            [_pinField becomeFirstResponder];
        }
    }
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[self cdh] iCloudAccountIsSignedIn];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
   [[self cdh] backgroundSaveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self canEvaluatePolicy];
}

- (void)applicationWillTerminate:(UIApplication *)application {
   [[self cdh] backgroundSaveContext];
}
@end
