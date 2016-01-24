//
//  BalanceViewController.m
//  Ink
//
//  Created by Jason Scharff on 1/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "BalanceViewController.h"

#import "AutolayoutHelper.h"
#import "XYDoughnutChart.h"

#import "UIColor+ColorPalette.h"
#import "UIFontDescriptor+AvenirNext.h"
#import "Utilities.h"

#import "BalanceStoreController.h"

@interface BalanceViewController () <XYDoughnutChartDataSource, XYDoughnutChartDelegate>

@property (nonatomic, strong) XYDoughnutChart *donutChart;
@property (nonatomic, strong) UILabel *totalLabel;
@property (nonatomic, strong) NSArray *donutValues;
@property (nonatomic, strong) UILabel *checkingLabel;
@property (nonatomic, strong) UILabel *savingsLabel;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

static int kINKDistanceFromSuperview = 20;
static int KINKDonutChartStrokeLength = 20;

@implementation BalanceViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  self.spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  self.spinner.layer.zPosition = 1000;
  self.spinner.color = [UIColor inkPurple];
  [self.view addSubview:self.spinner];
  self.spinner.center = self.view.center;
  [self.spinner startAnimating];
  [self addDonutChart];
  [[BalanceStoreController sharedBalanceStoreController]refreshData:^(NSArray *results) {
    self.donutValues = results;
    NSLog(@"results = %@", results);
    [self addTotalLabel];
    [self addIndividualLabels];
    [_spinner stopAnimating];
    _spinner.hidden = YES;
    [_donutChart reloadData:NO];
  }];
  [self addCircle];
}

-(void)viewWDidAppear:(BOOL)animated {
  [[BalanceStoreController sharedBalanceStoreController]refreshData:^(NSArray *results) {
    self.donutValues = results;
    NSLog(@"results = %@", results);
    [self addTotalLabel];
    [self addIndividualLabels];
    [_spinner stopAnimating];
    _spinner.hidden = YES;
    [_donutChart reloadData:NO];
  }];
}

-(void)addDonutChart {
  _donutChart = [[XYDoughnutChart alloc]init];
  _donutChart.delegate = self;
  _donutChart.dataSource = self;
  _donutChart.startDoughnutAngle = 0;
  _donutChart.userInteractionEnabled = NO;
  _donutChart.showLabel = NO;
  
  [self.view addSubview:_donutChart];
  
  CGFloat width = self.view.frame.size.width - 2*kINKDistanceFromSuperview;
  _donutChart.frame = CGRectMake(kINKDistanceFromSuperview, kINKDistanceFromSuperview, width, width);
}


-(void)addCircle {
  UIView *circle = [UIView new];
  CGRect frame = circle.frame;
  frame.size.height = _donutChart.frame.size.height - KINKDonutChartStrokeLength;
  frame.size.width = frame.size.height;
  circle.frame = frame;
  circle.center = _donutChart.center;
  circle.clipsToBounds = YES;
  circle.layer.cornerRadius = circle.frame.size.height / 2;
  circle.backgroundColor = [UIColor whiteColor];
  [self.view addSubview:circle];
}

-(void)addTotalLabel {
  _totalLabel = [UILabel new];
  _totalLabel.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleHeadline]size:0];
  NSString *text = [Utilities roundedDollarStringFromNumbers:((NSNumber *)self.donutValues[0]).floatValue];
  _totalLabel.text = text;
  

  _totalLabel.textAlignment = NSTextAlignmentCenter;
  _totalLabel.textColor = [UIColor inkPurple];
  _totalLabel.frame = CGRectMake(0, 0, _donutChart.frame.size.width, 100);
  _totalLabel.center = CGPointMake(_donutChart.center.x, _donutChart.center.y - _donutChart.frame.size.height/6);
  
  [self.view addSubview:_totalLabel];
}

-(void)addIndividualLabels {
  _checkingLabel = [UILabel new];
  _checkingLabel.textAlignment = NSTextAlignmentCenter;
  _savingsLabel = [UILabel new];
  _savingsLabel.textAlignment = NSTextAlignmentCenter;
  NSNumber *checkingTop = @(self.donutChart.center.y + 20);
  [AutolayoutHelper configureView:self.view subViews:VarBindings(_checkingLabel, _savingsLabel) metrics: VarBindings(checkingTop) constraints:@[@"H:|-[_checkingLabel]-|", @"H:|-[_savingsLabel]-|", @"V:|-checkingTop-[_checkingLabel]", @"V:[_checkingLabel]-10-[_savingsLabel]"]];
  
    CGFloat checkingVal = ((NSNumber *)self.donutValues[1]).floatValue;
    NSString *baseString = [NSString stringWithFormat:@"What you can spend: %@", [Utilities roundedDollarStringFromNumbers:checkingVal]];
   
    NSMutableAttributedString *checking = [[NSMutableAttributedString alloc] initWithString:baseString];
    
    NSRange range = [baseString rangeOfString:@"What you can spend: "];
    [checking addAttribute:@"NSFontAttributeName" value:[UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleHeadline]size:0] range:NSMakeRange(0, baseString.length)];
    
                            
    [checking addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:range];
    
    [checking addAttribute:NSForegroundColorAttributeName value:[UIColor inkRed] range:NSMakeRange(range.location+range.length, baseString.length-range.length)];
    
    _checkingLabel.attributedText = checking;
  
    CGFloat savingValue = ((NSNumber *)self.donutValues[2]).floatValue;
    NSString *baseStringSavings = [NSString stringWithFormat:@"What you've saved: %@", [Utilities roundedDollarStringFromNumbers:savingValue]];
    
    NSMutableAttributedString *savings = [[NSMutableAttributedString alloc] initWithString:baseStringSavings];
    
    NSRange rangeSavings = [baseStringSavings rangeOfString:@"What you've saved: "];
    
    [savings addAttribute:@"NSFontAttributeName" value:[UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleHeadline]size:0] range:NSMakeRange(0, baseStringSavings.length)];
    
    [savings addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:rangeSavings];
    
    [savings addAttribute:NSForegroundColorAttributeName value:[UIColor inkGreen] range:NSMakeRange(rangeSavings.location+rangeSavings.length, baseStringSavings.length-rangeSavings.length)];
    
    _savingsLabel.attributedText = savings;
  
}



-(NSInteger)numberOfSlicesInDoughnutChart:(XYDoughnutChart *)doughnutChart {
  return self.donutValues.count;
}

-(CGFloat)doughnutChart:(XYDoughnutChart *)doughnutChart valueForSliceAtIndexPath:(NSIndexPath *)indexPath {
  NSNumber *val = self.donutValues[indexPath.slice];
  return val.floatValue;
}

- (UIColor *)doughnutChart:(XYDoughnutChart *)doughnutChart colorForSliceAtIndexPath:(NSIndexPath *)indexPath {
  switch (indexPath.slice) {
      case 0:
        return [UIColor clearColor];
        break;
      case 1:
        return [UIColor inkRed];
      case 2:
        return [UIColor inkGreen];
      default:
        return nil;
        break;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
