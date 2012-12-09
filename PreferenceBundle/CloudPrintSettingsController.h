//
//  CloudPrintSettingsController.h
//  GoogleCloudPrint
//
//  Created by Conrad Kramer on 10/21/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import <Preferences/PSListController.h>

#import "OAuth2AuthorizationController.h"

@interface CloudPrintSettingsController : PSListController <OAuth2AuthorizationDelegate>

@end
