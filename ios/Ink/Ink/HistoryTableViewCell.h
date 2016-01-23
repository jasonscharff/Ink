//
//  HistoryTableViewCell.h
//  Ink
//
//  Created by Jason Scharff on 1/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Transaction;

@interface HistoryTableViewCell : UITableViewCell

-(void)setupFromTransaction: (Transaction *)transaction  shouldShowDate : (BOOL)shouldShowDate;

@end
