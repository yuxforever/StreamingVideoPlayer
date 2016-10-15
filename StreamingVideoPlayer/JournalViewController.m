//
//  JournalViewController.m
//  StreamingVideoPlayer
//
//  Created by Yu Ma on 7/27/16.
//  Copyright © 2016 Yu Ma. All rights reserved.
//

#import "JournalViewController.h"
#import "DetailViewController.h"
#import "videoInfoDataModel.h"
#import "datamodel.h"

@interface JournalViewController ()

@property (nonatomic, strong)NSMutableArray *videoInfoGroup;

@end


@implementation JournalViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    UIBarButtonItem *myBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
//                                                                     style:UIBarButtonItemStylePlain target:self
//                                                                    action:@selector(goBack:)];
//    self.navigationItem.leftBarButtonItem = myBackButton;
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
                 NSLog(@"kkkkkkkk  %@", videogroups);
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellJou" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    videoInfoDataModel *object = self.videoInfoGroup[indexPath.row];
    cell.textLabel.text = object.videoName;
    cell.detailTextLabel.text = object.videoComments;
    
}

- (IBAction)Back
{
    [self dismissViewControllerAnimated:YES completion:nil]; // ios 6

}
- (void)goBack:(id)sender {
    NSLog(@"try  to  go back back ");
    //[self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
