//
//  CPJob.h
//  GoogleCloudPrint
//
//  Created by Conrad Kramer on 10/21/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum {
    CPJobStatusUnknown,
    CPJobStatusQueued,
    CPJobStatusInProgress,
    CPJobStatusDone,
    CPJobStatusError
} CPJobStatus;

@class CPPrinter;

@interface CPJob : NSManagedObject

@property (nonatomic, retain) NSString * jobID;

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * contentType;

@property (nonatomic) CPJobStatus status;
@property (nonatomic, retain) NSString * message;

@property (nonatomic, retain) CPPrinter *printer;

@property (nonatomic, retain) NSDate *created;
@property (nonatomic, retain) NSDate *updated;

// NOT in Core Data
@property (strong, nonatomic) NSData *fileData;
@property (strong, nonatomic) NSString *fileName;

@end
