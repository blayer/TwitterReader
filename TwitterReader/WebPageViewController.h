//
//  WebPageViewController.h
//  TwitterReader
//
//  Created by Changkun Zhao on 5/5/15.
//  Copyright (c) 2015 Changkun Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebPageViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *webPage;
@property NSString *pageURL;

@end
