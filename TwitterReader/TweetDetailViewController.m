//
//  TweetDetailViewController.m
//  TwitterReader
//
//  Created by Changkun Zhao on 5/5/15.
//  Copyright (c) 2015 Changkun Zhao. All rights reserved.
//

#import "TweetDetailViewController.h"
#import "STTwitterAPI.h"
#import "TwitterReaderParameters.h"
#import "TimeLineViewController.h"

@interface TweetDetailViewController ()
@property NSDictionary *tweetInfo;
@property NSString *targetScreenName;
@property NSDictionary *user;
@end

@implementation TweetDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

-(void) viewWillAppear:(BOOL)animated
{   [self buildView];
    [self.view setNeedsDisplay];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) buildView
{
    // Do any additional setup after loading the view.
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:ZCKConsumerKey
                                                            consumerSecret:ZCKConsumerSecret];
    
    [twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        
        
        [twitter getStatusesShowID:self.tweetID trimUser:nil includeMyRetweet:nil includeEntities:nil successBlock:^(NSDictionary *status) {
            self.tweetInfo=status;
            self.user=self.tweetInfo[@"user"];
            [self showTweetDetail];
            
            
        } errorBlock:^(NSError *error) {
            
            
            NSLog(@"%@",error.debugDescription);
            
        }];
        
        
    } errorBlock:^(NSError *error) {
        NSLog(@"%@",error.debugDescription);
        
    }];
    

    
}
-(void) showTweetDetail
{
     NSString *retweet = [NSString stringWithFormat:@"%@ %@", self.tweetInfo[@"retweet_count"],@"retweets"];
    self.retweetLabel.text=retweet;
    
    NSString *favorite =[NSString stringWithFormat:@"%@ %@", self.user[@"favourites_count"],@"favorites"];
    self.favoriteLabel.text=favorite;
    
    NSString *imageURL=self.user[@"profile_image_url"];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
    [self.iconImageView setImage:[UIImage imageWithData:data]];
    
    self.contentLabel.text=self.tweetInfo[@"text"];
    
    [self.nameButton setTitle:self.user[@"screen_name"] forState:UIControlStateNormal];
}


- (IBAction)nameButtonClicked:(id)sender {
    self.targetScreenName=self.user[@"screen_name"];
    [self performSegueWithIdentifier: @"timelineSegue" sender: self];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"timelineSegue"]) {
        TimeLineViewController *destViewController=segue.destinationViewController;
      //  destViewController.scrrenName=self.targetScreenName;
        
          destViewController.scrrenName=@"NBAcom";

    }}

@end
