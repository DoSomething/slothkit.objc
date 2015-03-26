//
//  DSOCampaignDetailViewController.m
//  SlothieBoy
//
//  Created by Aaron Schachter on 3/4/15.
//  Copyright (c) 2015 Aaron Schachter. All rights reserved.
//

#import "DSOCampaignDetailViewController.h"
#import "DSOReportbackViewController.h"
#import <SlothKit/SlothKit.h>

@interface DSOCampaignDetailViewController ()
@property (nonatomic, assign) BOOL isSignedUp;
@property (nonatomic, assign) BOOL isCompleted;
@property (nonatomic, assign) NSInteger rbid;
@property (weak, nonatomic) IBOutlet UILabel *ctaLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
- (IBAction)actionTapped:(id)sender;

@end

@implementation DSOCampaignDetailViewController

- (void)setCampaign:(DSOCampaign *)campaign {
    _campaign = campaign;

    self.title = campaign.title;
    self.ctaLabel.text = campaign.callToAction;
    self.coverImage.image = campaign.coverImage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isSignedUp = NO;
    self.isCompleted = NO;
    self.actionButton.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [DSOCampaign campaignWithID:self.campaign.campaignID completion:^(DSOCampaign *campaign, NSError *error) {
        self.campaign = campaign;
    }];

    [self.campaign myActivity:^(DSOCampaignActivity *activity, NSError *error) {
        if(error) {
            NSLog(@"%@", error.localizedDescription);
            return;
        }

        if (activity.hasSignedUp) {
            self.isSignedUp = YES;
            [self.actionButton setTitle:@"Prove It" forState:UIControlStateNormal];
        }
        if (activity.hasReportedBack) {
            self.isCompleted = YES;
            [self.actionButton setTitle:@"Proved It!" forState:UIControlStateNormal];
        }
        self.actionButton.hidden = NO;
    }];
}

- (IBAction)actionTapped:(id)sender {
   if (self.isSignedUp) {
        UINavigationController *rbNavVC = [self.storyboard instantiateViewControllerWithIdentifier:@"reportbackNavigationController"];
        DSOReportbackViewController *destVC = (DSOReportbackViewController *)rbNavVC.topViewController;
        [destVC setCampaign:self.campaign];
        [self presentViewController:rbNavVC animated:YES completion:nil];
    }
    else {
        [self.campaign signupFromSource:@"SlothieBoy Example" completion:^(NSError *error) {
            if(error) {
                NSLog(@"%@", error.localizedDescription);
                return;
            }

            [self.actionButton setTitle:@"Prove It" forState:UIControlStateNormal];
            self.isSignedUp = YES;
        }];
    }
}
@end
