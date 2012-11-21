//
//  GCPAppDelegate.m
//  GoogleCloudPrint
//
//  Created by Conrad Kramer on 10/21/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "CPAppDelegate.h"

#import "CloudPrintIncrementalStore.h"
#import "CloudPrintAPIClient.h"
#import "CPPrinter.h"
#import "CPJob.h"

#import "CPPrinterListController.h"

@implementation CPAppDelegate

@synthesize managedObjectContext = _managedObjectContext, managedObjectModel = _managedObjectModel, persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Set up persistent stores
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[CloudPrintIncrementalStore model]];
    CloudPrintIncrementalStore *incrementalStore = (CloudPrintIncrementalStore *)[_persistentStoreCoordinator addPersistentStoreWithType:[CloudPrintIncrementalStore type] configuration:nil URL:nil options:nil error:nil];
    [incrementalStore.backingPersistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:nil];
    
    // Create managed context
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:_persistentStoreCoordinator];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextObjectsDidChangeNotification object:_managedObjectContext queue:nil usingBlock:^(NSNotification *note) {
        NSSet *objects = note.userInfo[NSInsertedObjectsKey];
        [objects enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            if ([obj isKindOfClass:[CPPrinter class]]) {
                CPPrinter *printer = (CPPrinter *)obj;
                
                NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Test" ofType:@"pdf"];
                
                if ([printer.printerID isEqualToString:@"__google__docs"]) {
                    CPJob *job = [NSEntityDescription insertNewObjectForEntityForName:@"Job" inManagedObjectContext:_managedObjectContext];
                    job.title = @"TESTICLES";
                    job.printer = printer;
                    job.fileData = [NSData dataWithContentsOfFile:filePath];
                    job.contentType = @"application/pdf";
                    
                    [_managedObjectContext save:nil];
                }
            }
        }];
    }];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Printer"];
    
    NSArray *results = [_managedObjectContext executeFetchRequest:request error:nil];
    NSLog(@"%@", [results valueForKey:@"name"]);
    
    CPPrinterListController *listController = [[CPPrinterListController alloc] init];
    
    _navigationController = [[UINavigationController alloc] initWithRootViewController:listController];
    
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.rootViewController = _navigationController;
    [_window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Saves changes in the application's managed object context before the application terminates.
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext {
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    return [CloudPrintIncrementalStore model];
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    return _persistentStoreCoordinator;
}

@end
