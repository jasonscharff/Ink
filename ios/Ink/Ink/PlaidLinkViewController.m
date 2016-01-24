//
//  PlaidLinkViewController.m
//  Ink
//
//  Created by Jason Scharff on 1/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "PlaidLinkViewController.h"

#import "AppDelegate.h"
#import "LoginStoreController.h"


@interface PlaidLinkViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation PlaidLinkViewController

-(void)viewWillAppear:(BOOL)animated {
  self.navigationController.navigationBar.topItem.title = @"Ink";
}

- (void)viewDidLoad {
  [super viewDidLoad];
  _webView = [[UIWebView alloc]init];
  _webView.frame = self.view.frame;
  _webView.delegate = self;
  [self.view addSubview:_webView];
  NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
  NSError *error = NULL;
  NSString *html = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:&error];
  if(!error) {
    NSURL *baseURL = [NSURL fileURLWithPath:htmlFile];
    [_webView loadHTMLString:html baseURL:baseURL];
  }
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
   NSString *actionType = request.URL.host;
  if ([actionType isEqualToString:@"handlePublicToken"]) {
    [[LoginStoreController sharedLoginStoreController]sendPlaidToken:request.URL.fragment];
    [self moveToMainView];
  }
  return YES;
}

-(void)moveToMainView {
  AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  [appDelegate createTabBarController];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
