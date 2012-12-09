//
//  CloudPrintSettingsController.m
//  GoogleCloudPrint
//
//  Created by Conrad Kramer on 10/21/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import <Foundation/NSXPCConnection.h>

#import "CloudPrintSettingsController.h"

#import "CloudPrintXPCBridge.h"
#import "OAuth2AuthorizationSetup.h"

@interface CloudPrintSettingsController ()
@property (strong, nonatomic) NSXPCConnection *authConnection;
@end

@implementation CloudPrintSettingsController

- (id)init {
    if ((self = [super init])) {
        NSXPCConnection *authConnection = [[NSXPCConnection alloc] initWithMachServiceName:@"org.thebigboss.cpconnector.authorization" options:0x0];
        authConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(CPAuthenticationService)];
        [authConnection resume];
        
        self.authConnection = authConnection;
    }
    
    return self;
}

- (void)dealloc {
    [self.authConnection invalidate];
}

- (void)setSpecifier:(PSSpecifier *)specifier {
    [specifier setTarget:self]; // Figure out why I need to do this
    [super setSpecifier:specifier];
}

- (void)authenticateUsingOAuth:(PSSpecifier *)buttonSpecifier {
    NSURL *uri = [NSURL URLWithString:@"http://localhost/"];
    
    // Fetch authorization URL
    id<CPAuthenticationService> authService = [self.authConnection remoteObjectProxy];
    [authService authorizationURLWithRedirectURI:[uri absoluteString] reply:^(NSURL *url) {
        
        // Create OAuth2 authorization specifier
        PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"Authorization" target:self set:nil get:nil detail:[OAuth2AuthorizationSetup class] cell:[PSTableCell cellTypeFromString:@"PSLinkCell"] edit:nil];
        [specifier setProperty:NSStringFromClass([OAuth2AuthorizationController class]) forKey:PSSetupCustomClassKey];
        [specifier setProperty:url forKey:OAuth2AuthorizationURLKey];
        [specifier setProperty:uri forKey:OAuth2RedirectURIKey];

        // Display the controller on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            OAuth2AuthorizationSetup *setupController = [self controllerForSpecifier:specifier];

            [self pushController:setupController];
            
            OAuth2AuthorizationController *viewController = (OAuth2AuthorizationController *)[setupController topViewController];
            viewController.delegate = self;
        });
    }];
}

- (void)receivedAuthorizationCode:(NSString *)code withRedirectURI:(NSURL *)uri {
    id<CPAuthenticationService> authService = [self.authConnection remoteObjectProxy];
    [authService authenticateWithCode:code redirectURI:[uri absoluteString] reply:^(BOOL success, NSError *error) {
        // Update UI
    }];
}

- (void)deleteCredential:(PSSpecifier *)specifier {
    id<CPAuthenticationService> authService = [self.authConnection remoteObjectProxy];
    [authService deleteCredential];
    
    // Update UI
}

@end