//
//  DSOCampaignDetailViewController.m
//  SlothieBoy
//
//  Created by Aaron Schachter on 3/4/15.
//  Copyright (c) 2015 Aaron Schachter. All rights reserved.
//

#import "DSOCampaignDetailViewController.h"
#import "DSOReportbackViewController.h"
#import <SlothKit/DSOAPIClient.h>

@interface DSOCampaignDetailViewController ()
@property (strong, nonatomic) DSOAPIClient *client;
@property (nonatomic, assign) BOOL isSignedUp;
@property (nonatomic, assign) BOOL isCompleted;
@property (nonatomic, assign) NSInteger rbid;
@property (weak, nonatomic) IBOutlet UILabel *ctaLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
- (IBAction)actionTapped:(id)sender;

@end

@implementation DSOCampaignDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.client = [DSOAPIClient sharedClient];
    self.isSignedUp = NO;
    self.isCompleted = NO;
    self.actionButton.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.title = self.campaign.title;
    [self.client getCampaignWithNid:self.campaign.nid andCompletionHandler:^(NSDictionary *response){
        [self.campaign syncWithDictionary:response];
        self.ctaLabel.text = self.campaign.callToAction;
        self.coverImage.image = self.campaign.coverImage;
    }];
    [self.client getCurrentUserActivityWithNid:self.campaign.nid andCompletionHandler:^(NSDictionary *response){
        NSLog(@"response %@", response);
        if ([response objectForKey:@"sid"]) {
            self.isSignedUp = YES;
           [self.actionButton setTitle:@"Prove It" forState:UIControlStateNormal];
        }
        if ([response objectForKey:@"rbid"]) {
            self.isCompleted = YES;
            self.rbid = (NSInteger *)(long)response[@"rbid"];
            NSLog(@"rbid %@", self.rbid);
            [self.actionButton setTitle:@"Proved It!" forState:UIControlStateNormal];
        }
        self.actionButton.hidden = NO;
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)actionTapped:(id)sender {
   if (self.isSignedUp) {
        UINavigationController *rbNavVC = [self.storyboard instantiateViewControllerWithIdentifier:@"reportbackNavigationController"];
        DSOReportbackViewController *destVC = (DSOReportbackViewController *)rbNavVC.topViewController;
        [destVC setCampaign:self.campaign];
        [self presentViewController:rbNavVC animated:YES completion:nil];
    }
    else {
        [self.client postSignupForNid:self.campaign.nid
                        andSource:@"SlothieBoy Example"
             andCompletionHandler:^(NSDictionary *response){
                 [self.actionButton setTitle:@"Prove It" forState:UIControlStateNormal];
                 self.isSignedUp = YES;

             }
                  andErrorHandler:^(NSError *error){
                      NSLog(@"%@", error.localizedDescription);
                  }
         ];
    }
}
@end
