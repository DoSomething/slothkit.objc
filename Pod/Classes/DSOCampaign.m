//
//  DSOCampaign.m
//  Pods
//
//  Created by Aaron Schachter on 3/4/15.
//
//

#import "DSOCampaign.h"

@implementation DSOCampaign

-(void)syncWithDictionary:(NSDictionary *)values {
    self.callToAction = values[@"call_to_action"];
    NSDictionary *images = values[@"image_cover"];
    self.coverImageUrl = images[@"src"];
    NSData* imageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:self.coverImageUrl]];
    self.coverImage = [[UIImage alloc] initWithData:imageData];
    self.reportbackNoun = values[@"reportback_noun"];
    self.reportbackVerb = values[@"reportback_verb"];
}

@end
