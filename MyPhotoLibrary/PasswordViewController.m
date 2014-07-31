//
//  PasswordViewController.m
//  MyPhotoLibrary
//
//  Created by WozniBob on 7/28/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import "PasswordViewController.h"

@interface PasswordViewController ()

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UISnapBehavior *passSnap;

@end

@implementation PasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *passEnter = [UIImage imageNamed:@"password_test.png"];
    UIImageView *passImage = [[UIImageView alloc] initWithImage:passEnter];
    [_passView addSubview:passImage];
    [_animator setDelegate:self];
    
    
    // Do any additional setup after loading the view.
    [self hideKeyboardWhenBackgroundIsTouched];
    self.passText.delegate = (id)self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideKeyboardWhenBackgroundIsTouched {
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [tgr setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tgr];
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - textField delegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.passText) {
        if ([_passText.text  isEqual: @"1234"]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            
            
            for (int i = 0; i < 5; ++i) {
                CGPoint point = CGPointMake(180, 180);
                [self snapIt:point];
                point = CGPointMake(200 , 180);
                [self snapIt:point];
            }
        }
    }
}
- (void)snapIt:(CGPoint)toPoint {
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    _passSnap = [[UISnapBehavior alloc] initWithItem:_passLabel snapToPoint:toPoint];
    _passSnap.damping = 0.0;
    [_animator addBehavior:_passSnap];
}
- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator
{
    NSLog(@"paused");
    [_animator removeBehavior:_passSnap];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
