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

@interface TimeLineViewController ()
@property (strong,nonatomic) NSMutableArray *twitterFeed;
@property (strong,nonatomic) NSDictionary  *feedDict;
@property (weak,nonatomic) NSString *selectedID;

@end

@implementation TimeLineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.scrrenName==nil)
    { self.scrrenName=@"NBAcom";}
    
       // Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated
{
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:ZCKConsumerKey
                                                            consumerSecret:ZCKConsumerSecret];
    
    [twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
        
        [twitter getUserTimelineWithScreenName:self.scrrenName successBlock:^(NSArray *statuses) {
            
            self.twitterFeed=[NSMutableArray arrayWithArray:statuses];
            [self.timeLineTableView reloadData];
            
            
        } errorBlock:^(NSError *error) {
            
            NSLog(@"%@",error.debugDescription);
        }];
        
    } errorBlock:^(NSError *error) {
        
        NSLog(@"%@",error.debugDescription);
        
        
    }];
    

    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// return date in format mm/dd/yyyy
-(NSString *) getTweetDate:(NSString* ) time
{
    NSArray *array = [time componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *date=[NSString stringWithFormat:@"%@/%@/%@", array[1], array[2], array[5]];
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
    NSString *time=[self getTweetTime:feed[@"created_at"]];
    NSString *handleName=[NSString stringWithFormat:@"@%@",user[@"screen_name"]];
    cell.handleLabel.text=handleName;
    cell.date.text=time;
    [cell.icon setImage:[UIImage imageWithData:data]];
    
    
    NSDictionary *entities=feed[@"entities"];
    NSArray *mediaList=entities[@"media"];
    NSDictionary *media=[mediaList objectAtIndex:0];
    NSString *contentImageURL= media[@"media_url"];
    NSString *size=@"medium";
    
    NSData *contentData = [NSData dataWithContentsOfURL:[NSURL URLWithString:
                                                         [NSString stringWithFormat:@"%@:%@",contentImageURL,size ]]];
    [cell.picture setImage:[UIImage imageWithData:contentData]];
    if(contentData==nil)
    {
        [cell.picture removeFromSuperview];
        
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
    
    else return 240.0f;
    
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
