//
//  SendMoneyViewController.m
//  Ink
//
//  Created by Jason Scharff on 1/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "SendMoneyViewController.h"

#import "AutoLayoutHelper.h"
#import "BottomBorderTextField.h"
#import "SendMoneyStoreController.h"
#import "UIColor+ColorPalette.h"
#import "UIFontDescriptor+AvenirNext.h"

@interface SendMoneyViewController () <UITextFieldDelegate>

@property (nonatomic, strong) BottomBorderTextField *moneyField;

@end

@implementation SendMoneyViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  UILabel *mainText = [UILabel new];
  mainText.textAlignment = NSTextAlignmentCenter;
  UILabel *caption = [UILabel new];
  caption.textAlignment = NSTextAlignmentCenter;
  _moneyField = [[BottomBorderTextField alloc]initWithBorderColor:[UIColor inkGreen] borderWidth:2.0];
  
  _moneyField.placeholder = @"Enter an amount to save.";
  _moneyField.keyboardType = UIKeyboardTypeNumberPad;
  _moneyField.delegate = self;
  _moneyField.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleBody]size:0];
  _moneyField.textAlignment = NSTextAlignmentCenter;
  
  mainText.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18];
  mainText.text = @"Save More Money.";
  caption.text = @"Manually commit to saving more.";
  
  caption.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleBody]size:0];
  
  UIButton *sendButton = [[UIButton alloc]init];
  [sendButton setTitle:@"Save More Money" forState:UIControlStateNormal];
  [sendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  sendButton.layer.borderWidth = 2;
  sendButton.layer.cornerRadius = 8;
  sendButton.contentEdgeInsets= UIEdgeInsetsMake(10, 12, 10, 12);
  sendButton.layer.borderColor = [[UIColor inkGreen]CGColor];
  [sendButton addTarget:self action:@selector(sendButtonClicked:) forControlEvents:UIControlEventTouchDown];
  
  [AutolayoutHelper configureView:self.view subViews:VarBindings(_moneyField, caption, mainText, sendButton) constraints:@[@"V:|-25-[mainText]-[caption]-16-[_moneyField]-20-[sendButton]", @"H:|-12-[_moneyField]-12-|", @"H:|-[mainText]-|", @"H:|-[caption]-|"]];
  
  NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:sendButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
  [self.view addConstraint:constraint];
  
  [_moneyField addTarget:self
                action:@selector(textFieldDidChange:)
      forControlEvents:UIControlEventEditingChanged];
  
  
}

-(void)textFieldDidChange : (UITextField *)textField{
  NSString *text = textField.text;
  if(text.length == 0) {
    return;
  }
  if([text characterAtIndex:0] == '$') {
    return;
  }
  else {
    NSString *appended = [NSString stringWithFormat:@"$%@", text];
    textField.text = appended;
  }
}

-(IBAction)sendButtonClicked:(id)sender {
  [[SendMoneyStoreController sharedSendMoneyStoreController]saveMoney:_moneyField.text];
  _moneyField.text = @"";
  UIAlertController * alert=   [UIAlertController
                              alertControllerWithTitle:@"Congrats on saving money!"
                              message:@"Your saving will go a long way for the future. Keep up the good work!"
                              preferredStyle:UIAlertControllerStyleAlert];
  
  UIAlertAction* dismissButton = [UIAlertAction
                              actionWithTitle:@"Dismiss"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                              }];
  
  [alert addAction:dismissButton];
  
  [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
