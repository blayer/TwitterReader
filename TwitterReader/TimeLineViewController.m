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

@interface TimeLineViewController ()
@property (strong,nonatomic) NSMutableArray *twitterFeed;
@property (strong,nonatomic) NSDictionary  *feedDict;

@end

@implementation TimeLineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:ZCKConsumerKey
                                                            consumerSecret:ZCKConsumerSecret];
    [twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
        
        [twitter getUserTimelineWithScreenName:@"NBA" successBlock:^(NSArray *statuses) {
            
            self.twitterFeed=[NSMutableArray arrayWithArray:statuses];
            [self.timeLineTableView reloadData];
            
            
        } errorBlock:^(NSError *error) {
            
            NSLog(@"%@",error.debugDescription);
        }];
        
    } errorBlock:^(NSError *error) {
        
        NSLog(@"%@",error.debugDescription);

        
    }];
    
   
       // Do any additional setup after loading the view.
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    cell.date.text=time;
    [cell.icon setImage:[UIImage imageWithData:data]];
    
  /*  NSDictionary* urls=feed[@"urls"];
    NSString *imgURL=urls[@"url"];
    NSData *external = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
    [cell.picture setImage:[UIImage imageWithData:external]];
   */
    return cell;
}
-(void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
     UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    NSString *string =@"test";
    /* Section header is in 0th index... */
    [label setText:string];
    [view addSubview:label];
    return view;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
