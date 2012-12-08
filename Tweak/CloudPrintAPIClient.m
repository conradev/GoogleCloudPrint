//
//  CloudPrintAPIClient.m
//  GoogleCloudPrint
//
//  Created by Conrad Kramer on 10/21/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "CloudPrintAPIClient.h"
#import "GoogleOAuth2Client.h"

#import "CPPrinter.h"
#import "CPJob.h"

static NSString * const kCloudPrintAPIBaseURLString = @"https://www.google.com/cloudprint/";
static NSString * const kCloudPrintAPIClientID = @"485131505528.apps.googleusercontent.com";
static NSString * const kCloudPrintAPIClientSecret = @"k06D1ob6iELWL1WB0UviAKXX";
static NSString * const kCloudPrintAPIScopeString = @"https://www.googleapis.com/auth/cloudprint";

@interface AFURLConnectionOperation (ModifyRequestAuthorization)
@property (readwrite, nonatomic, strong) NSURLRequest *request;
@end

@implementation AFURLConnectionOperation (ModifyRequestAuthorization)
@dynamic request;

- (void)setValueForAuthorizationHeader:(NSString *)value {
    NSMutableURLRequest *mutableURLRequest = [self.request mutableCopy];

    NSMutableDictionary *existingHeaders = [NSMutableDictionary dictionaryWithDictionary:[self.request allHTTPHeaderFields]];
    [existingHeaders setValue:value forKey:@"Authorization"];
    [mutableURLRequest setAllHTTPHeaderFields:existingHeaders];

    self.request = [mutableURLRequest copy];
}

@end

@interface CloudPrintAPIClient ()
@property (strong, nonatomic) GoogleOAuth2Client *authClient;
@property (strong, nonatomic) AFOAuthCredential *credential;
@end

@implementation CloudPrintAPIClient

+ (CloudPrintAPIClient *)sharedClient {
    static CloudPrintAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kCloudPrintAPIBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    if ((self = [super initWithBaseURL:url])) {
        // JSON
        self.parameterEncoding = AFJSONParameterEncoding;
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        // Google is stupid
        [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/plain"]];

        // Create OAuth client for authorization and load credential from keychain
        self.authClient = [GoogleOAuth2Client clientWithClientID:kCloudPrintAPIClientID secret:kCloudPrintAPIClientSecret];
        self.credential = [AFOAuthCredential retrieveCredentialWithIdentifier:self.authClient.serviceProviderIdentifier];
        
        // Monitor operation queues to automagically maintain dependencies
        [self.operationQueue addObserver:self forKeyPath:@"operations" options:NSKeyValueObservingOptionNew context:nil];
        [self.authClient.operationQueue addObserver:self forKeyPath:@"operations" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    return self;
}

- (void)dealloc {
    [self.authClient.operationQueue removeObserver:self forKeyPath:@"operations"];
    [self.operationQueue removeObserver:self forKeyPath:@"operations"];
}

#pragma mark - Authorization (API Client)

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"operations"]) {
        // Automagically refresh an expired credential
        if ([object isEqual:self.operationQueue] && self.credential.expired && self.authClient.operationQueue.operationCount == 0) {
            [self refreshCredentialWithSuccess:nil failure:nil];
        }
        
        NSArray *operations = self.operationQueue.operations;
        NSArray *authOperations = self.authClient.operationQueue.operations;

        // Make all operations in API client queue dependent on ones in auth client queue, automagically
        [operations enumerateObjectsUsingBlock:^(NSOperation *operation, NSUInteger idx, BOOL *stop) {
            [authOperations enumerateObjectsUsingBlock:^(NSOperation *authOperation, NSUInteger idx, BOOL *stop) {
                NSLog(@"Made operaton %@ dependent", operation);
                [operation addDependency:authOperation];
            }];
        }];
        
        if ([object isEqual:self.authClient.operationQueue]) {
            self.operationQueue.suspended = NO;
        }
    }
}

- (void)deleteCredential {
    self.credential = nil;
}

- (void)setCredential:(AFOAuthCredential *)credential {
    _credential = credential;

    // Store updated credential in keychain
    [AFOAuthCredential storeCredential:_credential withIdentifier:self.authClient.serviceProviderIdentifier];

    // Refresh authorization header in already queued operations
    [self setAuthorizationHeaderWithCredential:_credential];
    [self.operationQueue.operations enumerateObjectsUsingBlock:^(NSOperation *operation, NSUInteger idx, BOOL *stop) {
        if ([operation isKindOfClass:[AFURLConnectionOperation class]]) {
            [(AFURLConnectionOperation *)operation setValueForAuthorizationHeader:[self defaultValueForHeader:@"Authorization"]];
        }
    }];
}

// Borrowed from AFOAuth2Client
- (void)setAuthorizationHeaderWithCredential:(AFOAuthCredential *)credential {
    [self setAuthorizationHeaderWithToken:credential.accessToken ofType:credential.tokenType];
}

