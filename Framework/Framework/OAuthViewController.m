//
//  OAuthWebViewController.m
//  Framework
//
//  Created by Dan Kalinin on 26/09/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import "OAuthViewController.h"
#import "OAuthClient.h"



@interface OAuthViewController ()

@property OAuthClient *client;

@end



@implementation OAuthViewController

- (void)loadAuthorizationPageForClient:(OAuthClient *)client {
    self.client = client;
    
    NSURLRequest *request = [client authorizationRequest];
    [self.webView loadRequest:request];
}

#pragma mark - Web view

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webView:(UIWebView *)webView didReceiveCredential:(OAuthCredential *)credential withError:(NSError *)error {
    
}

@end
