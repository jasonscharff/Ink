//
//  NewsfeedViewController.m
//  Ink
//
//  Created by Jason Scharff on 1/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "NewsfeedViewController.h"
#import "NewsfeedTableViewCell.h"
#import "NewsfeedStoreController.h"
#import "UIColor+ColorPalette.h"
#import "AutolayoutHelper.h"

@interface NewsfeedViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *objects;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

static NSString *reuseIdentifier = @"com.ink.newsfeed";


@implementation NewsfeedViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tableView = [[UITableView alloc]init];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.allowsSelection = NO;
  self.tableView.rowHeight = UITableViewAutomaticDimension;
  self.tableView.estimatedRowHeight = 50.0;
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  self.activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  self.activityView.color = [UIColor inkPurple];
  
  [AutolayoutHelper configureView:self.view subViews:VarBindings(_tableView, _activityView) constraints:@[@"H:|[_tableView]|", @"V:|[_tableView]|", @"X:_activityView.centerX == superview.centerX", @"X:_activityView.centerY == superview.centerY"]];
  
  [self.activityView startAnimating];
  
  _refreshControl = [[UIRefreshControl alloc]init];
  [self.tableView addSubview:_refreshControl];
  [_refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
  
  [self.tableView registerClass:[NewsfeedTableViewCell class] forCellReuseIdentifier:reuseIdentifier];
  [[NewsfeedStoreController sharedNewsfeedStoreController]getItemsFromServer:^(NSArray *items) {
    self.objects = items;
    [self.tableView reloadData];
    [self.activityView stopAnimating];
    self.activityView.hidden = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
  }];
}

-(void)refreshTable : (UITableView *)tableView {
  [[NewsfeedStoreController sharedNewsfeedStoreController]getItemsFromServer:^(NSArray *items) {
    self.objects = items;
    [self.tableView reloadData];
    [self.activityView stopAnimating];
    self.activityView.hidden = YES;
    [_refreshControl endRefreshing];
  }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NewsfeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  [cell configureFromNewsfeedItem:self.objects[indexPath.row]];
  return cell;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
