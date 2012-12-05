//
//  GoogleOAuth2Client.h
//  OAuthTest
//
//  Created by Conrad Kramer on 12/3/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "AFOAuth2Client.h"

@interface GoogleOAuth2Client : AFOAuth2Client

+ (GoogleOAuth2Client *)clientWithClientID:(NSString *)clientID secret:(NSString *)secret;
- (id)initWithClientID:(NSString *)clientID secret:(NSString *)secret;

@end
