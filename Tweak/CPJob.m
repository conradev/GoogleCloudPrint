//
//  CPJob.m
//  GoogleCloudPrint
//
//  Created by Conrad Kramer on 10/21/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "CPJob.h"

@implementation CPJob

@dynamic jobID;

@dynamic title;
@dynamic contentType;

@dynamic status;
@dynamic message;

@dynamic printer;

@dynamic created;

@synthesize fileData = _fileData;
@synthesize fileName = _fileName;

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, title: %@, jobID: %@, status: %i>", NSStringFromClass([self class]), self, self.title, self.jobID, self.status];
}

- (NSString *)fileName {
    if (_fileName) {
        return _fileName;
    }

    NSString *fileExtension = @".pdf";
    NSString *fileName = [[self.title componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
    return [fileName stringByAppendingString:fileExtension];
}


@end
