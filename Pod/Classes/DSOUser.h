//
//  DSOUser.h
//  Pods
//
//  Created by Aaron Schachter on 3/5/15.
//
//

#import <Foundation/Foundation.h>

@interface DSOUser : NSObject

- (NSInteger)getUid;

- (void)syncWithDictionary:(NSDictionary *)values;

@end
