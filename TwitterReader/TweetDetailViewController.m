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
#import "ActivityHub.h"

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
     [self buildView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [self.view setNeedsDisplay];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) buildView
{
    // Do any additional setup after loading the view.
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.frame = CGRectMake(10.0, 0.0, 40.0, 40.0);
    activityIndicator.center = self.view.center;
    [self.view addSubview: activityIndicator];
    [activityIndicator startAnimating];
    
    
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:ZCKConsumerKey
                                                            consumerSecret:ZCKConsumerSecret];
    
    [twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        
        
        [twitter getStatusesShowID:self.tweetID trimUser:nil includeMyRetweet:nil includeEntities:[NSNumber numberWithBool:YES] successBlock:^(NSDictionary *status) {
            [activityIndicator stopAnimating];
            self.tweetInfo=status;
            self.user=self.tweetInfo[@"user"];
            [self showTweetDetail];
            
            
        } errorBlock:^(NSError *error) {
            [activityIndicator stopAnimating];
            [self.view setNeedsDisplay];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Loading Error."
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
            
            
            NSLog(@"%@",error.debugDescription);
            
        }];
        
        
    } errorBlock:^(NSError *error) {
        
        [activityIndicator stopAnimating];
        [self.view setNeedsDisplay];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Loading Error."
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];

        NSLog(@"%@",error.debugDescription);
        
    }];
    

    
}
-(void) showTweetDetail
{   //show num of tweets
    NSString *retweet = [NSString stringWithFormat:@"%@ %@", self.tweetInfo[@"retweet_count"],@"retweets"];
    self.retweetLabel.text=retweet;
    
    //show num of favorites
    NSString *favorite =[NSString stringWithFormat:@"%@ %@", self.user[@"favourites_count"],@"favorites"];
    self.favoriteLabel.text=favorite;
    // show profile image
    NSString *imageURL=self.user[@"profile_image_url"];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
    [self.iconImageView setImage:[UIImage imageWithData:data]];
    // show image
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
 
    //should tweet content
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
    
    //show date
    NSString *date=self.user[@"created_at"];
    self.dateLabel.text=[NSString stringWithFormat:@"%@  %@", [self getTweetDate:date],[self getTweetTime:date]];
    
    //show screen name
    NSString *screenName=[NSString stringWithFormat:@"@%@",self.user[@"screen_name"]];
    [self.nameButton setTitle:screenName forState:UIControlStateNormal];
    
    //show user name
    NSString *username=self.user[@"name"];
    [self.userNameButton setTitle:username forState:UIControlStateNormal];
    
}


- (IBAction)userNameButtonClicked:(id)sender {
    self.targetScreenName=self.user[@"screen_name"];
    [self performSegueWithIdentifier: @"timelineSegue" sender: self];
    
}

- (IBAction)nameButtonClicked:(id)sender {
    self.targetScreenName=self.user[@"screen_name"];
    [self performSegueWithIdentifier: @"timelineSegue" sender: self];
}

- (IBAction)replyButtonClicked:(id)sender {
    
    ActivityHub *hub=[[ActivityHub alloc ]initWithFrame:CGRectMake(0, 0,170, 170)];
    hub.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0);
    [hub setLabelText:@"Reply Sent."];
    [hub setImage:[UIImage imageNamed:@"Checkmark-64.png"]];
    [self.view addSubview:hub];
    
    //delay 1.5 seconds for display activity hub
    double delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [hub removeFromSuperview];
    });
    
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

// load prefix of textfied from all mentions and tweet's screen name
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    NSArray *mentions=(self.tweetInfo[@"entities"])[@"user_mentions"];
    NSMutableString *prefix=[NSMutableString stringWithFormat:@"@%@",self.user[@"screen_name"]];
    
    for(NSDictionary *mention in mentions)
    {
        NSString *add=[NSString stringWithFormat:@"@%@",mention[@"screen_name"]];
        [prefix appendString:add];
    }
  
    textField.text=prefix;
    return YES;
}
-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

-(NSString *) getTweetDate:(NSString* ) time
{
    NSArray *array = [time componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *date=[NSString stringWithFormat:@"%@-%@", array[1], array[2]];
    return date;
}

//return time in format hh/mm
-(NSString *) getTweetTime:(NSString* ) time
{
    NSArray *dateArray = [time componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *threeDigiTime=[NSString stringWithFormat:@"%@", dateArray[3]];
    NSArray *timeArray= [threeDigiTime componentsSeparatedByString:@":"];
    NSString *twoDigitTime=[NSString stringWithFormat:@"%@:%@", timeArray[0],timeArray[1]];
    return twoDigitTime;
}


@end
