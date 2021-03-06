//
//  NSMutableURLRequest+OAuth.m
//  Framework
//
//  Created by Dan Kalinin on 22/09/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import "OAuthClient.h"
#import <Helpers/Helpers.h>
#import <URLTransaction/URLTransaction.h>
#import <JSONSchema/JSONSchema.h>

NSErrorDomain const OAuthErrorDomain = @"OAuthErrorDomain";

NSString *const OAuthGrantTypeAuthorizationCode = @"authorization_code";
NSString *const OAuthGrantTypeImplicit = @"implicit";
NSString *const OAuthGrantTypeResourceOwnerPasswordCredentials = @"password";
NSString *const OAuthGrantTypeClientCredentials = @"client_credentials";

static NSString *const OAuthGrantTypeRefreshToken = @"refresh_token";

static NSString *const OAuthAccessTokenKey = @"access_token";
static NSString *const OAuthTokenTypeKey = @"token_type";
static NSString *const OAuthExpiresInKey = @"expires_in";
static NSString *const OAuthRefreshTokenKey = @"refresh_token";
static NSString *const OAuthCodeKey = @"code";
static NSString *const OAuthStateKey = @"state";
static NSString *const OAuthMacKeyKey = @"mac_key";
static NSString *const OAuthMacAlgorithmKey = @"mac_algorithm";

static NSString *const OAuthErrorKey = @"error";
static NSString *const OAuthErrorDescriptionKey = @"error_description";
static NSString *const OAuthErrorUriKey = @"error_uri";

static NSString *const OAuthResponseType = @"response_type";
static NSString *const OAuthClientId = @"client_id";
static NSString *const OAuthClientSecret = @"client_secret";
static NSString *const OAuthRedirectUri = @"redirect_uri";
static NSString *const OAuthScope = @"scope";
static NSString *const OAuthState = @"state";
static NSString *const OAuthGrantType = @"grant_type";
static NSString *const OAuthCode = @"code";
static NSString *const OAuthUsername = @"username";
static NSString *const OAuthPassword = @"password";
static NSString *const OAuthRefreshToken = @"refresh_token";

static NSString *const OAuthResponseTypeCode = @"code";
static NSString *const OAuthResponseTypeToken = @"token";

static NSString *const OAuthTokenTypeBearer = @"bearer";
static NSString *const OAuthTokenTypeMac = @"mac";

static NSString *const OAuthMathAlgorithmHmacSha1 = @"hmac-sha-1";
static NSString *const OAuthMathAlgorithmHmacSha256 = @"hmac-sha-256";

static NSString *const OAuthErrorsTable = @"Errors";
static NSString *const OAuthStateErrorDescriptionKey = @"invalid_state";

static NSString *const JSONSchemaCode = @"code";
static NSString *const JSONSchemaCredential = @"credential";
static NSString *const JSONSchemaError = @"error";










@interface OAuthCredential () <NSCoding>

@property NSString *accessToken;
@property NSString *tokenType;
@property NSDate *expirationDate;
@property NSString *refreshToken;

@property NSString *macKey;
@property NSString *macAlgorithm;

@end



@implementation OAuthCredential

#pragma mark - Serialization

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.accessToken = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(accessToken))];
        self.tokenType = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(tokenType))];
        self.expirationDate = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(expirationDate))];
        self.refreshToken = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(refreshToken))];
        self.macKey = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(macKey))];
        self.macAlgorithm = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(macAlgorithm))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.accessToken forKey:NSStringFromSelector(@selector(accessToken))];
    [aCoder encodeObject:self.tokenType forKey:NSStringFromSelector(@selector(tokenType))];
    [aCoder encodeObject:self.expirationDate forKey:NSStringFromSelector(@selector(expirationDate))];
    [aCoder encodeObject:self.refreshToken forKey:NSStringFromSelector(@selector(refreshToken))];
    [aCoder encodeObject:self.macKey forKey:NSStringFromSelector(@selector(macKey))];
    [aCoder encodeObject:self.macAlgorithm forKey:NSStringFromSelector(@selector(macAlgorithm))];
}

