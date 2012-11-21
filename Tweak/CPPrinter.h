//
//  CPPrinter.h
//  GoogleCloudPrint
//
//  Created by Conrad Kramer on 10/21/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum {
    CPConnectionStatusUnknown,
    CPConnectionStatusOnline,
    CPConnectionStatusOffline,
    CPConnectionStatusDormant
} CPConnectionStatus;

@class CPJob;

@interface CPPrinter : NSManagedObject

@property (nonatomic, retain) NSString * printerID;

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * displayName;

@property (nonatomic, retain) NSString * proxy;
@property (nonatomic, retain) NSString * printerDescription;

@property (nonatomic, retain) NSString * status;
@property (nonatomic) CPConnectionStatus connectionStatus;

@property (nonatomic, retain) NSSet *jobs;

@end