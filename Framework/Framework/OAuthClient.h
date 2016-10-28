//
//  NSMutableURLRequest+OAuth.h
//  Framework
//
//  Created by Dan Kalinin on 22/09/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSErrorDomain const OAuthErrorDomain;

extern NSString *const OAuthGrantTypeAuthorizationCode;
extern NSString *const OAuthGrantTypeImplicit;
extern NSString *const OAuthGrantTypeResourceOwnerPasswordCredentials;
extern NSString *const OAuthGrantTypeClientCredentials;

typedef NS_ENUM(NSInteger, OAuthAuthenticationScheme) {
    OAuthAuthenticationSchemeDefault,
    OAuthAuthenticationSchemeHTTPBasic,
    OAuthAuthenticationSchemeNone
};










@interface OAuthCredential : NSObject

@property (readonly) NSString *accessToken;
@property (readonly) NSString *tokenType;
@property (readonly) NSDate *expirationDate;
@property (readonly) NSString *refreshToken;
@property (readonly) NSString *macKey;
@property (readonly) NSString *macAlgorithm;

- (BOOL)expired;

- (void)exportToKeychain:(NSString *)account;
+ (instancetype)importFromKeychain:(NSString *)account;

@end










@interface NSMutableURLRequest (OAuth)

- (void)setOAuthCredential:(OAuthCredential *)credential;

@end










@interface OAuthClient : NSObject

typedef void (^OAuthRequestHandler)(OAuthCredential *credential, NSError *error);

- (instancetype)initWithAuthorizationServerBaseComponents:(NSURLComponents *)authorizationServerBaseComponents clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret;
@property (readonly) NSURLComponents *authorizationServerBaseComponents;
@property (readonly) NSString *clientId;
@property (readonly) NSString *clientSecret;

@property OAuthAuthenticationScheme authenticationScheme;

@property NSString *authorizationEndpoint;
@property NSString *tokenEndpoint;
@property NSString *clientEndpoint;

@property NSString *grantType;
@property NSString *scope;
@property NSString *state;
@property NSString *code;
@property NSString *username;
@property NSString *password;

- (NSURLRequest *)authorizationRequest;
- (void)getCredential:(OAuthRequestHandler)completion;
- (void)refreshCredential:(OAuthCredential *)oldCredential completion:(OAuthRequestHandler)completion;

- (NSString *)codeWithURL:(NSURL *)URL error:(NSError **)error;
- (OAuthCredential *)credentialWithURL:(NSURL *)URL error:(NSError **)error;

@end