#pragma mark - Accessors

- (BOOL)expired {
    BOOL expired = [self.expirationDate timeIntervalSinceNow] <= 0.0;
    return expired;
}

- (NSString *)description {
    NSString *accessToken = [NSString stringWithFormat:@"%@ - %@", OAuthAccessTokenKey, self.accessToken];
    NSString *tokenType = [NSString stringWithFormat:@"%@ - %@", OAuthTokenTypeKey, self.tokenType];
    NSString *expiresIn = [NSString stringWithFormat:@"%@ - %f", OAuthExpiresInKey, [self.expirationDate timeIntervalSinceNow]];
    NSString *refreshToken = [NSString stringWithFormat:@"%@ - %@", OAuthRefreshTokenKey, self.refreshToken];
    NSString *macKey = [NSString stringWithFormat:@"%@ - %@", OAuthMacKeyKey, self.macKey];
    NSString *macAlgorithm = [NSString stringWithFormat:@"%@ - %@", OAuthMacAlgorithmKey, self.macAlgorithm];
    
    NSArray *descriptions = @[accessToken, tokenType, expiresIn, refreshToken, macKey, macAlgorithm];
    NSString *description = [descriptions componentsJoinedByString:@"\n"];
    
    return description;
}

#pragma mark - Keychain

- (void)exportToKeychain:(NSString *)account {
    NSData *credential = [NSKeyedArchiver archivedDataWithRootObject:self];
    
    Keychain *keychain = [Keychain new];
    keychain.service = NSStringFromClass([self class]);
    keychain.account = account;
    keychain.credential = credential;
}

+ (instancetype)importFromKeychain:(NSString *)account {
    Keychain *keychain = [Keychain new];
    keychain.service = NSStringFromClass(self);
    keychain.account = account;
    
    NSData *data = keychain.credential;
    OAuthCredential *credential = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return credential;
}

@end










@implementation NSMutableURLRequest (OAuth)

- (void)setOAuthCredential:(OAuthCredential *)credential {
    
    NSString *value;
    
    if ([credential.tokenType.lowercaseString isEqualToString:OAuthTokenTypeBearer]) {
        value = [NSString stringWithFormat:@"%@ %@", credential.tokenType.capitalizedString, credential.accessToken];
    } else if ([credential.tokenType.lowercaseString isEqualToString:OAuthTokenTypeMac]) {
        // TODO: mac token type
        if ([credential.macAlgorithm isEqualToString:OAuthMathAlgorithmHmacSha1]) {
            
        } else if ([credential.macAlgorithm isEqualToString:OAuthMathAlgorithmHmacSha256]) {
            
        }
    }
    
    [self setValue:value forHTTPHeaderField:@"Authorization"];
}

@end










@interface OAuthClient ()

@property NSURLComponents *authorizationServerBaseComponents;
@property NSString *clientId;
@property NSString *clientSecret;

@property NSString *responseType;
@property BOOL authorize;
@property BOOL refresh;

@property NSString *refreshToken;

@property NSError *stateError;

@end



@implementation OAuthClient

- (instancetype)initWithAuthorizationServerBaseComponents:(NSURLComponents *)authorizationServerBaseComponents clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret {
    self = [super init];
    if (self) {
        self.authorizationServerBaseComponents = authorizationServerBaseComponents;
        self.clientId = clientId;
        self.clientSecret = clientSecret;
        
        self.authorizationEndpoint = @"/authorize";
        self.tokenEndpoint = @"/token";
        self.clientEndpoint = @"http://client.com";
        
        self.grantType = OAuthGrantTypeAuthorizationCode;
        
        NSString *description = [self.bundle localizedStringForKey:OAuthStateErrorDescriptionKey value:OAuthStateErrorDescriptionKey table:OAuthErrorsTable];
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[NSLocalizedDescriptionKey] = description;
        self.stateError = [NSError errorWithDomain:OAuthErrorDomain code:0 userInfo:userInfo];
    }
    return self;
}

