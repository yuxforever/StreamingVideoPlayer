//
//  videoInfoDataModel.h
//  StreamingVideoPlayer
//
//  Created by Yu Ma on 7/26/16.
//  Copyright © 2016 Yu Ma. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AWSDynamoDB/AWSDynamoDB.h>

@interface videoInfoDataModel : AWSDynamoDBObjectModel <AWSDynamoDBModeling>

@property (nonatomic, strong) NSString *videoName;
@property (nonatomic, strong) NSString *videoUrl;
@property (nonatomic, strong) NSString *videoComments;
@property (nonatomic, strong) NSString *userId;


@end
