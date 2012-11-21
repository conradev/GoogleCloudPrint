//
//  CloudPrintXPCBridge.m
//  GoogleCloudPrint
//
//  Created by Conrad Kramer on 10/21/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import <Foundation/NSXPCConnection.h>

#import "CloudPrintXPCBridge.h"
#import "CloudPrintServiceDelegate.h"

#import "CPPrinter.h"
#import "CPPrinterProxy.h"

@interface CloudPrintXPCBridge ()
@property (strong, nonatomic) NSMutableSet *connections;
@end

@implementation CloudPrintXPCBridge

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context {
    if ((self = [super init])) {
        _context = context;
        _connections = [NSMutableSet set];
        
        %c(CPPrinterProxy) = objc_getClass("CPPrinterProxy");
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextObjectsDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
}

#pragma mark - NSXPCListenerDelegate

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    
    NSSet *acceptableClasses = [NSSet setWithObjects:[NSSet class], %c(CPPrinterProxy), nil];
    
    NSXPCInterface *remoteInterface = [NSXPCInterface interfaceWithProtocol:@protocol(CloudPrintServiceDelegate)];
    [remoteInterface setClasses:acceptableClasses forSelector:@selector(cloudprintServiceInsertedPrinters:) argumentIndex:0 ofReply:NO];
    [remoteInterface setClasses:acceptableClasses forSelector:@selector(cloudprintServiceUpdatedPrinters:) argumentIndex:0 ofReply:NO];
    [remoteInterface setClasses:acceptableClasses forSelector:@selector(cloudprintServiceDeletedPrinters:) argumentIndex:0 ofReply:NO];
    newConnection.remoteObjectInterface = remoteInterface;
    
    NSXPCInterface *exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(CloudPrintService)];
    [exportedInterface setClasses:acceptableClasses forSelector:@selector(fetchPrintersWithReply:) argumentIndex:0 ofReply:YES];
    newConnection.exportedInterface = exportedInterface;
    newConnection.exportedObject = self;

    __weak CloudPrintXPCBridge *weakSelf = self;
    __weak NSXPCConnection *weakConnection = newConnection;
    newConnection.invalidationHandler = ^() {
        NSLog(@"Connection invalidated: %@", weakConnection);
        [weakSelf.connections removeObject:weakConnection];
    };
    
    [newConnection resume];
    NSLog(@"Connection created: %@", newConnection);
    [self.connections addObject:newConnection];

    return YES;
}

#pragma mark - CloudPrintDataSource

- (void)fetchPrintersWithReply:(void (^)(NSSet *))replyBlock {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Printer"];
    NSArray *printers = [_context executeFetchRequest:request error:nil];
    
    NSMutableSet *proxies = [NSMutableSet set];
    [printers enumerateObjectsUsingBlock:^(CPPrinter *printer, NSUInteger idx, BOOL *stop) {
        CPPrinterProxy *proxy = [[%c(CPPrinterProxy) alloc] initWithPrinter:printer];
        [proxies addObject:proxy];
    }];
    
    replyBlock([NSSet setWithSet:proxies]);
}

#pragma mark - CloudPrintServiceDelegate

- (void)managedObjectContextObjectsDidChange:(NSNotification *)note {
    
    BOOL (^printerTest)(id, BOOL*) = ^(id obj, BOOL *stop) {
        return [obj isKindOfClass:[CPPrinter class]];
    };
    NSSet *inserted = [note.userInfo[NSInsertedObjectsKey] objectsPassingTest:printerTest];
    NSSet *updated = [note.userInfo[NSUpdatedObjectsKey] objectsPassingTest:printerTest];
    NSSet *deleted = [note.userInfo[NSDeletedObjectsKey] objectsPassingTest:printerTest];
    
    NSSet *(^proxiesFromModels)(NSSet *) = ^(NSSet *printers) {
        NSMutableSet *proxies = [NSMutableSet set];
        [printers enumerateObjectsUsingBlock:^(CPPrinter *printer, BOOL *stop) {
            CPPrinterProxy *proxy = [[%c(CPPrinterProxy) alloc] initWithPrinter:printer];
            [proxies addObject:proxy];
        }];
        return [NSSet setWithSet:proxies];
    };
        
    [self.connections enumerateObjectsUsingBlock:^(NSXPCConnection *connection, BOOL *stop) {
        id<CloudPrintServiceDelegate> serviceDelegate = [connection remoteObjectProxy];
        
        if (inserted.count) {
            [serviceDelegate cloudprintServiceInsertedPrinters:proxiesFromModels(inserted)];
        }
        if (updated.count) {
            [serviceDelegate cloudprintServiceUpdatedPrinters:proxiesFromModels(updated)];
        }
        if (deleted.count) {
            [serviceDelegate cloudprintServiceDeletedPrinters:proxiesFromModels(deleted)];
        }
    }];
}

@end