//
//  PKPrinterBrowser.x
//  GoogleCloudPrint
//
//  Created by Conrad Kramer on 10/21/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import <Foundation/NSXPCConnection.h>

#import <PrintKit/PKPrinterBrowser.h>
#import "CloudPrintServiceDelegate.h"

#import "CloudPrintXPCBridge.h"
#import "CPPrinterProxy.h"

@interface CloudPrintServiceDelegateProxy : NSObject <CloudPrintServiceDelegate>
@property (assign, nonatomic) id<CloudPrintServiceDelegate> realDelegate;
@end
@implementation CloudPrintServiceDelegateProxy
- (id)forwardingTargetForSelector:(SEL)aSelector { return _realDelegate; }
@end

@interface PKPrinterBrowser (CloudPrintConnector) <CloudPrintServiceDelegate>
@property (strong, nonatomic, getter=__cloudprint_connection, setter=__cloudprint_set_connection:) NSXPCConnection *cloudprintConnection;
@property (strong, nonatomic, getter=__cloudprint_printers, setter=__cloudprint_set_printers:) NSMutableDictionary *cloudprintPrinters;
@end

static char connectionKey, printersKey;

%config(generator=internal);

%hook PKPrinterBrowser

- (id)initWithDelegate:(id)delegate {
    if ((self = %orig)) {
        NSXPCConnection *connection = [[NSXPCConnection alloc] initWithMachServiceName:@"org.thebigboss.cpconnector" options:0x0];
        
        NSSet *acceptableClasses = [NSSet setWithObjects:[NSSet class], [CPPrinterProxy class], nil];
        
        // This is to break a retain cycle
        // `self` retains `connection` and `connection` retains `exportedObject`
        CloudPrintServiceDelegateProxy *delegateProxy = [[CloudPrintServiceDelegateProxy alloc] init];
        delegateProxy.realDelegate = self;
        connection.exportedObject = delegateProxy;
        
        NSXPCInterface *exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(CloudPrintServiceDelegate)];
        [exportedInterface setClasses:acceptableClasses forSelector:@selector(cloudprintServiceInsertedPrinters:) argumentIndex:0 ofReply:NO];
        [exportedInterface setClasses:acceptableClasses forSelector:@selector(cloudprintServiceUpdatedPrinters:) argumentIndex:0 ofReply:NO];
        [exportedInterface setClasses:acceptableClasses forSelector:@selector(cloudprintServiceDeletedPrinters:) argumentIndex:0 ofReply:NO];
        connection.exportedInterface = exportedInterface;

        NSXPCInterface *remoteInterface = [NSXPCInterface interfaceWithProtocol:@protocol(CloudPrintService)];
        [remoteInterface setClasses:acceptableClasses forSelector:@selector(fetchPrintersWithReply:) argumentIndex:0 ofReply:YES];
        connection.remoteObjectInterface = remoteInterface;
        
        [connection resume];
        self.cloudprintConnection = connection;
        
        // Get remote object
        id<CloudPrintService> service = [connection remoteObjectProxy];
        [service fetchPrintersWithReply:^(NSSet *printers) {
            [self cloudprintServiceInsertedPrinters:printers];
        }];
    }
    
    return self;
}

- (void)dealloc {
    [self.cloudprintConnection invalidate];
    
    %orig;
}

#pragma mark - Properties

%new(v@:@)
- (void)__cloudprint_set_connection:(id)object {
    objc_setAssociatedObject(self, &connectionKey, object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new(@@:)
- (id)__cloudprint_connection {
    return objc_getAssociatedObject(self, &connectionKey);
}

%new(v@:@)
- (void)__cloudprint_set_printers:(id)object {
    objc_setAssociatedObject(self, &printersKey, object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new(@@:)
- (id)__cloudprint_printers {
    return objc_getAssociatedObject(self, &printersKey);
}

#pragma mark - Overridden property values

- (NSMutableDictionary *)printers {
    NSMutableDictionary *orig = %orig;
    
    NSMutableDictionary *combined = [NSMutableDictionary dictionaryWithDictionary:orig];
    [combined addEntriesFromDictionary:self.cloudprintPrinters];
    
    return combined;
}

#pragma mark - CloudPrintServiceDelegate

%new(v@:@)
- (void)cloudprintServiceInsertedPrinters:(NSSet *)printers {
    NSLog(@"Inserted printers! %@", printers);
    [self cloudprintServiceUpdatedPrinters:printers];
    
    // Notify delegate
    NSArray *allPrinters = [printers allObjects];
    [allPrinters enumerateObjectsUsingBlock:^(CPPrinterProxy *printer, NSUInteger idx, BOOL *stop) {
        BOOL more = (idx < allPrinters.count - 1);
        [self.delegate addPrinter:printer moreComing:more];
    }];
}

%new(v@:@)
- (void)cloudprintServiceUpdatedPrinters:(NSSet *)printers {
    NSLog(@"Updated printers! %@", printers);
    [printers enumerateObjectsUsingBlock:^(CPPrinterProxy *printer, BOOL *stop) {
        [self.cloudprintPrinters setObject:printer forKey:printer.cloudprintID];
    }];
}

%new(v@:@)
- (void)cloudprintServiceDeletedPrinters:(NSSet *)printers {
    NSLog(@"Deleted printers! %@", printers);
    [printers enumerateObjectsUsingBlock:^(CPPrinterProxy *printer, BOOL *stop) {
        [self.cloudprintPrinters removeObjectForKey:printer.cloudprintID];
    }];
    
    // Notify delegate
    NSArray *allPrinters = [printers allObjects];
    [allPrinters enumerateObjectsUsingBlock:^(CPPrinterProxy *printer, NSUInteger idx, BOOL *stop) {
        BOOL more = (idx < allPrinters.count - 1);
        [self.delegate removePrinter:printer moreGoing:more];
    }];
}

%end

%ctor {
    %init;

    class_addProtocol(%c(PKPrinterBrowser), @protocol(CloudPrintServiceDelegate));
}