//
//  NewsfeedTableViewCell.h
//  Ink
//
//  Created by Jason Scharff on 1/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewsfeedItem;

@interface NewsfeedTableViewCell : UITableViewCell

-(void)configureFromNewsfeedItem : (NewsfeedItem *)item;

@end
