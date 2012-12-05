//
//  GoogleOAuth2Client.m
//  OAuthTest
//
//  Created by Conrad Kramer on 12/3/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "AFURLConnectionOperation.h"

#import "GoogleOAuth2Client.h"

static NSString * const GoogleOAuth2BaseURLString = @"https://accounts.google.com/o/oauth2/";

@implementation GoogleOAuth2Client

+ (AFOAuth2Client *)clientWithClientID:(NSString *)clientID secret:(NSString *)secret {
    return [[self alloc] initWithClientID:clientID secret:secret];
}

- (id)initWithClientID:(NSString *)clientID secret:(NSString *)secret {
    self = [super initWithBaseURL:[NSURL URLWithString:GoogleOAuth2BaseURLString] clientID:clientID secret:secret];
    return self;
}

- (void)refreshCredential:(AFOAuthCredential *)credential
                  success:(void (^)(AFOAuthCredential *))success
                  failure:(void (^)(NSError *))failure
{
    [self authenticateUsingOAuthWithRefreshToken:credential.refreshToken success:success failure:failure];
}

- (void)authenticateUsingOAuthWithRefreshToken:(NSString *)refreshToken
                                       success:(void (^)(AFOAuthCredential *))success
                                       failure:(void (^)(NSError *))failure
{
    [super authenticateUsingOAuthWithPath:@"token" refreshToken:refreshToken success:success failure:failure];
}

- (void)authenticateUsingOAuthWithCode:(NSString *)code
                           redirectURI:(NSString *)uri
                               success:(void (^)(AFOAuthCredential *))success
                               failure:(void (^)(NSError *))failure
{
    [super authenticateUsingOAuthWithPath:@"token" code:code redirectURI:uri success:success failure:failure];
}

- (void)authenticateUsingOAuthWithPath:(NSString *)path
                            parameters:(NSDictionary *)parameters
                               success:(void (^)(AFOAuthCredential *credential))success
                               failure:(void (^)(NSError *error))failure
{
    void (^wrappedSuccess)(AFOAuthCredential *) = ^(AFOAuthCredential *credential) {
        NSMutableDictionary *representation = [NSMutableDictionary dictionaryWithObjectsAndKeys:parameters[@"scope"], @"scope", nil];
        [self verifyCredential:credential againstRepresentation:representation success:success failure:failure];
    };

    [super authenticateUsingOAuthWithPath:path parameters:parameters success:wrappedSuccess failure:failure];
}

/*
 * I don't want to be a confused deputy!
 * http://en.wikipedia.org/wiki/Confused_deputy_problem
 */

- (void)verifyCredential:(AFOAuthCredential *)credential
   againstRepresentation:(NSDictionary *)representation
                 success:(void (^)(AFOAuthCredential *))success
                 failure:(void (^)(NSError *))failure
{
    void (^validateBlock)(AFOAuthCredential *) = ^(AFOAuthCredential *credential) {
        NSMutableDictionary *comparisonDict = [NSMutableDictionary dictionaryWithObject:self.clientID forKey:@"audience"];
        [comparisonDict addEntriesFromDictionary:representation];

        NSMutableURLRequest *validationRequest = [self requestWithMethod:@"GET" path:nil parameters:nil];
        NSURL *validationURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=%@", credential.accessToken]];

        [validationRequest setURL:validationURL];
        [validationRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];

        AFHTTPRequestOperation *validationOperation = [self HTTPRequestOperationWithRequest:validationRequest success:^(AFHTTPRequestOperation *operation, id responseObject) {
            __block BOOL equal = YES;
            __block NSString *errorKey = nil;
            [comparisonDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                equal = [responseObject[key] isEqual:obj];
                *stop = !equal;

                errorKey = equal ? nil : key;
            }];

            if (equal && success) {
                success(credential);
            } else {
                NSString *errorDescription = [NSString stringWithFormat:@"Unable to verify credential. The returned value for \"%@\" does not match what was sent.", errorKey];
                NSLog(@"%@", errorDescription);

                if (failure) {
                    NSError *error = [NSError errorWithDomain:AFNetworkingErrorDomain code:NSURLErrorUnknown userInfo:@{ NSLocalizedDescriptionKey : errorDescription }];
                    failure(error);
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (failure) {
                failure(error);
            }
        }];

        [self enqueueHTTPRequestOperation:validationOperation];
    };

    if (self.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        // Automagically succeed if no internet connection is available
        if (success) {
            success(credential);
        }
    } else if (credential.expired) {
        // Automagically refresh token if expired
        [self refreshCredential:credential success:validateBlock failure:failure];
    } else {
        // If token is valid and server is reachable, just go ahead
        validateBlock(credential);
    }
}

@end
