//
//  OAuthWebView.h
//  Framework
//
//  Created by Dan Kalinin on 24/09/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAuthClient.h"



@interface OAuthWebView : UIWebView

@property OAuthClient *oauthClient;

@end
