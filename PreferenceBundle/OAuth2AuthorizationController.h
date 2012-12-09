//
//  OAuth2AuthorizationController.h
//  GoogleCloudPrint
//
//  Created by Conrad Kramer on 10/21/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import <Preferences/PSViewController.h>

extern NSString * const OAuth2AuthorizationURLKey;
extern NSString * const OAuth2RedirectURIKey;

@protocol OAuth2AuthorizationDelegate
@required
- (void)receivedAuthorizationCode:(NSString *)code withRedirectURI:(NSURL *)uri;
@end

@interface OAuth2AuthorizationController : PSViewController

@property (weak, nonatomic) id<OAuth2AuthorizationDelegate> delegate;

@end