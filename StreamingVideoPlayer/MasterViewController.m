//
//  MasterViewController.m
//  StreamingVideoPlayer
//
//  Created by Yu Ma on 7/22/16.
//  Copyright © 2016 Yu Ma. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "videoInfoDataModel.h"
#import "datamodel.h"


@interface MasterViewController ()
@property (nonatomic, strong)videoInfoDataModel *videoInfoModel;
@property (nonatomic, strong)NSMutableArray *videoInfoGroup;

@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    [self loadVideoInfo];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadVideoInfo{
    
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                    identityPoolId:@"us-east-1:f077300c-e12e-4e7b-8f9d-e6e5c96ce5c8"];
    
    //us-east-1:f077300c-e12e-4e7b-8f9d-e6e5c96ce5c8
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1
                                                                         credentialsProvider:credentialsProvider];
    
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    // Retrieve your Amazon Cognito ID.
    
    
    [[credentialsProvider getIdentityId] continueWithBlock:^id(AWSTask *task){
        
        if (task.error == nil)
        {
            NSString* cognitoId = credentialsProvider.identityId;
            NSLog(@"cognitoId111111111: %@", cognitoId);
        }
        else
        {
            NSLog(@"Error : %@", task.error);
        }
        
        return nil;
    }];

    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    self.videoInfoGroup = [NSMutableArray new];
    
    [[dynamoDBObjectMapper scan:[videoInfoDataModel class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.exception) {
             NSLog(@"The request failed. Exception: [%@]", task.exception);
         }
         if (task.result) {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             for (videoInfoDataModel *videogroups in paginatedOutput.items) {
                 //Do something with book.
                
                 [self.videoInfoGroup addObject:videogroups];
                }
            }

         NSLog(@"BEGIN reloadData");
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.tableView reloadData];
         });
         NSLog(@"END reloadData");
         return nil;
     }];
}

-(void)saveInfo{
    //    videoInfoDataModel *videoModel = [videoInfoDataModel new];
    //
    //          videoModel.userId = @"9129394004";
    //          videoModel.videoName = @"CH01_BD1_10-6-11";
    //          videoModel.videoUrl = @"https://s3.amazonaws.com/michaelmavideostreaming/CH01_BD1_10-6-11.mp4";
    //
    //        AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    //
    //        [[dynamoDBObjectMapper save:videoModel]
    //         continueWithBlock:^id(AWSTask *task) {
    //             if (task.error) {
    //                 NSLog(@"The request failed. Error: [%@]", task.error);
    //             }
    //             if (task.exception) {
    //                 NSLog(@"The request failed. Exception: [%@]", task.exception);
    //             }
    //             if (task.result) {
    //                 //Do something with the result.
    //             }
    //             return nil;
    //         }];
    
    //       datamodel *myBook = [datamodel new];
    //        myBook.userId = @"9129394293";
    //        myBook.className = @"The Scarlet Letter";
    //        myBook.colorName = @"Nathaniel Hawthorne";
    //        //myBook.Price = [NSNumber numberWithInt:899];
    //
    //
    //    [[dynamoDBObjectMapper load:[myBook class] hashKey:@"9129394291" rangeKey:nil]
    //     continueWithBlock:^id(AWSTask *task) {
    //         if (task.error) {
    //             NSLog(@"The request failed. Error: [%@]", task.error);
    //         }
    //
    //         if (task.exception) {
    //             NSLog(@"The request failed. Exception: [%@]", task.exception);
    //         }
    //
    //         if (task.result) {
    //             dataModel *book = task.result;
    //             NSLog(@"jjjjjjjjj  %@", book);
    //             //Do something with the result.
    //         }
    //         return nil;
    //     }];
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        videoInfoDataModel *videoModel = self.videoInfoGroup[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:videoModel];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.videoInfoGroup.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {


}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    videoInfoDataModel *object = self.videoInfoGroup[indexPath.row];
    cell.textLabel.text = object.videoName;
}

#pragma mark - Fetched results controller



@end
