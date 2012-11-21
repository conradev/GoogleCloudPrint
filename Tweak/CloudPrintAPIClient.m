//
//  CloudPrintAPIClient.m
//  GoogleCloudPrint
//
//  Created by Conrad Kramer on 10/21/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "CloudPrintAPIClient.h"

#import "CPPrinter.h"
#import "CPJob.h"

static NSString * const CPAPIBaseURLString = @"https://www.google.com/cloudprint/";

@implementation CloudPrintAPIClient

+ (CloudPrintAPIClient *)sharedClient {
    static CloudPrintAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:CPAPIBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    if ((self = [super initWithBaseURL:url])) {
        // Let's use JSON!
        self.parameterEncoding = AFJSONParameterEncoding;
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        [self setAuthorizationHeaderWithToken:@"ya29.AHES6ZQTqiv1cNHn-C0gZYjXKKL5Egqn-O5r9nqMHytWW78"];
        
        [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/plain"]];        
    }
    
    return self;
}

- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)urlRequest success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    void (^wrappedSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"success"] isEqualToNumber:@NO]) {
            NSError *error = [NSError errorWithDomain:AFNetworkingErrorDomain code:0 userInfo:@{ NSLocalizedDescriptionKey : responseObject[@"message"] }];
            failure(operation, error);
        } else {
            success(operation, responseObject);
        }
    };
    
    return [super HTTPRequestOperationWithRequest:urlRequest success:wrappedSuccess failure:failure];
}

#pragma mark - Authorization

- (void)setAuthorizationHeaderWithToken:(NSString *)token {
    [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", token]];
}

#pragma mark - Parsing Responses

- (id)representationOrArrayOfRepresentationsFromResponseObject:(NSDictionary *)responseObject {
    if (responseObject[@"printers"]) { // After querying printers
        return responseObject[@"printers"];
    } else if (responseObject[@"jobs"]) { // After querying jobs
        return responseObject[@"jobs"];
    } else if (responseObject[@"job"]) { // After submitting a job
        return responseObject[@"job"];
    }
    
    return nil;
}

- (NSDictionary *)fixedRepresentation:(NSDictionary *)representation forEntity:(NSEntityDescription *)entity {
    if ([entity.name isEqualToString:@"Printer"]) {
        NSArray *printers = representation[@"printers"];
        if (printers.count == 1) {
            representation = [printers objectAtIndex:0];
        }
    } else if ([entity.name isEqualToString:@"Job"]) {
        if (representation[@"job"]) {
            representation = representation[@"job"];
        }
    }
    
    return representation;
}

- (NSString *)resourceIdentifierForRepresentation:(NSDictionary *)representation
                                         ofEntity:(NSEntityDescription *)entity
                                     fromResponse:(NSHTTPURLResponse *)response {
    
    representation = [self fixedRepresentation:representation forEntity:entity];
    
    if ([entity.name isEqualToString:@"Printer"]) {
        return representation[@"id"];
    } else if ([entity.name isEqualToString:@"Job"]) {
        return [NSString pathWithComponents:@[ representation[@"printerid"], representation[@"id"] ]];
    }
    
    return nil;
}

- (NSDictionary *)attributesForRepresentation:(NSDictionary *)representation
                                     ofEntity:(NSEntityDescription *)entity
                                 fromResponse:(NSHTTPURLResponse *)response {
        
    representation = [self fixedRepresentation:representation forEntity:entity];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[super attributesForRepresentation:representation ofEntity:entity fromResponse:response]];
    
    if ([entity.name isEqualToString:@"Printer"]) {
        attributes[@"printerID"] = representation[@"id"];
        attributes[@"name"] = representation[@"name"];
        attributes[@"displayName"] = representation[@"displayName"];
        attributes[@"printerDescription"] = representation[@"description"];
        attributes[@"proxy"] = representation[@"proxy"];
        attributes[@"status"] = representation[@"status"];
        
        NSString *statusRepresentation = representation[@"connectionStatus"];
        NSNumber *connectionStatus = @(CPConnectionStatusUnknown);
        
        if ([statusRepresentation isEqualToString:@"ONLINE"]) {
            connectionStatus = @(CPConnectionStatusOnline);
        } else if ([statusRepresentation isEqualToString:@"OFFLINE"]) {
            connectionStatus = @(CPConnectionStatusOffline);
        } else if ([statusRepresentation isEqualToString:@"DORMANT"]) {
            connectionStatus = @(CPConnectionStatusDormant);
        }
        
        attributes[@"connectionStatus"] = connectionStatus;
        
    } else if ([entity.name isEqualToString:@"Job"]) {
        attributes[@"jobID"] = representation[@"id"];
        attributes[@"title"] = representation[@"title"];
        attributes[@"contentType"] = representation[@"contentType"];
        attributes[@"message"] = representation[@"message"];
        attributes[@"created"] = [NSDate dateWithTimeIntervalSince1970:[representation[@"createTime"] doubleValue]];
        attributes[@"updated"] = [NSDate dateWithTimeIntervalSince1970:[representation[@"updateTime"] doubleValue]];
                
        NSString *statusRepresentation = representation[@"status"];
        NSNumber *jobStatus = @(CPJobStatusUnknown);
        
        if ([statusRepresentation isEqualToString:@"QUEUED"]) {
            jobStatus = @(CPJobStatusQueued);
        } else if ([statusRepresentation isEqualToString:@"IN_PROGRESS"]) {
            jobStatus = @(CPJobStatusInProgress);
        } else if ([statusRepresentation isEqualToString:@"DONE"]) {
            jobStatus = @(CPJobStatusDone);
        } else if ([statusRepresentation isEqualToString:@"ERROR"]) {
            jobStatus = @(CPJobStatusError);
        }
        
        [attributes  removeObjectForKey:@"updated"];
        
        attributes[@"status"] = jobStatus;
    }
    
    return attributes;
}

