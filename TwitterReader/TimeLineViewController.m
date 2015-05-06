//
//  TimeLineViewController.m
//  TwitterReader
//
//  Created by Changkun Zhao on 5/4/15.
//  Copyright (c) 2015 Changkun Zhao. All rights reserved.
//

#import "TimeLineViewController.h"
#import "STTwitterAPI.h"
#import "TweetCell.h"
#import "TwitterReaderParameters.h"
#import "TweetDetailViewController.h"
#import "SVPullToRefresh.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface TimeLineViewController ()
@property (strong,nonatomic) NSMutableArray *twitterFeed;
@property (strong,nonatomic) NSDictionary  *feedDict;
@property (weak,nonatomic) NSString *selectedID;
@property (weak,nonatomic) NSString *lastID;
@property NSInteger count;

@end

@implementation TimeLineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.scrrenName==nil)
    { self.scrrenName=@"NBAcom";}
    
    __weak TimeLineViewController *weakSelf = self;
    
    [self.timeLineTableView addInfiniteScrollingWithActionHandler:^{
            [weakSelf loadMoreTweets];
    }];
       // Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated
{ [self firstLoadTweets];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.timeLineTableView triggerPullToRefresh];
}


-(void) firstLoadTweets
{
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:ZCKConsumerKey
                                                            consumerSecret:ZCKConsumerSecret];
    
    [twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID){
        
        [twitter getUserTimelineWithScreenName:self.scrrenName count:NumberOfTweetsPerPull successBlock:^(NSArray *statuses) {
            self.twitterFeed=[NSMutableArray arrayWithArray:statuses];
            [self.timeLineTableView reloadData];
        } errorBlock:^(NSError *error) {
            NSLog(@"%@",error.debugDescription);
        }];
        
    } errorBlock:^(NSError *error) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Loading Error."
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        NSLog(@"%@",error.debugDescription);
        
        
    }];
}
-(void) loadMoreTweets
{
    
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:ZCKConsumerKey
                                                            consumerSecret:ZCKConsumerSecret];
    
    NSDictionary *lastFeed=[self.twitterFeed objectAtIndex:[self.twitterFeed count]-1];
    self.lastID=lastFeed[@"id_str"];
    [twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID){
        
        [twitter getUserTimelineWithScreenName:self.scrrenName sinceID:nil maxID:self.lastID count:NumberOfTweetsPerPull successBlock:^(NSArray *statuses) {
         // adding elements of statuses with first element removed,
         // becuase the first is a duplicate.
            self.count=[statuses count]-1;
            for (int i = 1; i <= self.count; i++)
            {
                [self.twitterFeed addObject:[statuses objectAtIndex:i]];
            }
            [self insertRowAtBottom];
        } errorBlock:^(NSError *error) {
            
            NSLog(@"%@",error.debugDescription);
        }];
    } errorBlock:^(NSError *error) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Loading Error."
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        NSLog(@"%@",error.debugDescription);
        
        
    }];

}

- (void)insertRowAtBottom {
    
    __weak TimeLineViewController *weakSelf = self;
    
    int64_t delayInSeconds =1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        
        for (int i = 0; i < self.count; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:self.twitterFeed.count+i-self.count inSection:0]];
        }
        [weakSelf.timeLineTableView beginUpdates];
        [weakSelf.timeLineTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
        [weakSelf.timeLineTableView endUpdates];
        [weakSelf.timeLineTableView.infiniteScrollingView stopAnimating];
    });
}


// return date in format mm/dd/yyyy
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



// using headers is not a good choice for timeline display

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{ return self.twitterFeed.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellID=@"CellID";
    TweetCell* cell=[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil)
    { cell = [[TweetCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];}
    
    NSInteger index=indexPath.row;
    NSDictionary* feed=self.twitterFeed[index];
    NSDictionary* user=feed[@"user"];
    cell.subtitleLabel.text=feed[@"text"];
    cell.titleLabel.text=user[@"name"];
    NSString *imageURL=user[@"profile_image_url"];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
    NSString *fullDate=feed[@"created_at"];
    cell.date.text=[NSString stringWithFormat:@"%@  %@",[self getTweetDate:fullDate],[self getTweetTime:fullDate] ];
    
    [cell.icon setImage:[UIImage imageWithData:data]];
    
    NSString *handleName=[NSString stringWithFormat:@"@%@",user[@"screen_name"]];
    cell.handleLabel.text=handleName;
    
    NSDictionary *entities=feed[@"entities"];
    NSArray *mediaList=entities[@"media"];
    NSDictionary *media=[mediaList objectAtIndex:0];
    NSString *contentImageURL= media[@"media_url"];
    NSString *size=@"small";
    if(contentImageURL==nil)
    {
        [cell.picture removeFromSuperview];
        
    }
    else {
    
  // downloading image asychronized, it would not block ui. 
        [cell.picture sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@:%@",contentImageURL,size ]]
                          placeholderImage:[UIImage imageNamed:contentImageURL]
                          options:SDWebImageRefreshCached];
        
    }
    
    // record id string in the cell,reuse it when cell clicked
    cell.tweetID=feed[@"id_str"];
    
   
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    self.selectedID=selectedCell.tweetID;
    [self performSegueWithIdentifier: @"detailSegue" sender: self];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* feed=self.twitterFeed[indexPath.row];
    NSDictionary *entities=feed[@"entities"];
    NSArray *mediaList=entities[@"media"];
    NSDictionary *media=[mediaList objectAtIndex:0];
    NSString *contentImageURL= media[@"media_url"];
    if(contentImageURL==nil)
    {   return 100.0f;}
    
    else return 270.0f;
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"detailSegue"]) {
        TweetDetailViewController *destViewController=segue.destinationViewController;
        destViewController.tweetID=self.selectedID;
    }}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
