//
//  SettingsViewController.m
//  uberhxthon
//
//  Created by Catherine Jue on 4/26/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()
@property (strong, nonatomic) NSMutableArray *completedUberReceipts;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.completedUberReceipts = [[NSMutableArray alloc]initWithObjects:@"Order Number: 40 - $8.56", @"Order Number: 41 - $15.44", @"Order Number: 58 - $33.76", @"Order Number: 38 - $12.12", @"Order Number: 39 - $6.10", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] init];
    label.text=@"Completed Order Uber Receipts";
    label.font = [label.font fontWithSize:24];
    label.backgroundColor=[AppConstants cashwinGreen];
    label.textColor = [AppConstants specialWhite];
    label.textAlignment= NSTextAlignmentCenter;
    return label;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Order Details";
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.completedUberReceipts count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [self.completedUberReceipts objectAtIndex:indexPath.row];
    cell.textLabel.font = [ UIFont fontWithName: @"Open Sans" size: 24.0 ];
    return cell;
}

@end