- (NSURLRequest *)authorizationRequest {
    
    if (![self.grantType isEqualToString:OAuthGrantTypeAuthorizationCode] && ![self.grantType isEqualToString:OAuthGrantTypeImplicit]) return nil;
    
    self.refresh = NO;
    self.authorize = YES;
    self.responseType = [self.grantType isEqualToString:OAuthGrantTypeAuthorizationCode] ? OAuthResponseTypeCode : OAuthResponseTypeToken;
    
    NSURLComponents *components = self.authorizationServerBaseComponents.copy;
    components.path = self.authorizationEndpoint;
    components.queryItems = [self queryItems];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:components.URL];
    return request;
}

- (void)getCredential:(OAuthRequestHandler)completion {
    self.refresh = NO;
    self.authorize = NO;
    
    NSURLRequest *request = [self credentialRequest:completion];
    [request resume];
}

- (void)refreshCredential:(OAuthCredential *)oldCredential completion:(OAuthRequestHandler)completion {
    self.refresh = YES;
    self.authorize = NO;
    self.refreshToken = oldCredential.refreshToken;
    
    NSString *grantType = self.grantType;
    self.grantType = OAuthGrantTypeRefreshToken;
    NSURLRequest *request = [self credentialRequest:completion];
    self.grantType = grantType;
    [request resume];
}

- (NSString *)codeWithURL:(NSURL *)URL error:(NSError **)error {
    NSURLComponents *components = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
    
    NSDictionary *dictionary = [self dictionaryWithQueryItems:components.queryItems];
    NSString *state = dictionary[OAuthStateKey];
    NSString *code;
    if ((state == nil && self.state == nil) || [state isEqualToString:self.state]) {
        code = [self codeWithDictionary:dictionary error:error];
    } else {
        code = nil;
        *error = self.stateError;
    }
    
    return code;
}

- (OAuthCredential *)credentialWithURL:(NSURL *)URL error:(NSError **)error {
    NSURLComponents *components = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
    
    NSDictionary *dictionary = [self dictionaryWithQueryItems:components.queryItems];
    NSString *state = dictionary[OAuthStateKey];
    OAuthCredential *credential;
    if ((state == nil && self.state == nil) || [state isEqualToString:self.state]) {
        components.query = components.fragment;
        dictionary = [self dictionaryWithQueryItems:components.queryItems];
        credential = [self credentialWithDictionary:dictionary error:error];
    } else {
        credential = nil;
        *error = self.stateError;
    }
    
    return credential;
}

#pragma mark - Helpers

- (NSURLRequest *)credentialRequest:(OAuthRequestHandler)completion {
    
    NSURLComponents *components = self.authorizationServerBaseComponents.copy;
    components.path = self.tokenEndpoint;
    
    NSURLComponents *queryComponents = [NSURLComponents new];
    queryComponents.queryItems = [self queryItems];
    NSString *queryString = queryComponents.percentEncodedQuery;
    NSData *queryData = [queryString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:components.URL];
    request.HTTPMethod = HTTPMethodPost;
    [request setValue:MediaTypeApplicationForm forHTTPHeaderField:HTTPHeaderFieldContentType];
    request.HTTPBody = queryData;
    
    if (self.authenticationScheme == OAuthAuthenticationSchemeHTTPBasic) {
        NSString *credential = [NSString stringWithFormat:@"%@:%@", self.clientId, self.clientSecret];
        NSData *credentialData = [credential dataUsingEncoding:NSUTF8StringEncoding];
        NSString *encodedCredential = [credentialData base64EncodedStringWithOptions:0];
        
        NSString *value = [NSString stringWithFormat:@"Basic %@", encodedCredential];
        [request setValue:value forHTTPHeaderField:HTTPHeaderFieldAuthorization];
    }
    
    [[request success:^(NSURLRequest *request) {
        NSError *error = nil;
        NSDictionary *dictionary = request.json;
        OAuthCredential *credential = [self credentialWithDictionary:dictionary error:&error];
        [self invokeHandler:completion credential:credential error:error];
    }] failure:^(NSURLRequest *request) {
        NSError *error = nil;
        if ([request.error.domain isEqualToString:HTTPErrorDomain]) {
            NSDictionary *dictionary = request.json;
            error = [self errorWithDictionary:dictionary underlyingError:request.error error:nil];
            error = error ? error : request.error;
        } else {
            error = request.error;
        }
        [self invokeHandler:completion credential:nil error:error];
    }];
    
    return request;
}

