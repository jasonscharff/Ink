//
//  HistoryViewController.m
//  Ink
//
//  Created by Jason Scharff on 1/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "HistoryViewController.h"

#import "AutolayoutHelper.h"
#import "HistoryStoreController.h"
#import "HistoryTableViewCell.h"
#import "Transaction.h"


static NSString *identifier = @"com.ink.history";


@interface HistoryViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *transactions;

@end

@implementation HistoryViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  _tableView = [[UITableView alloc]init];
  UILabel *frontLabel = [UILabel new];
  frontLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:45];
  frontLabel.textAlignment = NSTextAlignmentCenter;
  _tableView.delegate = self;
  _tableView.dataSource = self;
  [AutolayoutHelper configureView:self.view subViews:VarBindings(frontLabel, _tableView) constraints:@[@"H:|[_tableView]|", @"H:|-[frontLabel]-|", @"V:|-[frontLabel]-12-[_tableView]|"]];
  
  [[HistoryStoreController sharedHistoryStoreController]getLastMonthsHistory:^(NSArray *results) {
    _transactions = results;
    [self.tableView reloadData];
  }];
  
  
  
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  return _transactions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  HistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  if(indexPath.row > 0) {
    Transaction *current = _transactions[indexPath.row];
    Transaction *previous = _transactions[indexPath.row - 1];
    if(![previous.date isEqualToString:current.date]) {
      [cell setupFromTransaction:current shouldShowDate:YES];
    }
    else {
      [cell setupFromTransaction:current shouldShowDate:NO];
    }
  }
  else {
    Transaction *current = _transactions[indexPath.row];
    [cell setupFromTransaction:current shouldShowDate:YES];
  }
  return cell;
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
