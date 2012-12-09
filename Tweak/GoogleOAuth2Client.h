//
//  GoogleOAuth2Client.h
//  GoogleCloudPrint
//
//  Created by Conrad Kramer on 10/21/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "AFOAuth2Client.h"

@interface GoogleOAuth2Client : AFOAuth2Client

+ (GoogleOAuth2Client *)clientWithClientID:(NSString *)clientID secret:(NSString *)secret;
- (id)initWithClientID:(NSString *)clientID secret:(NSString *)secret;

- (void)refreshCredential:(AFOAuthCredential *)credential
                  success:(void (^)(AFOAuthCredential *))success
                  failure:(void (^)(NSError *))failure;

- (void)verifyCredential:(AFOAuthCredential *)credential
   againstRepresentation:(NSDictionary *)representation
                 success:(void (^)(AFOAuthCredential *))success
                 failure:(void (^)(NSError *))failure;

- (void)authenticateUsingOAuthWithRefreshToken:(NSString *)refreshToken
                                       success:(void (^)(AFOAuthCredential *))success
                                       failure:(void (^)(NSError *))failure;

- (void)authenticateUsingOAuthWithCode:(NSString *)code
                           redirectURI:(NSString *)uri
                               success:(void (^)(AFOAuthCredential *))success
                               failure:(void (^)(NSError *))failure;

- (NSURL *)authorizationURLWithScope:(NSString *)scope
                         redirectURI:(NSString *)uri;

@end