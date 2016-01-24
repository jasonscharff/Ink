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
#import "UIColor+ColorPalette.h"


static NSString *identifier = @"com.ink.history";


@interface HistoryViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *transactions;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation HistoryViewController

-(void)viewWillAppear:(BOOL)animated {
  self.navigationController.navigationBar.topItem.title = @"Ink";
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  
  _activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  _activityView.color = [UIColor inkPurple];
  [_activityView startAnimating];
  
  _tableView = [[UITableView alloc]init];
  [_tableView registerClass:[HistoryTableViewCell class] forCellReuseIdentifier:identifier];
  _tableView.delegate = self;
  _tableView.allowsSelection = NO;
  _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  _tableView.dataSource = self;
  self.tableView.rowHeight = UITableViewAutomaticDimension;
  self.tableView.estimatedRowHeight = 80.0;
  [AutolayoutHelper configureView:self.view subViews:VarBindings (_tableView, _activityView) constraints:@[@"H:|[_tableView]|", @"V:|[_tableView]|", @"X:_activityView.centerX == superview.centerX", @"X:_activityView.centerY == superview.centerY"]];
  
  _refreshControl = [[UIRefreshControl alloc]init];
  [self.tableView addSubview:_refreshControl];
  [_refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
  
  
  [[HistoryStoreController sharedHistoryStoreController]getLastMonthsHistory:^(NSArray *results) {
    _transactions = results;
    [self.tableView reloadData];
    [_activityView stopAnimating];
    _activityView.hidden = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
  }];
  
}

- (void)refreshTable : (UITableView *)tableView{
  [[HistoryStoreController sharedHistoryStoreController]queryFromInternet:^(NSArray *results) {
    _transactions = results;
    [self.tableView reloadData];
    [_activityView stopAnimating];
    _activityView.hidden = YES;
    [_refreshControl endRefreshing];
  }];
}

-(void)viewDidAppear:(BOOL)animated {
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
