//
//  CPPrinterProxy.m
//  GoogleCloudPrint
//
//  Created by Conrad Kramer on 10/21/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import <PrintKit/PKPrinter.h>
#import <PrintKit/PKPrintSettings.h>

#import "CPPrinter.h"
#import "CPPrinterProxy.h"

/*
 *  NOTE: This file is included by both the ARC-ified XPC service, and the non-ARC tweak. Because Theos
 *  does not allow for per-file flags, this code must support both ARC and no ARC, conditionally.
 */

@interface CPPrinterProxy (Internal)
@property (retain, nonatomic) NSString *cloudprintDisplayName;
@property (retain, nonatomic) NSString *cloudprintDescription;
@end

@implementation CPPrinterProxy

- (id)initWithPrinter:(CPPrinter *)printer {
    if ((self = [self initWithName:printer.name TXTRecord:nil])) {
        self.cloudprintID = printer.printerID;
        self.cloudprintDisplayName = printer.displayName;
        self.cloudprintDescription = printer.printerDescription;
    }

    return self;
}

- (void)dealloc {
#if ! __has_feature(objc_arc)
    self.cloudprintID = nil;
    self.cloudprintDisplayName = nil;
    self.cloudprintDescription = nil;
    [super dealloc];
#endif
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSString *decodedName = [decoder decodeObjectOfClass:[NSString class] forKey:@"name"];
    if ((self = [self initWithName:decodedName TXTRecord:nil])) {
        self.cloudprintDisplayName = [decoder decodeObjectOfClass:[NSString class] forKey:@"displayName"];
        self.cloudprintDescription = [decoder decodeObjectOfClass:[NSString class] forKey:@"cloudprintDescription"];
        self.cloudprintID = [decoder decodeObjectOfClass:[NSString class] forKey:@"cloudprintID"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.cloudprintDisplayName forKey:@"displayName"];
    [encoder encodeObject:self.cloudprintDescription forKey:@"cloudprintDescription"];
    [encoder encodeObject:self.cloudprintID forKey:@"cloudprintID"];
}

#pragma mark - Overridden property values

- (NSString *)displayName {
    return self.cloudprintDisplayName;
}

- (id)location {
    return self.cloudprintDescription;
}

- (BOOL)hasPrintInfoSupported {
    return YES;
}

- (NSDictionary *)printInfoSupported {
    NSMutableDictionary *orig = [NSMutableDictionary dictionaryWithDictionary:[super printInfoSupported]];
    orig[PKFileTypeKey] = @[ PKFileTypePDF, PKFileTypeJPEG, PKFileTypePNG ];
    return [NSDictionary dictionaryWithDictionary:orig];
}

#pragma mark - Print compatibility

- (NSString *)localName {
    // Name as identified by printd, or, rather, CUPS.
    // The super implementation tries to add the printer to CUPS if it has not already been added
    // We don't want this

    return nil;
}

- (int)printURL:(NSURL *)url ofType:(NSString *)contentType printSettings:(PKPrintSettings *)printSettings { 
    NSData *fileData = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:nil];
    NSLog(@"I have a URL-based job! %@ %@ %@", fileData, contentType, printSettings.dict);

    return 0; // Zero indicates success
}

- (int)startJob:(PKPrintSettings *)printSettings ofType:(NSString *)contentType {
    NSLog(@"I have a job! %@ %@", contentType, printSettings.dict);

    return 0;
}

- (int)sendData:(const char *)bytes ofLength:(int)length {
    //NSData *data = [NSData dataWithBytes:bytes length:length]; // To copy, or not to copy?

    return 0;
}

- (int)finishJob {

    return 0;
}

- (int)abortJob {

    return 0;
}

@end