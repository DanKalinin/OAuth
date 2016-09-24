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
    
    oauthClient.grantType = OAuthGrantTypeImplicit;
    oauthClient.username = @"papa10";
    oauthClient.password = @"11111111";
    oauthClient.state = @"123";
    
    NSLog(@"request - %@", [oauthClient authorizationRequest]);
    
    // 2 - Token
    
    oauthClient.code = @"YzJkMDVjN2QxYmEyYmY1OGNhZDEyZjZlOThiYTU1MjFlMGVjYTAxMzE1ZjFiOThmMDYyNjIyZmI1ZTNhYjY0ZA";
    [oauthClient getCredential:^(OAuthCredential *credential, NSError *error) {
        [oauthClient refreshCredential:credential completion:^(OAuthCredential *newCredential, NSError *error) {
            
            NSURL *codeURL = [NSURL URLWithString:@"http://client.ios/?state=123&code=ZTIwZDNkY2Y0ZWVmNWVhMjkxOGVlMDYzMTEyY2QzYjNjYjZmYTdlY2JjZTVhMDU4MDFmM2ViZjhmMzM4M2ZlZA"];
            NSString *code = [oauthClient codeWithURL:codeURL];
            NSLog(@"code - %@", code);
            
            NSURL *credentialURL = [NSURL URLWithString:@"http://client.ios/?state=123#access_token=ZGY1NzNlODI0YWFmOThlZDc3NDY0YWY0ZjU4MmFlZjUwZGQwYzMxYWZiMjFhZDI1MDU2ZGIxNzcwYzc3NGVkNA&expires_in=3600&token_type=bearer"];
            OAuthCredential *credential = [oauthClient credentialWithURL:credentialURL];
            NSLog(@"credential - %@", credential);
        }];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    NSLog(@"content - %@", NSMutableURLRequest.baseComponents[@"content"].URL);
//    NSLog(@"fota - %@", NSMutableURLRequest.baseComponents[@"fota"].URL);
}

@end
