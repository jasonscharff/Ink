//
//  NewsfeedViewController.m
//  Ink
//
//  Created by Jason Scharff on 1/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "NewsfeedViewController.h"

@interface NewsfeedViewController ()

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation NewsfeedViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
  
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
