//
//  ViewController.h
//  MagicBeep
//
//  Created by ALOUI Rabeb on 08/02/15.
//  Copyright (c) 2015 ISKN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *myData;
}
@property NSMutableArray *myData;
@property (weak, nonatomic) IBOutlet UITextView *mainText;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *connectionStatus;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITableView *devicesList;

@end

