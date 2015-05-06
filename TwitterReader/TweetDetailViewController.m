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
#import "STTweetLabel.h"
#import "WebPageViewController.h"

@interface TweetDetailViewController ()
@property (nonatomic, weak) IBOutlet STTweetLabel *tweetLabel;
@property NSDictionary *tweetInfo;
@property NSString *targetScreenName;
@property NSString *targetURL;
@property NSDictionary *user;
@end

@implementation TweetDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.replyTextField.delegate = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
    
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
        
        
        [twitter getStatusesShowID:self.tweetID trimUser:nil includeMyRetweet:nil includeEntities:[NSNumber numberWithBool:YES] successBlock:^(NSDictionary *status) {
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
    
    NSDictionary *entities=self.tweetInfo[@"entities"];
    NSArray *mediaList=entities[@"media"];
    NSDictionary *media=[mediaList objectAtIndex:0];
    NSString *contentImageURL= media[@"media_url"];
    NSString *size=@"large";

    NSData *contentData = [NSData dataWithContentsOfURL:[NSURL URLWithString:
                                                         [NSString stringWithFormat:@"%@:%@",contentImageURL,size ]]];
    
    [self.contentImageView setImage:[UIImage imageWithData:contentData]];
    
    if(contentData==nil)
    {
        [self.contentImageView removeFromSuperview];
       
         }
 
    
    self.tweetLabel.text=self.tweetInfo[@"text"];
    self.tweetLabel.detectionBlock = ^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {
        
        NSArray *hotWords = @[@"Handle", @"Hashtag", @"Link"];
        
        NSString *typeTag = [NSString stringWithFormat:@"%@", hotWords[hotWord]];
        
        if([typeTag isEqualToString:@"Link"])
        {     self.targetURL=string;
             [self performSegueWithIdentifier: @"webpageSegue" sender: self];
            
        }
        if([typeTag isEqualToString:@"Handle"])
        { self.targetScreenName=[string substringFromIndex:1];
         [self performSegueWithIdentifier: @"timelineSegue" sender: self];
        }
        
    };
    
  //  [self.contentTextView setDataDetectorTypes:UIDataDetectorTypeAll];
    
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
        destViewController.scrrenName=self.targetScreenName;
        
    }
    
    if([segue.identifier isEqualToString:@"webpageSegue"]){
        WebPageViewController *destViewController=segue.destinationViewController;
        destViewController.pageURL=self.targetURL;
    }
}

//for dismiss keyboards
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
    
}
-(void)dismissKeyboard {
    [self.view endEditing:YES];
}



@end
