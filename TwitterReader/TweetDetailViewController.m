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

@interface TweetDetailViewController ()
@property NSDictionary *tweetInfo;
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
     NSString *result = [NSString stringWithFormat:@"%@ %@", self.tweetInfo[@"retweet_count"],@"retweet"];
    self.retweetLabel.text=result;
    
}


@end
