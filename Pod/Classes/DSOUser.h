//
//  DSOUser.h
//  Pods
//
//  Created by Aaron Schachter on 3/5/15.
//
//

#import <Foundation/Foundation.h>

@interface DSOUser : NSObject

- (void)syncWithDictionary:(NSDictionary *)values;

@property (nonatomic, readonly) NSInteger userID;
@property (nonatomic, readonly) BOOL isAdmin;

@property (nonatomic, strong, readonly) NSString *email;

@end