#pragma mark - Paths

- (NSString *)pathForEntity:(NSEntityDescription *)entity {
    if ([entity.name isEqualToString:@"Printer"]) {
        return @"search";
    } else if ([entity.name isEqualToString:@"Job"]) {
        return @"jobs";
    }
    
    return nil;
}

- (NSString *)pathForObject:(NSManagedObject *)object {
    if ([object.entity.name isEqualToString:@"Printer"]) {
        return @"printer";
    }
    
    return nil;
}

- (NSString *)pathForRelationship:(NSRelationshipDescription *)relationship forObject:(NSManagedObject *)object {
    if ([object.entity.name isEqualToString:@"Printer"]) {
        if ([relationship.destinationEntity.name isEqualToString:@"Job"]) {
            return @"jobs";
        }
    } else if ([object.entity.name isEqualToString:@"Job"]) {
        if ([relationship.destinationEntity.name isEqualToString:@"Printer"]) {
            return @"printer";
        }
    }
    
    return nil;
}

#pragma mark - Requests

- (NSURLRequest *)requestForFetchRequest:(NSFetchRequest *)fetchRequest
                             withContext:(NSManagedObjectContext *)context {
    NSMutableURLRequest *mutableRequest = [super requestForFetchRequest:fetchRequest withContext:context];
    
    NSString *entityName = [[fetchRequest entity] name];
    
    if ([entityName isEqualToString:@"Printer"]) {
        mutableRequest = [self requestWithMethod:@"GET" path:[self pathForEntity:fetchRequest.entity] parameters:@{ @"connection_status" : @"ALL" }];
        mutableRequest.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    }
    
    return mutableRequest;
}

- (NSURLRequest *)requestWithMethod:(NSString *)method
                pathForObjectWithID:(NSManagedObjectID *)objectID
                        withContext:(NSManagedObjectContext *)context {

    NSMutableURLRequest *mutableRequest = [super requestWithMethod:method pathForObjectWithID:objectID withContext:context];
    
    NSManagedObject *object = [context objectWithID:objectID];
    NSString *entityName = [[objectID entity] name];
    NSString *resourceIdentifier = AFResourceIdentifierFromReferenceObject([(NSIncrementalStore *)objectID.persistentStore referenceObjectForObjectID:objectID]);
    
    if ([entityName isEqualToString:@"Printer"]) {
        mutableRequest = [self requestWithMethod:method path:[self pathForObject:object] parameters:@{ @"printerid" : resourceIdentifier, @"printer_connection_status" : @YES }];
    }
    
    return mutableRequest;
}

