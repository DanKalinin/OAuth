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
    
    BOOL load = YES;
    NSURL *URL = request.URL;
    
    if ([URL.absoluteString hasPrefix:self.client.clientEndpoint]) {
        
        load = NO;
        
        if ([self.client.grantType isEqualToString:OAuthGrantTypeAuthorizationCode]) {
            NSError *error = nil;
            NSString *code = [self.client codeWithURL:URL error:&error];
            if (code) {
                self.client.code = code;
                [self.client getCredential:^(OAuthCredential *credential, NSError *error) {
                    [self webView:self.webView didReceiveCredential:credential withError:error];
                }];
            } else {
                [self webView:self.webView didReceiveCredential:nil withError:error];
            }
        } else if ([self.client.grantType isEqualToString:OAuthGrantTypeImplicit]) {
            NSError *error = nil;
            OAuthCredential *credential = [self.client credentialWithURL:URL error:&error];
            [self webView:self.webView didReceiveCredential:credential withError:error];
        }
    }
    
    return load;
}

- (void)webView:(UIWebView *)webView didReceiveCredential:(OAuthCredential *)credential withError:(NSError *)error {
    
}

@end
