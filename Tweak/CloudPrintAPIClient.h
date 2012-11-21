//
//  CloudPrintAPIClient.h
//  GoogleCloudPrint
//
//  Created by Conrad Kramer on 10/21/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "AFRESTClient.h"

@class CPPrinter;

@interface CloudPrintAPIClient : AFRESTClient <AFIncrementalStoreHTTPClient>

+ (CloudPrintAPIClient *)sharedClient;

@end