//
//  WebPageViewController.m
//  TwitterReader
//
//  Created by Changkun Zhao on 5/5/15.
//  Copyright (c) 2015 Changkun Zhao. All rights reserved.
//

#import "WebPageViewController.h"

@interface WebPageViewController ()

@end

@implementation WebPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}
-(void) viewWillAppear:(BOOL)animated
{
   NSURL *url = [NSURL URLWithString:self.pageURL];
   NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
  [self.webPage loadRequest:requestObj];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
