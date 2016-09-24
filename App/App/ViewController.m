//
//  ViewController.m
//  App
//
//  Created by Dan Kalinin on 21/09/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import "ViewController.h"
#import <URLTransaction/URLTransaction.h>
#import <OAuth/OAuth.h>



@interface ViewController ()

@end



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSURLComponents *baseComponents = [NSURLComponents new];
//    baseComponents.scheme = @"https";
//    baseComponents.host = @"content.stage.readyforsky.com";
//    
//    NSURLRequest.baseComponents[@"content"] = baseComponents;
    
    // Configuration
    
    NSURLComponents *baseComponents = [NSURLComponents new];
    baseComponents.scheme = @"https";
    baseComponents.host = @"content.readyforsky.com";
    
    OAuthClient *oauthClient = [[OAuthClient alloc] initWithAuthorizationServerBaseComponents:baseComponents clientId:@"r4s" clientSecret:@"123"];
    oauthClient.authenticationScheme = OAuthAuthenticationSchemeHTTPBasic;
    
    oauthClient.authorizationEndpoint = @"/oauth/v2/auth";
    oauthClient.tokenEndpoint = @"/oauth/v2/token";
    oauthClient.clientEndpoint = @"http://client.ios";
    
    // 1 - Authorization
    
    oauthClient.grantType = OAuthGrantTypeClientCredentials;
    oauthClient.state = @"123";
    
//    NSLog(@"request - %@", [oauthClient authorizationCodeRequest]);
    
    // 2 - Token
    
    oauthClient.code = @"NTIwNDUyZTkwMDVkMjRjMDJiYTE4NTQ4MjNiZmI1MzVhNGQ2MGQ2YTJhZmRhNjgxN2ZiYjY5ZTA0MTQ1YjQ4OA";
    [oauthClient getCredential:^(OAuthCredential *credential, NSError *error) {
        
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    NSLog(@"content - %@", NSMutableURLRequest.baseComponents[@"content"].URL);
//    NSLog(@"fota - %@", NSMutableURLRequest.baseComponents[@"fota"].URL);
}

@end
