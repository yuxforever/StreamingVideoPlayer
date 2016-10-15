//
//  videoInfoDataModel.m
//  StreamingVideoPlayer
//
//  Created by Yu Ma on 7/26/16.
//  Copyright © 2016 Yu Ma. All rights reserved.
//

#import "videoInfoDataModel.h"

@implementation videoInfoDataModel

+ (NSString *)dynamoDBTableName {
    return @"test-mobilehub-1632726983-videoInfo";
}

+ (NSString *)hashKeyAttribute {
    return @"userId";
}

@end

