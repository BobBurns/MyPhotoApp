//
//  AppDelegate.h
//  MyPhotoLibrary
//
//  Created by WozniBob on 7/25/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Security/Security.h>
#import <StoreKit/StoreKit.h>

#import "CoreDataHelper.h"
#import "KeychainItemWrapper.h"


@import LocalAuthentication;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate, SKPaymentTransactionObserver>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong, readonly) CoreDataHelper *coreDataHelper;

@property (nonatomic, strong) UITextField *passText;
@property (nonatomic, strong) UITextField *pinField;
@property (nonatomic, strong) UITextField *repeatPinField;
@property (nonatomic, strong) KeychainItemWrapper *pinWrapper;


@property (nonatomic, strong) UIAlertView *noTouchAlert;

- (CoreDataHelper *)cdh;

@end

