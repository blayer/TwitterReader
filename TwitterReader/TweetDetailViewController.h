//
//  TweetDetailViewController.h
//  TwitterReader
//
//  Created by Changkun Zhao on 5/5/15.
//  Copyright (c) 2015 Changkun Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIButton *nameButton;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetLabel;
@property (weak, nonatomic) IBOutlet UILabel *favoriteLabel;
@property (weak, nonatomic) IBOutlet UITextField *replyTextField;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;

@end
