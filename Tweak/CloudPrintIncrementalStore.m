//
//  CloudPrintIncrementalStore.m
//  GoogleCloudPrint
//
//  Created by Conrad Kramer on 10/21/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "CloudPrintIncrementalStore.h"
#import "CloudPrintAPIClient.h"
#import "CPPrinter.h"
#import "CPJob.h"

static NSManagedObjectModel *_managedObjectModel;

@implementation CloudPrintIncrementalStore

+ (void)initialize {
    [NSPersistentStoreCoordinator registerStoreClass:self forStoreType:[self type]];
}

+ (NSString *)type {
    return NSStringFromClass(self);
}

+ (NSManagedObjectModel *)model {
    if (_managedObjectModel == nil) {
        
        _managedObjectModel = [[NSManagedObjectModel alloc] init];
        
        // Create entities
        
        NSEntityDescription *printerEntity = [[NSEntityDescription alloc] init];
        [printerEntity setName:@"Printer"];
        [printerEntity setManagedObjectClassName:@"CPPrinter"];
        
        NSEntityDescription *jobEntity = [[NSEntityDescription alloc] init];
        [jobEntity setName:@"Job"];
        [jobEntity setManagedObjectClassName:@"CPJob"];
        
        // Configure relationships
        NSRelationshipDescription *jobsRelationship = [[NSRelationshipDescription alloc] init];
        NSRelationshipDescription *printerRelationship = [[NSRelationshipDescription alloc] init];
        [printerRelationship setInverseRelationship:jobsRelationship];
        [jobsRelationship setInverseRelationship:printerRelationship];
        
        // Configure printer attributes
        if (printerEntity) {
            [printerRelationship setName:@"printer"];
            [printerRelationship setDestinationEntity:printerEntity];
            [printerRelationship setMinCount:1];
            [printerRelationship setMaxCount:1];

            NSAttributeDescription *idAttribute = [[NSAttributeDescription alloc] init];
            [idAttribute setName:@"printerID"];
            [idAttribute setAttributeType:NSStringAttributeType];
            
            NSAttributeDescription *nameAttribute = [[NSAttributeDescription alloc] init];
            [nameAttribute setName:@"name"];
            [nameAttribute setAttributeType:NSStringAttributeType];
            
            NSAttributeDescription *displayNameAttribute = [[NSAttributeDescription alloc] init];
            [displayNameAttribute setName:@"displayName"];
            [displayNameAttribute setAttributeType:NSStringAttributeType];
            
            NSAttributeDescription *descriptionAttribute = [[NSAttributeDescription alloc] init];
            [descriptionAttribute setName:@"printerDescription"];
            [descriptionAttribute setAttributeType:NSStringAttributeType];
            
            NSAttributeDescription *proxyAttribute = [[NSAttributeDescription alloc] init];
            [proxyAttribute setName:@"proxy"];
            [proxyAttribute setAttributeType:NSStringAttributeType];
            
            NSAttributeDescription *statusAttribute = [[NSAttributeDescription alloc] init];
            [statusAttribute setName:@"status"];
            [statusAttribute setAttributeType:NSStringAttributeType];
            
            NSAttributeDescription *connectionStatusAttribute = [[NSAttributeDescription alloc] init];
            [connectionStatusAttribute setName:@"connectionStatus"];
            [connectionStatusAttribute setAttributeType:NSInteger32AttributeType];
            [connectionStatusAttribute setDefaultValue:@(CPConnectionStatusUnknown)];
            
            [printerEntity setProperties:@[ jobsRelationship, idAttribute, nameAttribute, displayNameAttribute, descriptionAttribute, proxyAttribute, statusAttribute, connectionStatusAttribute ]];
        }
        
        // Configure job attributes
        if (jobEntity) {
            [jobsRelationship setName:@"jobs"];
            [jobsRelationship setDestinationEntity:jobEntity];
            [jobsRelationship setMaxCount:-1];

            NSAttributeDescription *idAttribute = [[NSAttributeDescription alloc] init];
            [idAttribute setName:@"jobID"];
            [idAttribute setAttributeType:NSStringAttributeType];
            
            NSAttributeDescription *titleAttribute = [[NSAttributeDescription alloc] init];
            [titleAttribute setName:@"title"];
            [titleAttribute setAttributeType:NSStringAttributeType];
            
            NSAttributeDescription *contentTypeAttribute = [[NSAttributeDescription alloc] init];
            [contentTypeAttribute setName:@"contentType"];
            [contentTypeAttribute setAttributeType:NSStringAttributeType];
            
            NSAttributeDescription *statusAttribute = [[NSAttributeDescription alloc] init];
            [statusAttribute setName:@"status"];
            [statusAttribute setAttributeType:NSInteger32AttributeType];
            [statusAttribute setDefaultValue:@(CPJobStatusUnknown)];
            
            NSAttributeDescription *messageAttribute = [[NSAttributeDescription alloc] init];
            [messageAttribute setName:@"message"];
            [messageAttribute setAttributeType:NSStringAttributeType];
            
            NSAttributeDescription *createdAttribute = [[NSAttributeDescription alloc] init];
            [createdAttribute setName:@"created"];
            [createdAttribute setAttributeType:NSDateAttributeType];
            
            [jobEntity setProperties:@[ printerRelationship, idAttribute, titleAttribute, contentTypeAttribute, statusAttribute, messageAttribute, createdAttribute ]];
        }
        
        [_managedObjectModel setEntities:@[ printerEntity, jobEntity ]];
    }
    
    return _managedObjectModel;
}

- (id<AFIncrementalStoreHTTPClient>)HTTPClient {
    return [CloudPrintAPIClient sharedClient];
}

@end