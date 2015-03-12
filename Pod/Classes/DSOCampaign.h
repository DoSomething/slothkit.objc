//
//  DSOCampaign.h
//  Pods
//
//  Created by Aaron Schachter on 3/4/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DSOCampaign : NSObject

@property (assign, nonatomic) NSInteger nid;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *callToAction;
@property (strong, nonatomic) NSString *coverImageUrl;
@property (strong, nonatomic) UIImage *coverImage;
@property (strong, nonatomic) NSString *reportbackNoun;
@property (strong, nonatomic) NSString *reportbackVerb;

-(void)syncWithDictionary:(NSDictionary *)values;

@end
