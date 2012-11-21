//
//  CPPrinter.m
//  GoogleCloudPrint
//
//  Created by Conrad Kramer on 10/21/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "CPPrinter.h"
#import "CPJob.h"

@implementation CPPrinter

@dynamic printerID;

@dynamic name;
@dynamic displayName;
@dynamic proxy;
@dynamic printerDescription;

@dynamic status;
@dynamic connectionStatus;

@dynamic jobs;

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, name: %@, printerID: %@, connectionStatus: %i>", NSStringFromClass([self class]), self, self.name, self.printerID, self.connectionStatus];
}

@end
