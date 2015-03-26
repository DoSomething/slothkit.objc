//
//  DSOSession.h
//  Pods
//
//  Created by Ryan Grimm on 3/24/15.
//
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "DSOUser.h"

@class DSOSession;

typedef void (^DSOSessionLoginBlock) (DSOSession *session);
typedef void (^DSOSessionFailureBlock) (NSError *error);
typedef void (^DSOSessionLogoutBlock) ();

@interface DSOSession : AFHTTPSessionManager

+ (BOOL)hasCachedSession;
+ (NSString *)lastLoginUsername;

/*
 * Starts a session by logging the user in using a username and password.
 * If there is an error, the failure block is called. If login succeeds and
 * the session is created, the success block will be called with the new session.
 */
+ (void)startWithUsername:(NSString *)username password:(NSString *)password success:(DSOSessionLoginBlock)successBlock failure:(DSOSessionFailureBlock)failureBlock;

/*
 * Starts a new session using the cached token. If the cached token is still valid,
 * the session will be passed into the success block.
 * If the failure block is returned without an error, a new login is required.
 */
+ (void)startWithCachedSession:(DSOSessionLoginBlock)successBlock failure:(DSOSessionFailureBlock)failure;

+ (DSOSession *)currentSession;

@property (nonatomic, strong, readonly) DSOUser *user;

- (void)logout:(DSOSessionLogoutBlock)successBlock failure:(DSOSessionFailureBlock)failureBlock;

@end

/*
 - (void)postReportbackForNid:(NSInteger)nid values:(NSDictionary *)values completionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;
*/