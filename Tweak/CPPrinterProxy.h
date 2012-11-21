//
//  CPPrinterProxy.h
//  GoogleCloudPrint
//
//  Created by Conrad Kramer on 10/21/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import <PrintKit/PKPrinter.h>

@class CPPrinter;

@interface CPPrinterProxy : PKPrinter <NSSecureCoding>

@property (retain, nonatomic, getter=__cloudprint_identifier, setter=__cloudprint_set_identifier:) NSString *cloudprintID;

+ (BOOL)supportsSecureCoding;

- (id)initWithPrinter:(CPPrinter *)printer;

@end