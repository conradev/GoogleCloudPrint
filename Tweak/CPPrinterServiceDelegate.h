//
//  CPPrinterServiceDelegate.h
//  GoogleCloudPrint
//
//  Created by Conrad Kramer on 10/21/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CPPrinterServiceDelegate <NSObject>
@optional

- (void)cloudprintServiceInsertedPrinters:(NSSet *)printers;

- (void)cloudprintServiceUpdatedPrinters:(NSSet *)printers;

- (void)cloudprintServiceDeletedPrinters:(NSSet *)printers;

@end
