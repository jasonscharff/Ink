//
//  HistoryTableViewCell.m
//  Ink
//
//  Created by Jason Scharff on 1/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "HistoryTableViewCell.h"

#import "AutolayoutHelper.h"
#import "UIFontDescriptor+AvenirNext.h"
#import "Transaction.h"
#import "UIColor+ColorPalette.h"
#import "Utilities.h"

@interface HistoryTableViewCell()

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIView *separator;
@property (nonatomic, strong) UILabel *merchant;
@property (nonatomic, strong) UILabel *amount;
@property (nonatomic, strong) UILabel *savedLabel;

@end

@implementation HistoryTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  
  self.dateLabel = [UILabel new];
  self.separator = [UIView new];
  self.merchant = [UILabel new];
  self.amount = [UILabel new];
  
  self.dateLabel.textAlignment = NSTextAlignmentCenter;
  self.dateLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:35];
  
  self.separator.backgroundColor = [UIColor lightGrayColor];
  
  self.merchant.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleSubheadline]size:0];
  
  self.amount.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleHeadline]size:0];
  
  self.savedLabel.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleCaption1]size:0];
  
  
  
  [AutolayoutHelper configureView:self.contentView subViews:VarBindings(_dateLabel, _separator, _merchant, _amount) constraints:@[@"H:|-[_dateLabel]-|", @"V:|-[_dateLabel]-[_separator]-14-[_merchant]", @"V:[separator(1)]-14-[_amount]-[_savedLabel]-|", @"H:|-4-[separator]-4|", @"H:|-[_merchant]", @"H:[_amount]-|", @"H:[_savedLabel]-|"]];

  return self;
}

-(void)setupFromTransaction: (Transaction *)transaction  shouldShowDate : (BOOL)shouldShowDate {
  if(shouldShowDate) {
    self.separator.hidden = NO;
    self.dateLabel.hidden = NO;
    self.dateLabel.text = [Utilities formatDateFromPlaid:transaction.date];
  }
  else {
    self.separator.hidden = YES;
    self.dateLabel.hidden = YES;
    self.dateLabel.text = @"";
  }
  if(transaction.lostMoney) {
    self.amount.textColor = [UIColor inkRed];
    
  }
  else {
    self.amount.textColor = [UIColor inkGreen];
  }
  
  if(transaction.amountSaved > 0) {
    self.savedLabel.text = [NSString stringWithFormat:@"Saved %@", [Utilities roundedDollarStringFromNumbers:transaction.amountSaved]];
  }
  else {
    self.savedLabel.text = @"";
  }
  
  self.amount.text = [Utilities roundedDollarStringFromNumbers:transaction.amount];
  
  
  
  
}

@end
