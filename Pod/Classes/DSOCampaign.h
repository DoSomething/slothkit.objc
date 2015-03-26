//
//  DSOCampaign.h
//  Pods
//
//  Created by Aaron Schachter on 3/4/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class DSOCampaign;
@class DSOCampaignActivity;

typedef void (^DSOCampaignListBlock)(NSArray *campaigns, NSError *error);
typedef void (^DSOCampaignBlock)(DSOCampaign *campaign, NSError *error);
typedef void (^DSOCampaignActivityBlock)(DSOCampaignActivity *activity, NSError *error);
typedef void (^DSOCampaignSignupBlock)(NSError *error);
typedef void (^DSOCampaignReportBackBlock)(NSDictionary *response, NSError *error);

@interface DSOCampaign : NSObject

+ (void)staffPickCampaigns:(DSOCampaignListBlock)completionBlock;
+ (void)campaignWithID:(NSInteger)campaignID completion:(DSOCampaignBlock)completionBlock;

- (void)myActivity:(DSOCampaignActivityBlock)completionBlock;
- (void)signupFromSource:(NSString *)source completion:(DSOCampaignSignupBlock)completionBlock;
- (void)reportbackValues:(NSDictionary *)values completionHandler:(DSOCampaignReportBackBlock)completionHandler;

@property (nonatomic) NSInteger campaignID;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *callToAction;
@property (strong, nonatomic) NSURL *coverImageURL;
@property (strong, nonatomic) UIImage *coverImage;
@property (strong, nonatomic) NSString *reportbackNoun;
@property (strong, nonatomic) NSString *reportbackVerb;

- (void)syncWithDictionary:(NSDictionary *)values;

@end
