//
//  DSOReportbackViewController.m
//  SlothieBoy
//
//  Created by Aaron Schachter on 3/6/15.
//  Copyright (c) 2015 Aaron Schachter. All rights reserved.
//

#import "DSOReportbackViewController.h"
#import <SlothKit/DSOClient.h>
#import "DSOCampaignDetailViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>


@interface DSOReportbackViewController ()

@property (strong, nonatomic) DSOClient *client;

@property (strong, nonatomic) NSString *selectedFilestring;
@property (strong, nonatomic) NSString *selectedFilename;
@property (strong, nonatomic) UIImagePickerController *picker;

@property (weak, nonatomic) IBOutlet UIImageView *previewImage;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UITextField *quantityTextField;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet UITextView *imageURLTextField;
@property (weak, nonatomic) IBOutlet UITextView *whyParticipatedTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

- (IBAction)takePhotoTapped:(id)sender;
- (IBAction)selectPhotoTapped:(id)sender;
- (IBAction)cancelTapped:(id)sender;
- (IBAction)saveTapped:(id)sender;
@end

@implementation DSOReportbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.client = [DSOClient sharedClient];
    self.quantityLabel.text = [NSString stringWithFormat:@"Number of %@ %@:", self.campaign.reportbackNoun, self.campaign.reportbackVerb];

    self.picker = [[UIImagePickerController alloc] init];
    self.picker.delegate = self;
    self.picker.allowsEditing = YES;

    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {

        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];

        [myAlertView show];
        self.takePhotoButton.hidden = YES;

    }
}

- (IBAction)cancelTapped:(id)sender {
    [self displayCampaignDetailViewController];
}

- (IBAction)saveTapped:(id)sender {
    self.saveButton.enabled = NO;
    NSDictionary *values = @{@"quantity":self.quantityTextField.text,
                             @"file":self.selectedFilestring,
                             @"filename":self.selectedFilename,
                             @"why_participated":self.whyParticipatedTextField.text};

    [self.client postReportbackForNid:self.campaign.nid
                        values:values
             completionHandler:^(NSDictionary *response){
                 [self displayCampaignDetailViewController];
             }
                  errorHandler:^(NSError *error){
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

- (IBAction)takePhotoTapped:(id)sender {
    self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:self.picker animated:YES completion:NULL];
}

- (IBAction)selectPhotoTapped:(id)sender {
    self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.picker animated:YES completion:NULL];
}
#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.previewImage.image = chosenImage;
    self.selectedFilestring = [UIImagePNGRepresentation(chosenImage) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];

    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        self.selectedFilename = @"temp.JPG";
        [picker dismissViewControllerAnimated:YES completion:NULL];
        return;
    }

    // Stolen from http://www.raywenderlich.com/forums/viewtopic.php?f=2&p=34901.
    // to get the original filename of selected file. Used for preserving file extensions.

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