- (NSURLRequest *)requestWithMethod:(NSString *)method
                pathForRelationship:(NSRelationshipDescription *)relationship
                    forObjectWithID:(NSManagedObjectID *)objectID
                        withContext:(NSManagedObjectContext *)context {
    
    NSMutableURLRequest *mutableRequest = [super requestWithMethod:method pathForRelationship:relationship forObjectWithID:objectID withContext:context];
    
    NSManagedObject *object = [context objectWithID:objectID];
    NSString *entityName = objectID.entity.name;
    NSString *resourceIdentifier = AFResourceIdentifierFromReferenceObject([(NSIncrementalStore *)objectID.persistentStore referenceObjectForObjectID:objectID]);

    if ([entityName isEqualToString:@"Printer"]) {
        if ([relationship.destinationEntity.name isEqualToString:@"Job"]) {
            mutableRequest = [self requestWithMethod:method path:[self pathForRelationship:relationship forObject:object] parameters:@{ @"printerid" : resourceIdentifier }];
            mutableRequest.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
        }
    } else if ([entityName isEqualToString:@"Job"]) {
        if ([relationship.destinationEntity.name isEqualToString:@"Printer"]) {
            NSArray *pathComponents = [resourceIdentifier pathComponents];
            NSString *printerID =  pathComponents[0];
            
            mutableRequest = [self requestWithMethod:method path:[self pathForRelationship:relationship forObject:object] parameters:@{ @"printerid" : printerID }];
        }
    }
    
    return mutableRequest;
}

- (NSMutableURLRequest *)requestForDeletedObject:(NSManagedObject *)deletedObject {
    NSMutableURLRequest *mutableRequest = nil;
    
    NSString *entityName = deletedObject.entity.name;
    NSString *resourceIdentifier = AFResourceIdentifierFromReferenceObject([(NSIncrementalStore *)deletedObject.objectID.persistentStore referenceObjectForObjectID:deletedObject.objectID]);
    
    if ([entityName isEqualToString:@"Job"]) {
        NSArray *pathComponents = [resourceIdentifier pathComponents];
        NSString *jobID =  pathComponents[1];
        
        return [self requestWithMethod:@"GET" path:@"deletejob" parameters:@{ @"jobid" : jobID }];
    }
    
    return mutableRequest;
}

- (NSMutableURLRequest *)requestForInsertedObject:(NSManagedObject *)insertedObject {
    NSMutableURLRequest *mutableRequest = nil;
    
    NSString *entityName = insertedObject.entity.name;
    
    if ([entityName isEqualToString:@"Job"]) {
        CPJob *job = (CPJob *)insertedObject;
        
        if (job.printer.printerID && job.fileData && job.title.length) {
            void (^constructionBlock)(id<AFMultipartFormData> formData) = ^(id<AFMultipartFormData> formData) {
                [formData appendPartWithFileData:job.fileData name:@"content" fileName:job.fileName mimeType:job.contentType];
            };
            
            NSDictionary *parameters = @{ @"printerid" : job.printer.printerID, @"title" : job.title, @"contentType" : job.contentType };
            mutableRequest = [self multipartFormRequestWithMethod:@"POST" path:@"submit" parameters:parameters constructingBodyWithBlock:constructionBlock];
        }
    }
    
    return mutableRequest;
}

- (NSMutableURLRequest *)requestForUpdatedObject:(NSManagedObject *)updatedObject {
    return nil;
}

#pragma mark - Delegate

- (BOOL)shouldFetchRemoteAttributeValuesForObjectWithID:(NSManagedObjectID *)objectID
                                 inManagedObjectContext:(NSManagedObjectContext *)context {
    if ([objectID.entity.name isEqualToString:@"Printer"]) {        
        return YES;
    }
    
    return NO;
}

- (BOOL)shouldFetchRemoteValuesForRelationship:(NSRelationshipDescription *)relationship
                               forObjectWithID:(NSManagedObjectID *)objectID
                        inManagedObjectContext:(NSManagedObjectContext *)context {
    if ([objectID.entity.name isEqualToString:@"Printer"]) {
        if ([relationship.destinationEntity.name isEqualToString:@"Job"]) {
            return YES;
        }
    } else if ([objectID.entity.name isEqualToString:@"Job"]) {
        if ([relationship.destinationEntity.name isEqualToString:@"Printer"]) {
            return YES;
        }
    }
    
    return NO;
}

@end