//
//  DSOReportbackViewController.h
//  SlothieBoy
//
//  Created by Aaron Schachter on 3/6/15.
//  Copyright (c) 2015 Aaron Schachter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SlothKit/DSOCampaign.h>

@interface DSOReportbackViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) DSOCampaign *campaign;

@end