- (NSArray<NSURLQueryItem *> *)queryItems {
    NSMutableArray *queryItems = [NSMutableArray array];
    
    NSURLQueryItem *responseTypeItem = [NSURLQueryItem queryItemWithName:OAuthResponseType value:self.responseType];
    NSURLQueryItem *clientIdItem = [NSURLQueryItem queryItemWithName:OAuthClientId value:self.clientId];
    NSURLQueryItem *clientSecretItem = [NSURLQueryItem queryItemWithName:OAuthClientSecret value:self.clientSecret];
    NSURLQueryItem *redirectUriItem = [NSURLQueryItem queryItemWithName:OAuthRedirectUri value:self.clientEndpoint];
    NSURLQueryItem *scopeItem = [NSURLQueryItem queryItemWithName:OAuthScope value:self.scope];
    NSURLQueryItem *stateItem = [NSURLQueryItem queryItemWithName:OAuthState value:self.state];
    NSURLQueryItem *codeItem = [NSURLQueryItem queryItemWithName:OAuthCode value:self.code];
    NSURLQueryItem *grantTypeItem = [NSURLQueryItem queryItemWithName:OAuthGrantType value:self.grantType];
    NSURLQueryItem *refreshTokenItem = [NSURLQueryItem queryItemWithName:OAuthRefreshToken value:self.refreshToken];
    NSURLQueryItem *usernameItem = [NSURLQueryItem queryItemWithName:OAuthUsername value:self.username];
    NSURLQueryItem *passwordItem = [NSURLQueryItem queryItemWithName:OAuthPassword value:self.password];
    
    [queryItems addObject:responseTypeItem];
    [queryItems addObject:clientIdItem];
    [queryItems addObject:clientSecretItem];
    [queryItems addObject:redirectUriItem];
    [queryItems addObject:scopeItem];
    [queryItems addObject:stateItem];
    [queryItems addObject:codeItem];
    [queryItems addObject:grantTypeItem];
    [queryItems addObject:refreshTokenItem];
    [queryItems addObject:usernameItem];
    [queryItems addObject:passwordItem];
    
    NSMutableArray *names;
    if (self.refresh) {
        names = @[OAuthGrantType, OAuthRefreshToken, OAuthScope].mutableCopy;
    } else {
        if ([self.grantType isEqualToString:OAuthGrantTypeAuthorizationCode]) {
            if (self.authorize) {
                names = @[OAuthResponseType, OAuthClientId, OAuthRedirectUri, OAuthScope, OAuthState].mutableCopy;
            } else {
                names = @[OAuthGrantType, OAuthCode, OAuthRedirectUri].mutableCopy;
            }
        } else if ([self.grantType isEqualToString:OAuthGrantTypeImplicit]) {
            names = @[OAuthResponseType, OAuthClientId, OAuthRedirectUri, OAuthScope, OAuthState].mutableCopy;
        } else if ([self.grantType isEqualToString:OAuthGrantTypeResourceOwnerPasswordCredentials]) {
            if (self.authorize) {
                names = @[].mutableCopy;
            } else {
                names = @[OAuthGrantType, OAuthUsername, OAuthPassword, OAuthScope].mutableCopy;
            }
        } else if ([self.grantType isEqualToString:OAuthGrantTypeClientCredentials]) {
            names = @[OAuthGrantType, OAuthScope].mutableCopy;
        } else {
            names = @[].mutableCopy;
        }
    }
    
    if (!self.authorize) {
        if (self.authenticationScheme == OAuthAuthenticationSchemeDefault) {
            [names addObject:OAuthClientId];
            [names addObject:OAuthClientSecret];
        }
    }
    
    NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"name IN %@", names];
    NSPredicate *valuePredicate = [NSPredicate predicateWithFormat:@"value != nil"];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[namePredicate, valuePredicate]];
    
    [queryItems filterUsingPredicate:predicate];
    
    return queryItems;
}

