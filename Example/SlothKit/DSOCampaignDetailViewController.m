//
//  DSOCampaignDetailViewController.m
//  SlothieBoy
//
//  Created by Aaron Schachter on 3/4/15.
//  Copyright (c) 2015 Aaron Schachter. All rights reserved.
//

#import "DSOCampaignDetailViewController.h"
#import "DSOReportbackViewController.h"
#import <SlothKit/DSOClient.h>

@interface DSOCampaignDetailViewController ()
@property (strong, nonatomic) DSOClient *client;
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
    self.client = [DSOClient sharedClient];
    self.isSignedUp = NO;
    self.isCompleted = NO;
    self.actionButton.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.title = self.campaign.title;
    [self.client getCampaignWithNid:self.campaign.nid completionHandler:^(NSDictionary *response){
        [self.campaign syncWithDictionary:response];
        self.ctaLabel.text = self.campaign.callToAction;
        self.coverImage.image = self.campaign.coverImage;
    }];
    [self.client getCurrentUserActivityWithNid:self.campaign.nid completionHandler:^(NSDictionary *response){
        if ([response objectForKey:@"sid"]) {
            self.isSignedUp = YES;
           [self.actionButton setTitle:@"Prove It" forState:UIControlStateNormal];
        }
        if ([response objectForKey:@"rbid"]) {
            self.isCompleted = YES;
            self.rbid = [response[@"rbid"] intValue];
            [self.actionButton setTitle:@"Proved It!" forState:UIControlStateNormal];
        }
        self.actionButton.hidden = NO;
    }];
    
}

- (IBAction)actionTapped:(id)sender {
    NSInteger nid = self.campaign.nid;

   if (self.isSignedUp) {
        UINavigationController *rbNavVC = [self.storyboard instantiateViewControllerWithIdentifier:@"reportbackNavigationController"];
        DSOReportbackViewController *destVC = (DSOReportbackViewController *)rbNavVC.topViewController;
        [destVC setCampaign:self.campaign];
        [self presentViewController:rbNavVC animated:YES completion:nil];
    }
    else {
        [self.client postSignupForNid:nid
                        source:@"SlothieBoy Example"
             completionHandler:^(NSDictionary *response){
                 [self.actionButton setTitle:@"Prove It" forState:UIControlStateNormal];
                 self.isSignedUp = YES;

             }
                  errorHandler:^(NSError *error){
                      NSLog(@"%@", error.localizedDescription);
                  }
         ];
    }
}
@end
