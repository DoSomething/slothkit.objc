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
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
- (IBAction)submitTapped:(id)sender;

@end

@implementation DSOLoginViewController

- (IBAction)submitTapped:(id)sender {
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    
    DSOClient *client = [DSOClient sharedClient];
    
    [client loginWithUsername:username andPassword:password andCompletionHandler:^(NSDictionary *response){
        NSLog(@"%@", response);
        UINavigationController *destNavVC = [self.storyboard instantiateViewControllerWithIdentifier:@"campaignListNavigationController"];
        [self presentViewController:destNavVC animated:YES completion:nil];
        
    } andErrorHandler:^(NSError *error){
        NSLog(@"%@", error.localizedDescription);
    }];
}
@end