- (void)invokeHandler:(OAuthRequestHandler)handler credential:(OAuthCredential *)credential error:(NSError *)error {
    if (handler) {
        handler(credential, error);
    }
}

- (NSString *)codeWithDictionary:(NSDictionary *)dictionary error:(NSError **)anError {
    
    JSONSchema *schema = [OAuthClient JSONSchemaNamed:JSONSchemaCode];
    BOOL valid = [schema validateObject:dictionary error:anError];
    if (!valid) return nil;
    
    NSString *code = dictionary[OAuthCodeKey];
    return code;
}

- (OAuthCredential *)credentialWithDictionary:(NSDictionary *)dictionary error:(NSError **)anError {
    
    JSONSchema *schema = [OAuthClient JSONSchemaNamed:JSONSchemaCredential];
    BOOL valid = [schema validateObject:dictionary error:anError];
    if (!valid) return nil;
    
    OAuthCredential *credential = [OAuthCredential new];
    
    credential.accessToken = dictionary[OAuthAccessTokenKey];
    credential.tokenType = dictionary[OAuthTokenTypeKey];
    credential.refreshToken = dictionary[OAuthRefreshTokenKey];
    credential.macKey = dictionary[OAuthMacKeyKey];
    credential.macAlgorithm = dictionary[OAuthMacAlgorithmKey];
    
    credential.expirationDate = [NSDate distantFuture];
    NSNumber *expiresIn = dictionary[OAuthExpiresInKey];
    if (expiresIn && expiresIn.doubleValue > 0.0) {
        credential.expirationDate = [NSDate dateWithTimeIntervalSinceNow:expiresIn.doubleValue];
    }
    
    return credential;
}

- (NSError *)errorWithDictionary:(NSDictionary *)dictionary underlyingError:(NSError *)underlyingError error:(NSError **)anError {
    
    JSONSchema *schema = [OAuthClient JSONSchemaNamed:JSONSchemaError];
    BOOL valid = [schema validateObject:dictionary error:anError];
    if (!valid) return nil;
    
    NSString *key = dictionary[OAuthErrorKey];
    NSString *description = dictionary[OAuthErrorDescriptionKey];
    NSString *uri = dictionary[OAuthErrorUriKey];
    
    if (!description) {
        description = [self.bundle localizedStringForKey:key value:key table:OAuthErrorsTable];
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NSLocalizedDescriptionKey] = description;
    userInfo[NSURLErrorKey] = [NSURL URLWithString:uri];
    userInfo[NSUnderlyingErrorKey] = underlyingError;
    
    NSError *error = [NSError errorWithDomain:OAuthErrorDomain code:0 userInfo:userInfo];
    return error;
}

- (NSDictionary *)dictionaryWithQueryItems:(NSArray<NSURLQueryItem *> *)queryItems {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (NSURLQueryItem *queryItem in queryItems) {
        dictionary[queryItem.name] = queryItem.value;
    }
    return dictionary;
}

@end
