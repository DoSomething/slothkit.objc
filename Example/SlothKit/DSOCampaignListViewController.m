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
#import <SlothKit/DSOAPIClient.h>
#import <SlothKit/DSOCampaign.h>

@interface DSOCampaignListViewController ()

@property (strong, nonatomic) DSOAPIClient *client;
@property (strong, nonatomic) NSMutableArray *campaigns;
- (IBAction)logoutTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DSOCampaignListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.client = [DSOAPIClient sharedClient];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.campaigns = [[NSMutableArray alloc] init];
    self.title = @"Campaigns";
    [self getCampaigns];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.client getConnectionStatusWithCompletionHandler:^(NSDictionary *response){
        NSDictionary *user = response[@"user"];
        NSDictionary *userRoles = user[@"roles"];
        // 1 is anon user.
        if ([userRoles objectForKey:@"1"]) {
            [self displayLoginViewController];
        }
        [self.client.user syncWithDictionary:response[@"user"]];
        return;
    } andErrorHandler:^(NSDictionary *response){
        NSLog(@"Error %@", response);
        [self displayLoginViewController];
    }];
}

- (void) displayLoginViewController {
    DSOLoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"loginNavigationController"];
    [self presentViewController:loginVC animated:YES completion:nil];
}

- (void) getCampaigns {
    
    [self.client getCampaignsWithCompletionHandler:^(NSMutableArray *response){
        for (NSDictionary *result in response) {
            DSOCampaign *campaign = [[DSOCampaign alloc] init];
            campaign.nid = (NSInteger *)(long)result[@"nid"];
            campaign.title = (NSString *)result[@"title"];
            [self.campaigns addObject:campaign];
        }
        [self.tableView reloadData];
    }];
}
    
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.campaigns count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableCell" forIndexPath:indexPath];
    DSOCampaign *campaign = (DSOCampaign *)self.campaigns[indexPath.row];
    cell.textLabel.text = campaign.title;
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (sender == self.logoutButton) {
        return;
    }
    UINavigationController *initialVC = (UINavigationController *) [segue destinationViewController];
    DSOCampaignDetailViewController *destVC = (DSOCampaignDetailViewController *)initialVC.topViewController;
    UITableViewCell *cell = (UITableViewCell *)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    DSOCampaign *campaign = (DSOCampaign *)self.campaigns[indexPath.row];
    [destVC setCampaign:campaign];
}

- (IBAction)logoutTapped:(id)sender {
    [self.client logoutWithCompletionHandler:^(NSDictionary *response){
        [self displayLoginViewController];
    }];
}
@end
