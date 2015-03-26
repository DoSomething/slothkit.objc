//
//  DSOViewController.m
//  SlothieBoy
//
//  Created by Aaron Schachter on 03/04/2015.
//  Copyright (c) 2014 Aaron Schachter. All rights reserved.
//

#import "DSOCampaignListViewController.h"
#import "DSOCampaignDetailViewController.h"
#import "DSOLoginViewController.h"
#import <SlothKit/SlothKit.h>

@interface DSOCampaignListViewController ()

@property (strong, nonatomic) NSArray *campaigns;
- (IBAction)logoutTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DSOCampaignListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.title = @"Campaigns";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if([DSOSession currentSession])
    {
        [self getCampaigns];
    }
    else if([DSOSession hasCachedSession])
    {
        [DSOSession startWithCachedSession:^(DSOSession *session) {
            [self getCampaigns];
        } failure:^(NSError *error) {
            if(error == nil) {
                [self displayLoginViewController];
            }
        }];
    }
}

- (void)displayLoginViewController {
    DSOLoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"loginNavigationController"];
    [self presentViewController:loginVC animated:YES completion:nil];
}

- (void)getCampaigns {
    [DSOCampaign staffPickCampaigns:^(NSArray *campaigns, NSError *error) {
        self.campaigns = campaigns;
        [self.tableView reloadData];
    }];
}
    
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.campaigns count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableCell" forIndexPath:indexPath];
    DSOCampaign *campaign = (DSOCampaign *)self.campaigns[indexPath.row];
    cell.textLabel.text = campaign.title;
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (sender == self.logoutButton)
    {
        return;
    }

    UINavigationController *initialVC = (UINavigationController *) [segue destinationViewController];
    DSOCampaignDetailViewController *destVC = (DSOCampaignDetailViewController *)initialVC.topViewController;

    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];
    destVC.campaign = (DSOCampaign *)self.campaigns[indexPath.row];
}

- (IBAction)logoutTapped:(id)sender {
    [[DSOSession currentSession] logout:^{
        [self displayLoginViewController];
    } failure:^(NSError *error) {

    }];
}
@end
