//
//  ViewController.m
//  MagicBeep
//
//  Created by ALOUI Rabeb on 08/02/15.
//  Copyright (c) 2015 ISKN. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize mainText;
@synthesize connectionStatus;
@synthesize activityIndicator;
@synthesize devicesList;
@synthesize myData;

extern void launchMagicBeep(ViewController* viewController) ;
extern void deviceSelected(int deviceID);

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    myData = [[NSMutableArray alloc]initWithObjects:
              nil];
    
    launchMagicBeep(self) ;
    [connectionStatus setTitle:@"Not connected"];
    // Do any additional setup after loading the view, typically from a nib.
    [devicesList setDelegate:self];
    [devicesList setDataSource:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View Data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:
(NSInteger)section{
    return [myData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSString *stringForCell;
    stringForCell= [myData objectAtIndex:indexPath.row];

    [cell.textLabel setText:stringForCell];
    return cell;
}

// Default is 1 if not implemented
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:
(NSInteger)section{
    NSString *headerTitle;
    headerTitle = @"Devices list";
    return headerTitle;
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:
(NSInteger)section{
    NSString *footerTitle;
    footerTitle = @"";

    return footerTitle;
}

#pragma mark - TableView delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:
(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    deviceSelected((int)indexPath.row);
    NSLog(@"Section:%ld Row:%ld selected and its data is %@",
          (long)indexPath.section,(long)indexPath.row,cell.textLabel.text);
}



@end
