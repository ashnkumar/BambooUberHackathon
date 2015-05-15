//
//  DetailedReceiptViewController.m
//  uberhxthon
//
//  Created by Catherine Jue on 5/12/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import "DetailedReceiptViewController.h"
#define kStatusRequestUber @"requestUber"
#define kStatusUberRequested @"uberRequested"
#define kStatusOutForDelivery @"outForDelivery"
#define kStatusOrderComplete @"deliveryComplete"

@interface DetailedReceiptViewController ()
@property (strong, nonatomic) NSMutableArray *orderDetailsArr;
@property (strong,nonatomic) NSString *orderStatus;
@end

@implementation DetailedReceiptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.orderDetails.allowsSelection = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)layoutDetails:(NSMutableArray *)details
{
    //Details array contains: order number, date ordered, time ordered, orderer's name, orderer's address line 1, orderer's address line 2, orderer's phonenumber, order details, paymentType, paymentLastFourDigits
    if ([details count] == 11)
    {
        self.orderDetailsArr = [[NSMutableArray alloc]init];
        self.orderNumber.text = [NSString stringWithFormat:@"#%@", details[0]];
        self.orderDate.text = [NSString stringWithFormat:@"%@ - %@", details[1], details[2]];
        self.destinationName.text = details[3];
        self.destinationAddressLine1.text = details[4];
        self.destinationAddressLine2.text = details[5];
        self.destinationPhoneNum.text = details[6];
        //TODO: layout order details, paymentType, paymentLastFourDigits
        NSDictionary *orderDetailsDict = details[7];
        self.paymentType.text = details[8];
        self.paymentLastFourDigits.text = [NSString stringWithFormat:@"****%@", details[9]];
        self.orderStatus = details[10];
        
        //Display the header images
        if ([self.orderStatus isEqualToString:kStatusRequestUber])
        {
            self.headerView.backgroundColor = [AppConstants receiptOrange];
            self.receiptStatus.text = @"Uber Not Yet Requested";
        }
        else if ([self.orderStatus isEqualToString:kStatusUberRequested])
        {
            self.headerView.backgroundColor = [AppConstants receiptPink];
            self.receiptStatus.text = @"Uber Requested";
        }
        else if ([self.orderStatus isEqualToString:kStatusOutForDelivery])
        {
            self.headerView.backgroundColor = [AppConstants receiptBlue];
            self.receiptStatus.text = @"Out for Delivery";
        }
        else if ([self.orderStatus isEqualToString:kStatusOrderComplete])
        {
            self.headerView.backgroundColor = [AppConstants cashwinGreen];
            self.receiptStatus.text = @"Delivery Complete";
        }
        else
        {
            NSLog(@"status is incorrect - couldn't set header in detailed receipt view");
        }
        
        //Move order details to array for tableview
        for (NSString *key in [orderDetailsDict allKeys])
        {
            NSString *obj = [orderDetailsDict objectForKey:key];
            [self.orderDetailsArr addObject:[NSString stringWithFormat:@"%@: %@", key, obj]];
        }
        [self.orderDetails reloadData];
    }
    else
    {
        NSLog(@"order details array doesn't have expected number of parameters inside detailedreceiptviewcontroller's layoutDetails");
    }
}

- (void)drawRect:(CGRect)rect{
    
}

#pragma mark - TableView
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] init];
    label.text=@"Order Details";
    label.backgroundColor=[AppConstants specialWhite];
    label.textColor = [AppConstants specialWhite];
    label.font = [label.font fontWithSize:18];
    label.textAlignment= NSTextAlignmentCenter;
    label.layer.borderColor = [AppConstants specialBlack].CGColor;
    label.layer.borderWidth = 2.0;
    return label;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.orderDetailsArr count];
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
    
    NSString *text = [self.orderDetailsArr objectAtIndex:indexPath.row];
    cell.textLabel.text = text;
    return cell;
}

@end
