//
//  DSOReportbackViewController.m
//  SlothieBoy
//
//  Created by Aaron Schachter on 3/6/15.
//  Copyright (c) 2015 Aaron Schachter. All rights reserved.
//

#import "DSOReportbackViewController.h"
#import <SlothKit/DSOAPIClient.h>
#import "DSOCampaignDetailViewController.h"

@interface DSOReportbackViewController ()
@property (strong, nonatomic) DSOAPIClient *client;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UITextField *quantityTextField;
@property (weak, nonatomic) IBOutlet UITextView *imageURLTextField;
@property (weak, nonatomic) IBOutlet UITextView *whyParticipatedTextField;
- (IBAction)cancelTapped:(id)sender;
- (IBAction)saveTapped:(id)sender;
@end

@implementation DSOReportbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.client = [DSOAPIClient sharedClient];
    self.quantityLabel.text = [NSString stringWithFormat:@"Number of %@ %@:", self.campaign.reportbackNoun, self.campaign.reportbackVerb];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancelTapped:(id)sender {
    [self displayCampaignDetailViewController];
}

- (IBAction)saveTapped:(id)sender {
    NSDictionary *values = @{@"quantity":self.quantityTextField.text,
                             @"file_url":self.imageURLTextField.text,
                             @"why_participated":self.whyParticipatedTextField.text};

    [self.client postReportbackForNid:self.campaign.nid
                        andValues:values
             andCompletionHandler:^(NSDictionary *response){
                 NSLog(@"@", response);
                 [self displayCampaignDetailViewController];
             }
                  andErrorHandler:^(NSError *error){
                      NSLog(@"%@", error.localizedDescription);
                  }
     ];
}

- (void) displayCampaignDetailViewController
{
    UINavigationController *navVC = [self.storyboard instantiateViewControllerWithIdentifier:@"campaignDetailNavigationController"];
    DSOCampaignDetailViewController *destVC = (DSOCampaignDetailViewController *)navVC.topViewController;
    [destVC setCampaign:self.campaign];
    [self presentViewController:navVC animated:YES completion:nil];
}
@end