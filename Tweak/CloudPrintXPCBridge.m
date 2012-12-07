//
//  CloudPrintXPCBridge.m
//  GoogleCloudPrint
//
//  Created by Conrad Kramer on 10/21/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import <Foundation/NSXPCConnection.h>
#import <objc/runtime.h>

#import "CloudPrintXPCBridge.h"
#import "CPPrinterServiceDelegate.h"

#import "CPPrinter.h"
#import "CPPrinterProxy.h"

@interface CloudPrintXPCBridge () {
    BOOL justKeepSwimming;
    NSSet *(^proxiesFromModels)(NSSet *);
}
@property (strong, nonatomic) NSMutableSet *connections;

@property (strong, nonatomic) NSXPCListener *printerListener;
@property (strong, nonatomic) NSXPCListener *authListener;

@end

@implementation CloudPrintXPCBridge

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context {
    if ((self = [super init])) {
        _context = context;
        _connections = [NSMutableSet set];

        proxiesFromModels = ^(NSSet *printers) {
            NSMutableSet *proxies = [NSMutableSet set];
            [printers enumerateObjectsUsingBlock:^(CPPrinter *printer, BOOL *stop) {
                CPPrinterProxy *proxy = [[CPPrinterProxy alloc] initWithPrinter:printer];
                [proxies addObject:proxy];
            }];
            return [NSSet setWithSet:proxies];
        };

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextObjectsDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
}

#pragma mark - NSRunLoop

- (void)runWithPrinterListener:(NSXPCListener *)printerListener authorizationListener:(NSXPCListener *)authListener {
    self.printerListener = printerListener;
    self.authListener = authListener;

    NSArray *listeners = @[ self.printerListener, self.authListener ];

    [listeners enumerateObjectsUsingBlock:^(NSXPCListener *listener, NSUInteger idx, BOOL *stop) {
        listener.delegate = self;
        [listener resume];
    }];

    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];

    // See http://lists.apple.com/archives/cocoa-dev/2003/Mar/msg01158.html
    justKeepSwimming = YES;
    while (justKeepSwimming) {
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[runLoop limitDateForMode:NSDefaultRunLoopMode]];
    }

    [listeners enumerateObjectsUsingBlock:^(NSXPCListener *listener, NSUInteger idx, BOOL *stop) {
        [listener invalidate];
    }];

    self.printerListener = nil;
    self.authListener = nil;
}

- (void)stopListener {
    justKeepSwimming = NO;
    [[NSRunLoop currentRunLoop] performSelector:nil target:nil argument:nil order:0 modes:@[NSDefaultRunLoopMode]];
}

- (void)stopTimeout {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopListener) object:nil];
}

- (void)startTimeout {
    [self performSelector:@selector(stopListener) withObject:nil afterDelay:60.0f];
}

#pragma mark - NSXPCListenerDelegate

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {

    NSLog(@"Canceling any scheduled stops.");
    [self performSelectorOnMainThread:@selector(stopTimeout) withObject:nil waitUntilDone:YES];

    newConnection.exportedObject = self;

    if ([listener isEqual:self.printerListener]) {
        NSSet *acceptableClasses = [NSSet setWithObjects:[NSSet class], [CPPrinterProxy class], nil];

        NSXPCInterface *remoteInterface = [NSXPCInterface interfaceWithProtocol:@protocol(CPPrinterServiceDelegate)];
        [remoteInterface setClasses:acceptableClasses forSelector:@selector(cloudprintServiceInsertedPrinters:) argumentIndex:0 ofReply:NO];
        [remoteInterface setClasses:acceptableClasses forSelector:@selector(cloudprintServiceUpdatedPrinters:) argumentIndex:0 ofReply:NO];
        [remoteInterface setClasses:acceptableClasses forSelector:@selector(cloudprintServiceDeletedPrinters:) argumentIndex:0 ofReply:NO];
        newConnection.remoteObjectInterface = remoteInterface;

        NSXPCInterface *exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(CPPrinterService)];
        [exportedInterface setClasses:acceptableClasses forSelector:@selector(fetchPrintersWithReply:) argumentIndex:0 ofReply:YES];
        newConnection.exportedInterface = exportedInterface;
    } else if ([listener isEqual:self.authListener]) {

    }

    __weak NSXPCConnection *weakConnection = newConnection;
    newConnection.invalidationHandler = ^() {
        NSLog(@"Connection invalidated %@", weakConnection);
        [self.connections removeObject:weakConnection];

        if (!self.connections.count) {
            NSLog(@"No valid connections. Scheduling stop in one minute.");
            [self performSelectorOnMainThread:@selector(startTimeout) withObject:nil waitUntilDone:YES];
        }
    };

    [newConnection resume];
    NSLog(@"Connection created %@", newConnection);
    [self.connections addObject:newConnection];

    return YES;
}

#pragma mark - CloudPrintDataSource

- (void)fetchPrintersWithReply:(void (^)(NSSet *))replyBlock {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Printer"];
    NSArray *printers = [_context executeFetchRequest:request error:nil];

    replyBlock(proxiesFromModels([NSSet setWithArray:printers]));
}

#pragma mark - CloudPrintServiceDelegate

- (void)managedObjectContextObjectsDidChange:(NSNotification *)note {

    BOOL (^printerTest)(id, BOOL*) = ^(id obj, BOOL *stop) {
        return [obj isKindOfClass:[CPPrinter class]];
    };
    NSSet *inserted = [note.userInfo[NSInsertedObjectsKey] objectsPassingTest:printerTest];
    NSSet *updated = [note.userInfo[NSUpdatedObjectsKey] objectsPassingTest:printerTest];
    NSSet *deleted = [note.userInfo[NSDeletedObjectsKey] objectsPassingTest:printerTest];

    NSSet *printerConnections = [self.connections objectsPassingTest:^(NSXPCConnection *connection, BOOL *stop) {
        Protocol *remoteProtocol = connection.remoteObjectInterface.protocol;
        return protocol_isEqual(remoteProtocol, @protocol(CPPrinterServiceDelegate));
    }];

    [printerConnections enumerateObjectsUsingBlock:^(NSXPCConnection *connection, BOOL *stop) {
        id<CPPrinterServiceDelegate> serviceDelegate = [connection remoteObjectProxy];
        
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