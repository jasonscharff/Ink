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

@interface NewsfeedViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *objects;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

static NSString *reuseIdentifier = @"com.ink.newsfeed";


@implementation NewsfeedViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.allowsSelection = NO;
  self.tableView.rowHeight = UITableViewAutomaticDimension;
  self.tableView.estimatedRowHeight = 50.0;
  [self.view addSubview:self.tableView];
  self.activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  self.activityView.color = [UIColor inkPurple];
  self.activityView.center = self.view.center;
  [self.view addSubview:self.activityView];
  [self.activityView startAnimating];
  
  [self.tableView registerClass:[NewsfeedTableViewCell class] forCellReuseIdentifier:reuseIdentifier];
  [[NewsfeedStoreController sharedNewsfeedStoreController]getItemsFromServer:^(NSArray *items) {
    self.objects = items;
    [self.tableView reloadData];
    [self.activityView stopAnimating];
    self.activityView.hidden = YES;
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
