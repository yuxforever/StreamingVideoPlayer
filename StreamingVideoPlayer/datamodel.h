//
//  datamodel.h
//  StreamingVideoPlayer
//
//  Created by Yu Ma on 7/26/16.
//  Copyright © 2016 Yu Ma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSDynamoDB/AWSDynamoDB.h>

@interface datamodel : AWSDynamoDBObjectModel <AWSDynamoDBModeling>

@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) NSString *colorName;
@property (nonatomic, strong) NSNumber *Price;
@property (nonatomic, strong) NSString *userId;

@end