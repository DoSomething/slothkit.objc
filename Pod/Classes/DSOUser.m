//
//  DSOUser.m
//  Pods
//
//  Created by Aaron Schachter on 3/5/15.
//
//

#import "DSOUser.h"

@interface DSOUser()
@property (nonatomic, readwrite) NSInteger userID;
@property (nonatomic, strong, readwrite) NSString *email;
@property (nonatomic, readwrite) BOOL isAdmin;
@end

@implementation DSOUser

- (void)syncWithDictionary:(NSDictionary *)values {
    self.userID = (NSInteger)values[@"uid"];
    self.email = values[@"mail"];

    self.isAdmin = NO;
    for(NSString *key in values[@"roles"]) {
        if([key isEqualToString:@"3"]) {
            self.isAdmin = YES;
        }
    }
}

@end
