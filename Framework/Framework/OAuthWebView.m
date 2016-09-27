//
//  OAuthWebView.m
//  Framework
//
//  Created by Dan Kalinin on 24/09/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

//#import "OAuthWebView.h"
//#import <Helpers/Helpers.h>
//
//
//
//@interface OAuthWebView () <OAuthWebViewDelegate>
//
//@property SurrogateContainer *delegateContainer;
//
//@end
//
//
//
//@implementation OAuthWebView
//
//@dynamic delegate;
//
//- (instancetype)initWithCoder:(NSCoder *)aDecoder {
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//        self.delegateContainer = [SurrogateContainer new];
//        self.delegate = self;
//    }
//    return self;
//}
//
//- (void)setDelegate:(id<OAuthWebViewDelegate>)delegate {
//    NSMutableArray *objects = [NSMutableArray array];
//    [objects addObject:self];
//    if (delegate && ![delegate isEqual:self]) {
//        [objects addObject:delegate];
//    }
//    self.delegateContainer.objects = objects;
//    [super setDelegate:(id)self.delegateContainer];
//}
//
//- (void)loadAuthorizationPageForClient:(OAuthClient *)client {
//    NSURLRequest *request = [client authorizationRequest];
//    [self loadRequest:request];
//}
//
//#pragma mark - Web view delegate
//
//- (void)webViewDidStartLoad:(UIWebView *)webView {
//    
//}
//
////- (void)load {
////    NSMethodSignature *signature = [NSMethodSignature methodSignatureForSelector:@selector(load)];
////    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
////    
////    // @encode(BOOL) - compiler directive -> string representing the type in runtime
////    
////    // - containsString:
////    // c - BOOL         return type
////    // @ - id           receiver        self
////    // : - SEL          selector        _cmd
////    // @ - NSString *   argument
////    
////    // const char *rt = [signature methodReturnType];
////    // NSUInteger rl = [signature methodReturnLength];
////    
////    // const char *at0 = [signature getArgumentTypeAtIndex:0];
////    // NSUInteger an = [signature numberOfArguments];
////    
////    
////    // isa - class pointer
////    // SEL : IMP - dispatch table
////}
////
////- (void)forwardInvocation:(NSInvocation *)anInvocation {
////    
////}
////
////- (void)doesNotRecognizeSelector:(SEL)aSelector {
////    
////}
////
////+ (BOOL)resolveInstanceMethod:(SEL)sel {
////    // @dynamic
////    return YES;
////}
//
//@end
