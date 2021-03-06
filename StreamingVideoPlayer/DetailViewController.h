//
//  DetailViewController.h
//  StreamingVideoPlayer
//
//  Created by Yu Ma on 7/22/16.
//  Copyright © 2016 Yu Ma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "videoInfoDataModel.h"

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic)videoInfoDataModel *videoModeInfo;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

