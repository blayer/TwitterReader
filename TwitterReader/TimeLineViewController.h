//
//  TimeLineViewController.h
//  TwitterReader
//
//  Created by Changkun Zhao on 5/4/15.
//  Copyright (c) 2015 Changkun Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeLineViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *timeLineTableView;

@end
