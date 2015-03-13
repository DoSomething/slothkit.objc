//
//  DSOAPIClient.h
//  Pods
//
//  Created by Aaron Schachter on 3/4/15.
//
//

#import "AFHTTPSessionManager.h"
#import "DSOUser.h"

@interface DSOClient : AFHTTPSessionManager

@property (strong, nonatomic) DSOUser *user;

+ (DSOClient *)sharedClient;

- (instancetype)initWithBaseURL:(NSURL *)url;

- (NSString *) getService;

- (NSDictionary *) getSavedLogin;

- (NSMutableDictionary *) getSavedTokens;

- (void)getCampaignWithNid:(NSInteger)nid completionHandler:(void(^)(NSDictionary *))completionHandler;

- (void)getCampaignsWithCompletionHandler:(void(^)(NSMutableArray *))completionHandler;

- (void)getConnectionStatusWithCompletionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSDictionary *))errorHandler;

- (void)getCurrentUserActivityWithNid:(NSInteger)nid completionHandler:(void(^)(NSDictionary *))completionHandler;

- (void)getSingleInboxReportbackForTid:(NSInteger)tid completionHandler:(void(^)(NSMutableArray *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

- (void)getTermsWithCompletionHandler:(void(^)(NSMutableArray *))completionHandler;

- (void)loginWithUsername:(NSString *)username password:(NSString *)password completionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

- (void)logoutWithCompletionHandler:(void(^)(NSDictionary *))completionHandler;

- (void)postReportbackForNid:(NSInteger)nid values:(NSDictionary *)values completionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

- (void)postReportbackItemReviewWithValues:(NSDictionary *)values completionHandler:(void(^)(NSArray *))completionHandler;


- (void)postSignupForNid:(NSInteger)nid source:(NSString *)source completionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

@end
