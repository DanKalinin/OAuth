//
//  OAuthWebViewController.h
//  Framework
//
//  Created by Dan Kalinin on 26/09/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAuthClient.h"



@interface OAuthViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (void)loadAuthorizationPageForClient:(OAuthClient *)client;
- (void)webView:(UIWebView *)webView didReceiveCredential:(OAuthCredential *)credential withError:(NSError *)error;

@end
