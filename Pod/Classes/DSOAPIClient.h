//
//  DSOAPIClient.h
//  Pods
//
//  Created by Aaron Schachter on 3/4/15.
//
//

#import "AFHTTPSessionManager.h"
#import "DSOUser.h"

@interface DSOAPIClient : AFHTTPSessionManager

@property (strong, nonatomic) DSOUser *user;

+ (DSOAPIClient *)sharedClient;

- (instancetype)initWithBaseURL:(NSURL *)url;

- (NSString *) getService;

- (void)getCampaignWithNid:(NSInteger)nid andCompletionHandler:(void(^)(NSDictionary *))completionHandler;

- (void)getCampaignsWithCompletionHandler:(void(^)(NSMutableArray *))completionHandler;

- (void)getConnectionStatusWithCompletionHandler:(void(^)(NSDictionary *))completionHandler andErrorHandler:(void(^)(NSDictionary *))errorHandler;

- (void)getCurrentUserActivityWithNid:(NSInteger)nid andCompletionHandler:(void(^)(NSDictionary *))completionHandler;

- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password andCompletionHandler:(void(^)(NSDictionary *))completionHandler andErrorHandler:(void(^)(NSError *))errorHandler;

- (void)logoutWithCompletionHandler:(void(^)(NSDictionary *))completionHandler;

- (BOOL)isLoggedIn;

- (void)postReportbackForNid:(NSInteger)nid andValues:(NSDictionary *)values andCompletionHandler:(void(^)(NSDictionary *))completionHandler andErrorHandler:(void(^)(NSError *))errorHandler;

- (void)postSignupForNid:(NSInteger)nid andSource:(NSString *)source andCompletionHandler:(void(^)(NSDictionary *))completionHandler andErrorHandler:(void(^)(NSError *))errorHandler;

@end
