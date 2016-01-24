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

static int maxNameLength = 15;

@interface HistoryTableViewCell()

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *merchant;
@property (nonatomic, strong) UILabel *amount;
@property (nonatomic, strong) UILabel *savedLabel;

@end

@implementation HistoryTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  
  self.dateLabel = [UILabel new];
  self.merchant = [UILabel new];
  self.amount = [UILabel new];
  _savedLabel = [UILabel new];
  
  self.dateLabel.textAlignment = NSTextAlignmentCenter;
  self.dateLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:18];
  
  
  self.merchant.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleHeadline]size:0];
  
  self.amount.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleHeadline]size:0];
  
  _amount.textAlignment = NSTextAlignmentRight;
  
  self.savedLabel.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleCaption1]size:0];
  
  
  
  [AutolayoutHelper configureView:self.contentView subViews:VarBindings(_dateLabel, _merchant, _amount, _savedLabel) constraints:@[@"H:|-[_dateLabel]-|", @"V:|-[_dateLabel]-14-[_merchant]", @"V:[_dateLabel]-14-[_amount]-[_savedLabel]-|", @"H:|-[_merchant][_amount]-|", @"H:[_savedLabel]-|"]];

  return self;
}

-(void)setupFromTransaction: (Transaction *)transaction  shouldShowDate : (BOOL)shouldShowDate {
  if(shouldShowDate) {
    self.dateLabel.hidden = NO;
    self.dateLabel.text = [Utilities formatDateFromPlaid:transaction.date];
  }
  else {
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
    NSString *baseString = [NSString stringWithFormat:@"Saved %@", [Utilities roundedDollarStringFromNumbers:transaction.amountSaved]];
    
    NSMutableAttributedString *saved = [[NSMutableAttributedString alloc] initWithString:baseString];
    
    NSRange range = [baseString rangeOfString:@"Saved "];
    
    [saved addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:range];
    [saved addAttribute:NSForegroundColorAttributeName value:[UIColor inkGreen] range:NSMakeRange(range.location+range.length, baseString.length-range.length)];
    
    self.savedLabel.attributedText = saved;
  }
  else {
    self.savedLabel.attributedText = [[NSAttributedString alloc]initWithString:@""];
  }
  
  self.amount.text = [Utilities roundedDollarStringFromNumbers:(transaction.amount)];
  self.merchant.text = [transaction.merchant substringToIndex: MIN(maxNameLength, [transaction.merchant length])];
  
  
  
  
  
}

@end