// Borrowed from AFOAuth2Client
- (void)setAuthorizationHeaderWithToken:(NSString *)token ofType:(NSString *)type {
    if ([[type lowercaseString] isEqualToString:@"bearer"]) {
        [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", token]];
    }
}

#pragma mark - Authorization (OAuth2 Client)

- (void)refreshCredentialWithSuccess:(void (^)())success
                             failure:(void (^)(NSError *))failure
{
    void (^wrappedSuccess)(AFOAuthCredential *) = ^(AFOAuthCredential *credential) {
        NSLog(@"Successfully refreshed credential");
        self.credential = credential;

        if (success) {
            success(self.credential);
        }
    };

    void (^wrappedFailure)(NSError *) = ^(NSError *error) {
        NSLog(@"Unable to refresh credential (%@)", [error localizedDescription]);
        if (failure) {
            failure(error);
        }
    };

    [self.authClient refreshCredential:self.credential success:wrappedSuccess failure:wrappedFailure];
    
    self.operationQueue.suspended = YES;
}

- (void)verifyCredentialWithSuccess:(void (^)())success
                            failure:(void (^)(NSError *))failure
{
    void (^wrappedSuccess)(AFOAuthCredential *) = ^(AFOAuthCredential *credential) {
        NSLog(@"Successfully verified credential");

        if (success) {
            success();
        }
    };

    void (^wrappedFailure)(NSError *) = ^(NSError *error) {
        NSLog(@"Unable to verify credential (%@)", [error localizedDescription]);
        if (failure) {
            failure(error);
        }
    };

    [self.authClient verifyCredential:self.credential againstRepresentation:nil success:wrappedSuccess failure:wrappedFailure];
    
    self.operationQueue.suspended = YES;
}

- (void)authenticateWithCode:(NSString *)code
                 redirectURI:(NSString *)uri
                     success:(void (^)())success
                     failure:(void (^)(NSError *))failure
{
    void (^wrappedSuccess)(AFOAuthCredential *) = ^(AFOAuthCredential *credential) {
        NSLog(@"Successfully exchanged code for credential");
        self.credential = credential;

        if (success) {
            success();
        }
    };

    void (^wrappedFailure)(NSError *) = ^(NSError *error) {
        NSLog(@"Unable to exchange code for credential (%@)", [error localizedDescription]);
        if (failure) {
            failure(error);
        }
    };

    [self.authClient authenticateUsingOAuthWithCode:code redirectURI:uri success:wrappedSuccess failure:wrappedFailure];
    
    self.operationQueue.suspended = YES;
}

- (NSURL *)authorizationURLWithRedirectURI:(NSURL *)uri {
    return [self.authClient authorizationURLWithScope:kCloudPrintAPIScopeString redirectURI:uri];
}

#pragma mark - Executing Requests

- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)urlRequest success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    void (^wrappedSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"success"] isEqualToNumber:@NO]) {
            NSError *error = [NSError errorWithDomain:AFNetworkingErrorDomain code:NSURLErrorUnknown userInfo:@{ NSLocalizedDescriptionKey : responseObject[@"message"] }];
            failure(operation, error);
        } else {
            success(operation, responseObject);
        }
    };
    
    return [super HTTPRequestOperationWithRequest:urlRequest success:wrappedSuccess failure:failure];
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
        representation = representation[@"job"] ?: representation;
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

        NSDictionary *possibleStatuses = @{
            @"ONLINE" : @(CPConnectionStatusOnline),
            @"OFFLINE" : @(CPConnectionStatusOffline),
            @"DORMANT" : @(CPConnectionStatusDormant)
        };
        
        NSNumber *connectionStatus = possibleStatuses[representation[@"connectionStatus"]];
        connectionStatus = connectionStatus ?: @(CPConnectionStatusUnknown);
        
        attributes[@"connectionStatus"] = connectionStatus;
        
    } else if ([entity.name isEqualToString:@"Job"]) {
        attributes[@"jobID"] = representation[@"id"];
        attributes[@"title"] = representation[@"title"];
        attributes[@"contentType"] = representation[@"contentType"];
        attributes[@"message"] = representation[@"message"];
        attributes[@"created"] = [NSDate dateWithTimeIntervalSince1970:[representation[@"createTime"] doubleValue]];
        
        NSDictionary *possibleStatuses = @{
            @"QUEUED" : @(CPJobStatusQueued),
            @"IN_PROGRESS" : @(CPJobStatusInProgress),
            @"DONE" : @(CPJobStatusDone),
            @"ERROR" : @(CPJobStatusError)
        };
        NSNumber *jobStatus = possibleStatuses[representation[@"status"]];
        jobStatus = jobStatus ?: @(CPJobStatusUnknown);

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