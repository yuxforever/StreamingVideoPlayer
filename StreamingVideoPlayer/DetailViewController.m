//
//  DetailViewController.m
//  StreamingVideoPlayer
//
//  Created by Yu Ma on 7/22/16.
//  Copyright © 2016 Yu Ma. All rights reserved.
//

#import "DetailViewController.h"
#import <AWSS3/AWSS3.h>
#import <MediaPlayer/MediaPlayer.h>
#import "JournalViewController.h"


@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (nonatomic, strong) NSString *Url1;
@property (nonatomic, strong) NSString *Url2;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(videoInfoDataModel *)newDetailItem {
    if (_videoModeInfo != newDetailItem) {
        _videoModeInfo = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.videoModeInfo) {
        self.detailDescriptionLabel.text = self.videoModeInfo.videoName;
        NSLog(@"Your user hash ID is:   %@", self.videoModeInfo.userId);
        [self mediaPlayerGetUrl:self.videoModeInfo.videoUrl];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.Url1 = @"https://s3.amazonaws.com/michaelmavideostreaming/";
//self.Url2 = @".mp4";
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)mediaPlayerGetUrl:(NSString *)urlInfo{
    
    // NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat: @"https://s3.amazonaws.com/michaelmavideostreaming/CH002.mp4"]];
    NSURL *url = [[NSURL alloc] initWithString:urlInfo];
    NSLog(@"jjjjjj %@",  url);
   // NSURL *url = [[NSURL alloc] initWithString:urlInfo];
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    
    [_moviePlayer.view setFrame:_videoView.bounds];
    [_moviePlayer.view setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [_videoView addSubview:_moviePlayer.view];
    
    _moviePlayer.fullscreen = YES;
    _moviePlayer.allowsAirPlay = YES;
    _moviePlayer.shouldAutoplay = NO;
    _moviePlayer.controlStyle = MPMovieControlStyleDefault;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoFinished)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toJournal"]) {
       JournalViewController *controller = (JournalViewController *)[[segue destinationViewController] topViewController];
       
        //controller.navigationItem.leftItemsSupplementBackButton = YES;
        
    }
}
- (IBAction)goToJurnal:(id)sender {
    
   JournalViewController *journalController = [self.storyboard instantiateViewControllerWithIdentifier:@"journalViewController"];
    
    [[self navigationController] pushViewController:journalController animated:YES];
}

-(void)videoFinished{
    
    NSLog(@"ssssssss");
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Comments"
                                                                              message: @"Leave Comments Here"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"comments";
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * namefield = textfields[0];
            if (namefield.text != nil && ![namefield.text isEqualToString:@""]) {
                [self saveVideoInfo:namefield.text];
            }
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

-(void)saveVideoInfo: (NSString *)WithCommnet{
    NSLog(@"Your Comments Is %@:",WithCommnet);
    
    self.videoModeInfo.videoComments = WithCommnet;
            AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
            [[dynamoDBObjectMapper save: self.videoModeInfo]
             continueWithBlock:^id(AWSTask *task) {
                 if (task.error) {
                     NSLog(@"The request failed. Error: [%@]", task.error);
                 }
                 if (task.exception) {
                     NSLog(@"The request failed. Exception: [%@]", task.exception);
                 }
                 if (task.result) {
                     //Do something with the result.
                 }
                 return nil;
             }];

}

-(void)downLoadFromAwsS3{
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"downloaded-CH00_BD1_10-6-11.mp4"];
    NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
   
    //NSURL *downloadingFileURL = [[NSURL alloc] initWithString:[NSString stringWithFormat: @"http://s3.amazonaws.com/michaelmavideostreaming/CH00_BD1_10-6-11.mp4"]];
    
    // Construct the download request.
    AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
    
    downloadRequest.bucket = @"michaelmavideostreaming";
    downloadRequest.key = @"CH00_BD1_10-6-11.mp4";
    downloadRequest.downloadingFileURL = downloadingFileURL;
    
    // Download the file.
    [[transferManager download:downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                           withBlock:^id(AWSTask *task) {
                                                               if (task.error){
                                                                   if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                                                                       switch (task.error.code) {
                                                                           case AWSS3TransferManagerErrorCancelled:
                                                                           case AWSS3TransferManagerErrorPaused:
                                                                               break;
                                                                               
                                                                           default:
                                                                               NSLog(@"Error: %@", task.error);
                                                                               break;
                                                                       }
                                                                   } else {
                                                                       // Unknown error.
                                                                       NSLog(@"Error: %@", task.error);
                                                                   }
                                                               }
                                                               
                                                               if (task.result) {
                                                                   AWSS3TransferManagerDownloadOutput *downloadOutput = task.result;
                                                                   //File downloaded successfully.
                                                                   NSLog(@"sssssssss  %@", downloadOutput);
                                                               }
                                                               return nil;
                                                           }];
}

@end
