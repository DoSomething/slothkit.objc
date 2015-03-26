//
//  DSOSession.m
//  Pods
//
//  Created by Ryan Grimm on 3/24/15.
//
//

#import "DSOSession.h"
#import "AFNetworkActivityLogger.h"
#import <SSKeychain/SSKeychain.h>

@interface DSOSession ()
@property (nonatomic, strong) NSString *serviceName;
@end

#ifdef DEBUG
#define DSOPROTOCOL @"http"
#define DSOSERVER @"staging.beta.dosomething.org"
#else
#define DSOPROTOCOL @"https"
#define DSOSERVER @"www.dosomething.org"
#endif

#define DSOSERVICETOKENSNAME [NSString stringWithFormat:@"%@-tokens", DSOSERVER]

DSOSession *_currentSession;

@interface DSOSession ()
@property (nonatomic, strong, readwrite) DSOUser *user;
@end

@implementation DSOSession

+ (BOOL)hasCachedSession {
    NSString *token = [SSKeychain passwordForService:DSOSERVICETOKENSNAME account:@"X-CSRF-Token"];
    NSString *cookie = [SSKeychain passwordForService:DSOSERVICETOKENSNAME account:@"Cookie"];

    return token.length > 0 && cookie.length > 0;
}

+ (NSString *)lastLoginUsername {
    NSArray *accounts = [SSKeychain accountsForService:DSOSERVER];
    NSDictionary *firstAccount = accounts.firstObject;

    return firstAccount[@"acct"];
}

+ (void)startWithUsername:(NSString *)username password:(NSString *)password success:(DSOSessionLoginBlock)successBlock failure:(DSOSessionFailureBlock)failureBlock
{
    _currentSession = nil;

    DSOSession *session = [[DSOSession alloc] init];

    NSDictionary *params = @{@"username":username,
                             @"password":password};

    [session POST:@"auth/login.json" parameters:params success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        [SSKeychain setPassword:password forService:DSOSERVER account:username];
        session.user = [[DSOUser alloc] init];
        [session.user syncWithDictionary:response[@"user"]];
        [session saveTokens:response];

        _currentSession = session;
        if (successBlock) {
            successBlock(session);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}

+ (void)startWithCachedSession:(DSOSessionLoginBlock)successBlock failure:(DSOSessionFailureBlock)failure
{
    if ([DSOSession hasCachedSession] == NO) {
        if (failure) {
            failure(nil);
        }
        return;
    }
    
    DSOSession *session = [[DSOSession alloc] init];

    NSString *token = [SSKeychain passwordForService:DSOSERVICETOKENSNAME account:@"X-CSRF-Token"];
    NSString *cookie = [SSKeychain passwordForService:DSOSERVICETOKENSNAME account:@"Cookie"];

    [session.requestSerializer setValue:token forHTTPHeaderField:@"X-CSRF-Token"];
    [session.requestSerializer setValue:cookie forHTTPHeaderField:@"Cookie"];

    [session POST:@"system/connect.json" parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        NSDictionary *userRoles = response[@"user"][@"roles"];

        // 1 is anon user.
        if ([userRoles objectForKey:@"1"]) {
            if(failure) {
                failure(nil);
                return;
            }
        }

        session.user = [[DSOUser alloc] init];
        [session.user syncWithDictionary:response[@"user"]];

        _currentSession = session;
        if (successBlock) {
            successBlock(session);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (DSOSession *)currentSession {
    return _currentSession;
}

- (instancetype)init
{
    NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/api/v1/", DSOPROTOCOL, DSOSERVER]];
    self = [super initWithBaseURL:baseURL];

    if (self != nil) {
        [[AFNetworkActivityLogger sharedLogger] startLogging];
        [[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelDebug];

        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }

    return self;
}

- (void)saveTokens:(NSDictionary *)response
{
    [SSKeychain setPassword:response[@"token"] forService:DSOSERVICETOKENSNAME account:@"X-CSRF-Token"];

    NSString *cookie = [NSString stringWithFormat:@"%@=%@", response[@"session_name"], response[@"sessid"]];
    [SSKeychain setPassword:cookie forService:DSOSERVICETOKENSNAME account:@"Cookie"];

    [self.requestSerializer setValue:response[@"token"] forHTTPHeaderField:@"X-CSRF-Token"];
    [self.requestSerializer setValue:cookie forHTTPHeaderField:@"Cookie"];
}


- (void)logout:(DSOSessionLogoutBlock)successBlock failure:(DSOSessionFailureBlock)failureBlock
{
    [self POST:@"auth/logout.json" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [SSKeychain deletePasswordForService:DSOSERVICETOKENSNAME account:@"X-CSRF-Token"];
        [SSKeychain deletePasswordForService:DSOSERVICETOKENSNAME account:@"Cookie"];

        if (successBlock) {
            successBlock();
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(failureBlock) {
            failureBlock(error);
        }
    }];
}


#pragma mark Unused

- (void)singleInboxReportbackForTid:(NSInteger)tid completionHandler:(void(^)(NSMutableArray *))completionHandler errorHandler:(void(^)(NSError *))errorHandler
{
    NSString *url = [NSString stringWithFormat:@"terms/%li/inbox.json?count=1", tid];
    [self GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@",error.localizedDescription);
    }];
}


- (void)termsWithCompletionHandler:(void(^)(NSMutableArray *))completionHandler
{
    NSString *url = @"terms.json";
    [self GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@",error.localizedDescription);
    }];
}


- (void)reportbackItemReviewWithValues:(NSDictionary *)values completionHandler:(void(^)(NSArray *))completionHandler
{
    NSString *postUrl = [NSString stringWithFormat:@"reportback_files/%@/review.json", values[@"fid"]];
    [self POST:postUrl parameters:values success:^(NSURLSessionDataTask *task, id responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@",error.localizedDescription);
    }];
}

@end
