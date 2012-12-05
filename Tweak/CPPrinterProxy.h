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

@property (retain, nonatomic) NSString *cloudprintID;

- (id)initWithPrinter:(CPPrinter *)printer;

@end