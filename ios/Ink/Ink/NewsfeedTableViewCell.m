//
//  NewsfeedTableViewCell.m
//  Ink
//
//  Created by Jason Scharff on 1/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "NewsfeedTableViewCell.h"

#import "AutolayoutHelper.h"
#import "NewsfeedItem.h"
#import "UIColor+ColorPalette.h"
#import "UIFontDescriptor+AvenirNext.h"
#import "Utilities.h"

@interface NewsfeedTableViewCell()

@property (nonatomic, strong) UILabel *mainLabel;
@property (nonatomic, strong) UILabel *timestampLabel;

@end

@implementation NewsfeedTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  
  _mainLabel = [UILabel new];
  _mainLabel.numberOfLines = 0;
  _mainLabel.textAlignment = NSTextAlignmentLeft;
  _timestampLabel = [UILabel new];
  _timestampLabel.textAlignment = NSTextAlignmentLeft;
  
  _mainLabel.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleSubheadline] size:0];
  
  _timestampLabel.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleBody] size:0];
  
  [AutolayoutHelper configureView:self.contentView subViews:VarBindings(_mainLabel, _timestampLabel) constraints:@[@"H:|-[_mainLabel]-|", @"V:|-[_timestampLabel]-[_mainLabel]-|", @"H:|-[_timestampLabel]"]];
  
  return self;
}

-(void)configureFromNewsfeedItem : (NewsfeedItem *)item {
  if(item.isPenalty) {
    _mainLabel.textColor = [UIColor inkRed];
    _timestampLabel.textColor = [UIColor inkRed];
  }
  else {
    _mainLabel.textColor= [UIColor inkGreen];
    _timestampLabel.textColor = [UIColor inkGreen];
  }
  _timestampLabel.text = [Utilities shortDateAsStringFromDate:item.timestamp];
  _mainLabel.text = item.contents;
}


@end
