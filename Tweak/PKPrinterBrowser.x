#import <Foundation/NSXPCConnection.h>
#import <PrintKit/PKPrinterBrowser.h>

#import "CloudPrintServiceDelegate.h"

#import "CloudPrintXPCBridge.h"
#import "CPPrinterProxy.h"

@interface PKPrinterBrowser (CloudPrintConnector) <CloudPrintServiceDelegate>
@property (retain, nonatomic, getter=__cloudprint_connection, setter=__cloudprint_set_connection:) NSXPCConnection *cloudprintConnection;
@property (retain, nonatomic, getter=__cloudprint_printers, setter=__cloudprint_set_printers:) NSMutableDictionary *cloudprintPrinters;
@end

static char connectionKey;
static char printersKey;

%hook PKPrinterBrowser

%new(v@:@)
- (void)__cloudprint_set_connection:(NSXPCConnection *)connection {
    objc_setAssociatedObject(self, &connectionKey, connection, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new(@@:)
- (id)__cloudprint_connection {
    return (NSXPCConnection *)objc_getAssociatedObject(self, &connectionKey);
}

%new(v@:@)
- (void)__cloudprint_set_printers:(NSMutableDictionary *)printers {
    objc_setAssociatedObject(self, &printersKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new(@@:)
- (id)__cloudprint_printers {
    return (NSXPCConnection *)objc_getAssociatedObject(self, &printersKey);
}

- (id)initWithDelegate:(id)delegate {
    if ((self = %orig)) {
        NSXPCConnection *connection = [[NSXPCConnection alloc] initWithMachServiceName:@"org.thebigboss.cpconnector" options:0x0];
        
        %c(CPPrinterProxy) = objc_getClass("CPPrinterProxy");
        NSSet *acceptableClasses = [NSSet setWithObjects:[NSSet class], %c(CPPrinterProxy), nil];
        
        NSXPCInterface *exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(CloudPrintServiceDelegate)];
        [exportedInterface setClasses:acceptableClasses forSelector:@selector(cloudprintServiceInsertedPrinters:) argumentIndex:0 ofReply:NO];
        [exportedInterface setClasses:acceptableClasses forSelector:@selector(cloudprintServiceUpdatedPrinters:) argumentIndex:0 ofReply:NO];
        [exportedInterface setClasses:acceptableClasses forSelector:@selector(cloudprintServiceDeletedPrinters:) argumentIndex:0 ofReply:NO];
        connection.exportedInterface = exportedInterface;
        connection.exportedObject = self;

        NSXPCInterface *remoteInterface = [NSXPCInterface interfaceWithProtocol:@protocol(CloudPrintService)];
        [remoteInterface setClasses:acceptableClasses forSelector:@selector(fetchPrintersWithReply:) argumentIndex:0 ofReply:YES];
        connection.remoteObjectInterface = remoteInterface;
        
        [connection resume];
        self.cloudprintConnection = connection;
        NSLog(@"Connected to Cloud Print service! %@", connection);
        
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
    NSLog(@"Disconnected from Cloud Print service! %@", self.cloudprintConnection);
    
    %orig;
}

- (NSMutableDictionary *)printers {
    NSMutableDictionary *orig = %orig;
    
    NSMutableDictionary *combined = [NSMutableDictionary dictionaryWithDictionary:orig];
    [combined addEntriesFromDictionary:self.cloudprintPrinters];
    
    return combined;
}

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