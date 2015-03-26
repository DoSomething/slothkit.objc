//
//  DSOLoginViewController.m
//  SlothieBoy
//
//  Created by Aaron Schachter on 3/5/15.
//  Copyright (c) 2015 Aaron Schachter. All rights reserved.
//

#import "DSOLoginViewController.h"
#import <SlothKit/DSOSession.h>

@interface DSOLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
- (IBAction)submitTapped:(id)sender;

@end

@implementation DSOLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.usernameTextField.text = [DSOSession lastLoginUsername];
//    self.passwordTextField.text = authValues[@"password"];
}

- (IBAction)submitTapped:(id)sender {
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    [DSOSession startWithUsername:username password:password success:^(DSOSession *session) {
        UINavigationController *destNavVC = [self.storyboard instantiateViewControllerWithIdentifier:@"campaignListNavigationController"];
        [self presentViewController:destNavVC animated:YES completion:nil];
    } failure:^(NSError *error) {
        NSLog(@"Error logging in: %@", error.localizedDescription);
    }];
}
@end
