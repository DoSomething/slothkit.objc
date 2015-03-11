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
#import <AssetsLibrary/AssetsLibrary.h>


@interface DSOReportbackViewController ()

@property (strong, nonatomic) DSOAPIClient *client;

@property (strong, nonatomic) NSString *selectedFilestring;
@property (strong, nonatomic) NSString *selectedFilename;

@property (weak, nonatomic) IBOutlet UIImageView *previewImage;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UITextField *quantityTextField;
@property (weak, nonatomic) IBOutlet UITextView *imageURLTextField;
- (IBAction)selectPhotoTapped:(id)sender;
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
                             @"file":self.selectedFilestring,
                             @"filename":self.selectedFilename,
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
- (IBAction)selectPhotoTapped:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}
#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.previewImage.image = chosenImage;
    self.selectedFilestring = [UIImagePNGRepresentation(chosenImage) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];

    // Stolen from http://www.raywenderlich.com/forums/viewtopic.php?f=2&p=34901.

    // get the ref url
    NSURL *refURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    // define the block to call when we get the asset based on the url (below)
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *imageAsset)
    {
        ALAssetRepresentation *imageRep = [imageAsset defaultRepresentation];
        self.selectedFilename = [imageRep filename];
    };
    // get the asset library and fetch the asset based on the ref url (pass in block above)
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:refURL resultBlock:resultblock failureBlock:nil];
    [picker dismissViewControllerAnimated:YES completion:NULL];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    [picker dismissViewControllerAnimated:YES completion:NULL];

}
@end
