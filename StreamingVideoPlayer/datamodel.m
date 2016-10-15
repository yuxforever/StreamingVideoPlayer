//
//  datamodel.m
//  StreamingVideoPlayer
//
//  Created by Yu Ma on 7/26/16.
//  Copyright © 2016 Yu Ma. All rights reserved.
//

#import "datamodel.h"
#import <AWSDynamoDB/AWSDynamoDB.h>

@implementation datamodel

+ (NSString *)dynamoDBTableName {
    return @"test-mobilehub-1632726983-test1";}

+ (NSString *)hashKeyAttribute {
    return @"userId";
}

@end
