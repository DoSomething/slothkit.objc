//
//  DSOLoginViewController.m
//  SlothieBoy
//
//  Created by Aaron Schachter on 3/5/15.
//  Copyright (c) 2015 Aaron Schachter. All rights reserved.
//

#import "DSOLoginViewController.h"
#import "SlothKit/DSOClient.h"

@interface DSOLoginViewController ()
@property (strong, nonatomic) DSOClient *client;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
- (IBAction)submitTapped:(id)sender;

@end

@implementation DSOLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.client = [DSOClient sharedClient];
    NSDictionary *authValues = [self.client getSavedLogin];
    if ([authValues count] > 0) {
        self.usernameTextField.text = authValues[@"username"];
        self.passwordTextField.text = authValues[@"password"];
    }
}

- (IBAction)submitTapped:(id)sender {
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    [self.client loginWithUsername:username password:password completionHandler:^(NSDictionary *response){
        NSLog(@"%@", response);
        UINavigationController *destNavVC = [self.storyboard instantiateViewControllerWithIdentifier:@"campaignListNavigationController"];
        [self presentViewController:destNavVC animated:YES completion:nil];
        
    } errorHandler:^(NSError *error){
        NSLog(@"%@", error.localizedDescription);
    }];
}
@end
