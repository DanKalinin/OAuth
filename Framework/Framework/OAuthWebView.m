//
//  OAuthWebView.m
//  Framework
//
//  Created by Dan Kalinin on 24/09/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import "OAuthWebView.h"



@interface OAuthWebView () <UIWebViewDelegate>

@end



@implementation OAuthWebView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.delegate = self;
    }
    return self;
}

@end
