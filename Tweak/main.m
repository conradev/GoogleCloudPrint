#import <Foundation/NSXPCConnection.h>

#import "CloudPrintIncrementalStore.h"
#import "CloudPrintXPCBridge.h"

int main(int argc, char **argv, char **envp) {
        
    // Set up persistent stores
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[CloudPrintIncrementalStore model]];
    CloudPrintIncrementalStore *incrementalStore = (CloudPrintIncrementalStore *)[persistentStoreCoordinator addPersistentStoreWithType:[CloudPrintIncrementalStore type] configuration:nil URL:nil options:nil error:nil];
    [incrementalStore.backingPersistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:nil];
    
    // Create managed object context
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
    
    NSLog(@"Service starting...");
    
    // Run listener
    CloudPrintXPCBridge *bridge = [[CloudPrintXPCBridge alloc] initWithManagedObjectContext:managedObjectContext];
    NSXPCListener *printerListener = [[NSXPCListener alloc] initWithMachServiceName:@"org.thebigboss.cpconnector.printers"];
    NSXPCListener *authListener = [[NSXPCListener alloc] initWithMachServiceName:@"org.thebigboss.cpconnector.authorization"];
    [bridge runWithPrinterListener:printerListener authorizationListener:authListener];
    
    NSLog(@"Service stopping...");
    
    return 0;
}