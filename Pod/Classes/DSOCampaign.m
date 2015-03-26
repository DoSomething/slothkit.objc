//
//  DSOCampaign.m
//  Pods
//
//  Created by Aaron Schachter on 3/4/15.
//
//

#import "DSOCampaign.h"
#import "DSOCampaignActivity.h"
#import "DSOSession.h"

@implementation DSOCampaign


+ (void)staffPickCampaigns:(DSOCampaignListBlock)completionBlock {
    if (completionBlock == nil) {
        return;
    }

    NSString *url = @"campaigns.json?parameters[is_staff_pick]=1";
    [[DSOSession currentSession] GET:url parameters:nil success:^(NSURLSessionDataTask *task, NSArray *response) {
        NSMutableArray *campaigns = [NSMutableArray arrayWithCapacity:response.count];
        for(NSDictionary *campaignData in response) {
            DSOCampaign *campaign = [[DSOCampaign alloc] init];
            [campaign syncWithDictionary:campaignData];
            [campaigns addObject:campaign];
        }

        completionBlock([campaigns copy], nil);

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionBlock(nil, error);
    }];
}

+ (void)campaignWithID:(NSInteger)campaignID completion:(DSOCampaignBlock)completionBlock {
    if (completionBlock == nil) {
        return;
    }

    NSString *url = [NSString stringWithFormat:@"content/%ld.json", (long)campaignID];
    [[DSOSession currentSession] GET:url parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        DSOCampaign *campaign = [[DSOCampaign alloc] init];
        [campaign syncWithDictionary:response];

        completionBlock(campaign, nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionBlock(nil, error);
    }];
}


- (void)myActivity:(DSOCampaignActivityBlock)completionBlock {
    if(completionBlock == nil) {
        return;
    }

    NSString *url = [NSString stringWithFormat:@"users/current/activity.json?nid=%ld", (long)self.campaignID];
    [[DSOSession currentSession] GET:url parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        DSOCampaignActivity *activity = [[DSOCampaignActivity alloc] initWithDictionary:response];
        completionBlock(activity, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionBlock(nil, error);
    }];
}

- (void)signupFromSource:(NSString *)source completion:(DSOCampaignSignupBlock)completionBlock {
    NSString *url = [NSString stringWithFormat:@"campaigns/%ld/signup.json", (long)self.campaignID];
    NSDictionary *params = @{@"source":source};
    [[DSOSession currentSession] POST:url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        if(completionBlock) {
            completionBlock(nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(completionBlock) {
            completionBlock(error);
        }
    }];
}

- (void)reportbackValues:(NSDictionary *)values completionHandler:(DSOCampaignReportBackBlock)completionHandler {
    NSString *url = [NSString stringWithFormat:@"campaigns/%ld/reportback.json", (long)self.campaignID];
    [[DSOSession currentSession] POST:url parameters:values success:^(NSURLSessionDataTask *task, id responseObject) {
        if(completionHandler) {
            completionHandler(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(completionHandler) {
            completionHandler(nil, error);
        }
    }];
}

- (void)syncWithDictionary:(NSDictionary *)values {
    self.campaignID = [values[@"nid"] integerValue];
    self.title = values[@"title"];
    self.callToAction = values[@"call_to_action"];

    NSDictionary *images = values[@"image_cover"];
    self.coverImageURL = [NSURL URLWithString:images[@"src"]];

    self.reportbackNoun = values[@"reportback_noun"];
    self.reportbackVerb = values[@"reportback_verb"];
}

- (UIImage *)coverImage {
    if(_coverImage) {
        return _coverImage;
    }

    NSData* imageData = [[NSData alloc]initWithContentsOfURL:self.coverImageURL];
    _coverImage = [[UIImage alloc] initWithData:imageData];

    return _coverImage;
}

@end
