//
//  NSMutableURLRequest+OAuth.h
//  Framework
//
//  Created by Dan Kalinin on 22/09/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const OAuthGrantTypeAuthorizationCode;
extern NSString *const OAuthGrantTypeImplicit;
extern NSString *const OAuthGrantTypeResourceOwnerPasswordCredentials;
extern NSString *const OAuthGrantTypeClientCredentials;










@interface OAuthCredential : NSObject

@property (readonly) NSString *accessToken;
@property (readonly) NSString *tokenType;
@property (readonly) NSDate *expirationDate;
@property (readonly) NSString *refreshToken;

- (BOOL)expired;

- (void)exportToKeychain:(NSString *)account;
+ (instancetype)importFromKeychain:(NSString *)account;

@end










@interface OAuthClient : NSObject

- (instancetype)initWithAuthorizationServerBaseComponents:(NSURLComponents *)authorizationServerBaseComponents clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret;
@property (readonly) NSURLComponents *authorizationServerBaseComponents;
@property (readonly) NSString *clientId;
@property (readonly) NSString *clientSecret;

@property NSString *authorizationEndpoint;
@property NSString *tokenEndpoint;
@property NSString *clientEndpoint;

@property NSString *grantType;
@property NSString *scope;
@property NSString *state;
@property NSString *code;

- (NSURLRequest *)authorizationCodeRequest;
- (void)getCredential:(void (^)(OAuthCredential *credential, NSError *error))completion;
- (void)refreshCredential:(OAuthCredential *)oldCredential completion:(void (^)(OAuthCredential *newCredential, NSError *error))completion;

@end


//NS_ASSUME_NONNULL_BEGIN
//
//@interface NSMutableURLRequest (OAuth)
//
//#pragma mark - Authorization code grant
//
//+ (instancetype)authorizationCodeRequest:(NSString *)responseType clientId:(NSString *)clientId redirectUri:(nullable NSString *)redirectUri scope:(nullable NSString *)scope state:(nullable NSString *)state;
//+ (instancetype)accessTokenRequest:(NSString *)grantType code:(NSString *)code redirectUri:(NSString *)redirectUri clientId:(NSString *)clientId;
//
//#pragma mark - Implicit grant
//
//+ (instancetype)accessTokenRequest:(NSString *)responseType clientId:(NSString *)clientId redirectUri:(nullable NSString *)redirectUri scope:(nullable NSString *)scope state:(nullable NSString *)state;
//
//#pragma mark - Resource owner password credentials grant
//
//+ (instancetype)accessTokenRequest:(NSString *)grantType username:(NSString *)userName password:(NSString *)password scope:(nullable NSString *)scope;
//
//#pragma mark - Client credentials grant
//
//+ (instancetype)accessTokenRequest:(NSString *)grantType scope:(nullable NSString *)scope;
//
//#pragma mark - Refresh access token
//
//+ (instancetype)accessTokenRequest:(NSString *)grantType refreshToken:(NSString *)refreshToken scope:(nullable NSString *)scope;
//
//@end
//
//
////@interface OAuthClient : NSObject
////
////@property NSString *grantType;
////@property NSString *clientId;
////@property NSString *redirectUri;
////@property NSString *userName;
////@property NSString *password;
////@property NSString *scope;
////
////@end
//
//NS_ASSUME_NONNULL_END
