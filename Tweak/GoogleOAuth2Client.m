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

- (void)authenticateUsingOAuthWithPath:(NSString *)path
                            parameters:(NSDictionary *)parameters
                               success:(void (^)(AFOAuthCredential *credential))success
                               failure:(void (^)(NSError *error))failure
{
    // I don't want to be a confused deputy!
    // http://en.wikipedia.org/wiki/Confused_deputy_problem

    void (^wrappedSuccess)(AFOAuthCredential *) = ^(AFOAuthCredential *credential) {
        NSMutableURLRequest *validationRequest = [self requestWithMethod:@"GET" path:nil parameters:nil];
        NSURL *validationURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=%@", credential.accessToken]];

        [validationRequest setURL:validationURL];
        [validationRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];

        NSMutableDictionary *comparisonDict = [NSMutableDictionary dictionaryWithObject:self.clientID forKey:@"audience"];
        [comparisonDict setValue:parameters[@"scope"] forKey:@"scope"];

        AFHTTPRequestOperation *validationOperation = [self HTTPRequestOperationWithRequest:validationRequest success:^(AFHTTPRequestOperation *operation, id responseObject) {
            __block BOOL equal = YES;
            __block NSString *errorKey = nil;
            [comparisonDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                equal = [responseObject[key] isEqual:obj];
                *stop = !equal;

                if (*stop) {
                    errorKey = key;
                }
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

    [super authenticateUsingOAuthWithPath:path parameters:parameters success:wrappedSuccess failure:failure];
}

@end
