//
//  CloudPrintXPCBridge.h
//  GoogleCloudPrint
//
//  Created by Conrad Kramer on 10/21/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@protocol NSXPCListenerDelegate;

@protocol CloudPrintService <NSObject>
@required
- (void)fetchPrintersWithReply:(void (^)(NSSet *))returnBlock;
@end

@interface CloudPrintXPCBridge : NSObject <NSXPCListenerDelegate, CloudPrintService>

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context;

@property (strong, readonly, nonatomic) NSManagedObjectContext *context;

@end