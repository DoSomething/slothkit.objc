//
//  DSOAPIClient.m
//  Pods
//
//  Created by Aaron Schachter on 3/4/15.
//
//

#import "DSOClient.h"
#import <SSKeychain/SSKeychain.h>

@interface DSOClient()
@property (retain, nonatomic) NSString *serviceName;
@property (retain, nonatomic) NSString *serviceTokensName;
@end

@implementation DSOClient

@synthesize serviceName;
@synthesize serviceTokensName;
@synthesize user;

+ (DSOClient *)sharedClient
{
    NSString *server = @"www.dosomething.org";
    NSString *protocol = @"https";
#ifdef DEBUG
    server = @"staging.beta.dosomething.org";
    protocol =@"http";
#endif
    NSString *apiEndpoint = [NSString stringWithFormat:@"%@://%@/api/v1/", protocol, server];
    static DSOClient *_sharedClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient  = [[self alloc] initWithBaseURL:[NSURL URLWithString:apiEndpoint]];
        _sharedClient.serviceName = server;
        _sharedClient.serviceTokensName = [NSString stringWithFormat:@"%@-tokens", server];
    });
    return _sharedClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (self) {
        self.user = [[DSOUser alloc] init];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    return self;
}


- (NSString *) getService
{
    return self.serviceName;
}

-(void) addAuthHTTPHeaders
{
    NSDictionary *tokens = [self getSavedTokens];
    //@todo Handle when tokens is empty.
    //@see https://github.com/DoSomething/ios-RBReviewer/issues/36
    for (NSString* key in tokens) {
        NSString *value = [tokens objectForKey:key];
        [self.requestSerializer setValue:value forHTTPHeaderField:key];
    }
}

- (void)getCampaignWithNid:(NSInteger)nid completionHandler:(void(^)(NSDictionary *))completionHandler
{
    NSString *url = [NSString stringWithFormat:@"content/%ld.json", (long)nid];
    [self GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@",error.localizedDescription);
    }];
}

- (void)getCampaignsWithCompletionHandler:(void(^)(NSMutableArray *))completionHandler
{
    NSString *url = @"campaigns.json?parameters[is_staff_pick]=1";
    [self GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@",error.localizedDescription);
    }];
}

- (void)getConnectionStatusWithCompletionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSDictionary *))errorHandler
{
    NSMutableDictionary *tokens = [self getSavedTokens];
    if ([tokens count] > 0) {
        [self addAuthHTTPHeaders];
    }
    [self POST:@"system/connect.json" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@",error.localizedDescription);
        errorHandler((NSDictionary *)error);
    }];
}

- (void)getCurrentUserActivityWithNid:(NSInteger)nid completionHandler:(void(^)(NSDictionary *))completionHandler
{
    NSString *url = [NSString stringWithFormat:@"users/current/activity.json?nid=%ld", (long)nid];
    NSLog(@"url = %@", url);
    [self GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@",error.localizedDescription);
    }];
}

- (void)getSingleInboxReportbackForTid:(NSInteger)tid completionHandler:(void(^)(NSMutableArray *))completionHandler errorHandler:(void(^)(NSError *))errorHandler
{

    NSString *url = [NSString stringWithFormat:@"terms/%li/inbox.json?count=1", tid];
    [self GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@",error.localizedDescription);
    }];
}


- (void)getTermsWithCompletionHandler:(void(^)(NSMutableArray *))completionHandler
{
    NSString *url = @"terms.json";
    [self GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@",error.localizedDescription);
    }];
}

-(void)loginWithUsername:(NSString *)username password:(NSString *)password completionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSError *))errorHandler
{
    NSDictionary *params = @{@"username":username,
                             @"password":password};
    
    [self POST:@"auth/login.json" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        [SSKeychain setPassword:password forService:self.serviceName account:username];
        [self.user syncWithDictionary:responseObject[@"user"]];
        [self setSavedTokens:responseObject];
        [self addAuthHTTPHeaders];
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        errorHandler(error);
    }];
}

- (void)logoutWithCompletionHandler:(void(^)(NSDictionary *))completionHandler
{
    [self POST:@"auth/logout.json" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [self deleteSavedTokens];
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@",error.localizedDescription);
    }];
}

- (void)postReportbackForNid:(NSInteger)nid values:(NSDictionary *)values completionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSError *))errorHandler
{
    NSString *url = [NSString stringWithFormat:@"campaigns/%ld/reportback.json", (long)nid];
    [self POST:url parameters:values success:^(NSURLSessionDataTask *task, id responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@",error.localizedDescription);
    }];
}

- (void)postReportbackItemReviewWithValues:(NSDictionary *)values completionHandler:(void(^)(NSArray *))completionHandler
{

    NSString *postUrl = [NSString stringWithFormat:@"reportback_files/%@/review.json", values[@"fid"]];
    [self POST:postUrl parameters:values success:^(NSURLSessionDataTask *task, id responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@",error.localizedDescription);
    }];
}


- (void)postSignupForNid:(NSInteger)nid source:(NSString *)source completionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSError *))errorHandler
{
    NSString *url = [NSString stringWithFormat:@"campaigns/%ld/signup.json", (long)nid];
    NSDictionary *params = @{@"source":source};
    [self POST:url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@",error.localizedDescription);
    }];
}

#pragma mark - Tokens

- (void) deleteSavedTokens
{
    NSMutableDictionary *tokens = [self getSavedTokens];
    for(id key in tokens) {
        [SSKeychain deletePasswordForService:self.serviceTokensName account:key];
    }
}

- (NSDictionary *) getSavedLogin
{
    NSDictionary *authValues = [[NSDictionary alloc] init];
    NSArray *accounts = [SSKeychain accountsForService:self.serviceName];
    if ([accounts count] > 0) {
        NSDictionary *account = accounts[0];
        authValues = @{@"username":account[@"acct"],
                       @"password":[SSKeychain passwordForService:self.serviceName account:account[@"acct"]]};
    }
    return authValues;
}


- (NSMutableDictionary *) getSavedTokens
{
    NSMutableDictionary *savedTokens = [[NSMutableDictionary alloc] init];
    NSArray *tokens = [SSKeychain accountsForService:self.serviceTokensName];
    if ([tokens count] > 0) {
        for (NSDictionary *token in tokens) {
            NSString *key = token[@"acct"];
            savedTokens[key] = [SSKeychain passwordForService:self.serviceTokensName account:key];
        }
    }
    return savedTokens;
}

- (void) setSavedTokens:(NSDictionary *)response
{
    [SSKeychain setPassword:response[@"token"] forService:self.serviceTokensName account:@"X-CSRF-Token"];
    
    NSString *cookie = [NSString stringWithFormat:@"%@=%@", response[@"session_name"], response[@"sessid"]];
    [SSKeychain setPassword:cookie forService:self.serviceTokensName account:@"Cookie"];
    
}

@end
