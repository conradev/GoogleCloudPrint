//
//  OAuth2AuthorizationController.m
//  GoogleCloudPrint
//
//  Created by Conrad Kramer on 10/21/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import <Preferences/PSSetupController.h>

#import "OAuth2AuthorizationController.h"

NSString * const OAuth2AuthorizationURLKey = @"OAuth2AuthorizationURLKey";
NSString * const OAuth2RedirectURIKey = @"OAuth2RedirectURIKey";

// Taken from https://github.com/AFNetworking/AFOAuth1Client/blob/master/AFOAuth1Client.m
static inline NSDictionary * AFParametersFromQueryString(NSString *queryString) {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (queryString) {
        NSScanner *parameterScanner = [[NSScanner alloc] initWithString:queryString];
        NSString *name = nil;
        NSString *value = nil;
        
        while (![parameterScanner isAtEnd]) {
            name = nil;
            [parameterScanner scanUpToString:@"=" intoString:&name];
            [parameterScanner scanString:@"=" intoString:NULL];
            
            value = nil;
            [parameterScanner scanUpToString:@"&" intoString:&value];
            [parameterScanner scanString:@"&" intoString:NULL];
            
            if (name && value) {
                [parameters setValue:[value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:[name stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
        }
    }
    
    return parameters;
}

@interface OAuth2AuthorizationController () <UIWebViewDelegate>
@property (weak, nonatomic) UIWebView *webView;
@property (weak, nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation OAuth2AuthorizationController

- (void)loadView {
    [super loadView];
    
    UIWebView *webView = [[UIWebView alloc] init];
    webView.translatesAutoresizingMaskIntoConstraints = NO;
    webView.delegate = self;
    [self.view addSubview:webView];
    self.webView = webView;
    
    NSDictionary *views = @{ @"webView" : self.webView };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webView]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator = activityIndicator;
    
    self.title = self.specifier.name;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self.parentController action:@selector(dismiss)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];

    [self.webView loadRequest:[NSURLRequest requestWithURL:[self.specifier propertyForKey:OAuth2AuthorizationURLKey]]];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.activityIndicator stopAnimating];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [request URL];
    NSURL *redirectURI = [self.specifier propertyForKey:OAuth2RedirectURIKey];
    NSURL *authorizationURL = [self.specifier propertyForKey:OAuth2AuthorizationURLKey];
        
    if ([[url host] isEqualToString:[redirectURI host]]) {
        NSDictionary *parameters = AFParametersFromQueryString([url query]);
        
        [self.delegate receivedAuthorizationCode:parameters[@"code"] withRedirectURI:redirectURI];
        [(PSSetupController *)self.parentController dismiss];
        
        return NO;
    } else if ([[url host] isEqualToString:[authorizationURL host]]) {
        return YES;
    }
    
    [[UIApplication sharedApplication] openURL:url];
    
    return NO;
}

@end