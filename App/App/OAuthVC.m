//
//  OAuthVC.m
//  App
//
//  Created by Dan Kalinin on 26/09/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import "OAuthVC.h"
#import <OAuth/OAuth.h>



@interface OAuthVC ()

@end



@implementation OAuthVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURLComponents *components = [NSURLComponents new];
    components.scheme = @"https";
    components.host = @"content.readyforsky.com";
    
    OAuthClient *client = [[OAuthClient alloc] initWithAuthorizationServerBaseComponents:components clientId:@"r4s" clientSecret:@"123"];
    
    client.authorizationEndpoint = @"/oauth/v2/auth";
    client.tokenEndpoint = @"/oauth/v2/token";
    client.clientEndpoint = @"http://client.ios";
    
    [self loadAuthorizationPageForClient:client];
}

@end
