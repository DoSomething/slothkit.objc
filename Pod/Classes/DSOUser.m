//
//  DSOUser.m
//  Pods
//
//  Created by Aaron Schachter on 3/5/15.
//
//

#import "DSOUser.h"

@interface DSOUser()
@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, strong) NSString *email;
@end

@implementation DSOUser

- (void)syncWithDictionary:(NSDictionary *)values {
    self.uid = (NSInteger)values[@"uid"];
    self.email = values[@"email"];
}

@end
