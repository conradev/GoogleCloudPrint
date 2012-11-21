//
//  CPPrinterProxy.m
//  GoogleCloudPrint
//
//  Created by Conrad Kramer on 10/21/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import <PrintKit/PKPrinter.h>
#import <PrintKit/PKPrintSettings.h>

#import "CPPrinter.h"
#import "CPPrinterProxy.h"

extern NSString const *PKFileTypePDF;
extern NSString const *PKFileTypeJPEG;
extern NSString const *PKFileTypePNG;

@interface CPPrinterProxy (Internal)
@property (retain, nonatomic, getter=__cloudprint_displayName, setter=__cloudprint_set_displayName:) NSString *cloudprintDisplayName;
@property (retain, nonatomic, getter=__cloudprint_description, setter=__cloudprint_set_description:) NSString *cloudprintDescription;
@end

static char identifierKey;
static char displayNameKey;
static char descriptionKey;

%subclass CPPrinterProxy: PKPrinter <NSSecureCoding>

#pragma mark - Properties

%new(v@:@)
- (void)__cloudprint_set_identifier:(NSString *)identifier {
    objc_setAssociatedObject(self, &identifierKey, identifier, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new(@@:)
- (id)__cloudprint_identifier {
    return objc_getAssociatedObject(self, &identifierKey);
}

%new(v@:@)
- (void)__cloudprint_set_displayName:(NSString *)displayName {
    objc_setAssociatedObject(self, &displayNameKey, displayName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new(@@:)
- (id)__cloudprint_displayName {
    return objc_getAssociatedObject(self, &displayNameKey);
}

%new(v@:@)
- (void)__cloudprint_set_description:(NSString *)description {
    objc_setAssociatedObject(self, &descriptionKey, description, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new(@@:)
- (id)__cloudprint_description {
    return objc_getAssociatedObject(self, &descriptionKey);
}

#pragma mark - NSSecureCoding

%new(c@:)
+ (BOOL)supportsSecureCoding {
    return YES;
}

%new(@@:@)
- (id)initWithCoder:(NSCoder *)decoder {
    NSString *name = [decoder decodeObjectOfClass:[NSString class] forKey:@"name"];
    if ((self = [self initWithName:name TXTRecord:nil])) {
        self.cloudprintDisplayName = [decoder decodeObjectOfClass:[NSString class] forKey:@"displayName"];
        self.cloudprintDescription = [decoder decodeObjectOfClass:[NSString class] forKey:@"cloudprintDescription"];
        self.cloudprintID = [decoder decodeObjectOfClass:[NSString class] forKey:@"cloudprintID"];
    }
    
    return self;
}

%new(v@:@)
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.cloudprintDisplayName forKey:@"displayName"];
    [encoder encodeObject:self.cloudprintDescription forKey:@"cloudprintDescription"];
    [encoder encodeObject:self.cloudprintID forKey:@"cloudprintID"];
}

#pragma mark External Interface

%new(@@:@)
- (id)initWithPrinter:(CPPrinter *)printer {
    if ((self = [self initWithName:printer.name TXTRecord:nil])) {
        self.cloudprintID = printer.printerID;
        self.cloudprintDisplayName = printer.displayName;
        self.cloudprintDescription = printer.printerDescription;
    }
    
    return self;
}

#pragma mark - Overridden property values

- (NSString *)displayName {
    return self.cloudprintDisplayName;
}

- (id)location {
    return self.cloudprintDescription;
}

- (BOOL)hasPrintInfoSupported {
    return YES;
}

- (NSDictionary *)printInfoSupported {
    NSMutableDictionary *orig = [NSMutableDictionary dictionaryWithDictionary:%orig];
    orig[@"document-format"] = @[ PKFileTypePDF, PKFileTypeJPEG, PKFileTypePNG ];
    return [NSDictionary dictionaryWithDictionary:orig];
}

#pragma mark - Print compatibility

- (NSString *)localName {
    // Name as identified by printd, or, rather, CUPS.
    // The super implementation tries to add the printer to CUPS if it has not already been added
    // We don't want this
    
    return nil;
}

- (int)printURL:(NSURL *)url ofType:(NSString *)contentType printSettings:(PKPrintSettings *)printSettings { 
    NSData *fileData = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:nil];
    NSLog(@"I has data! %@ %@ %@", fileData, contentType, printSettings.dict);
    
    /*
    
     I has data! (null) image/jpeg {
	    "com.apple.page-scaling" = "scale-down-only";
	    "com.apple.thumbnail-position" = center;
	    copies = 1;
	    "job-name" = Photos;
	    "print-color-mode" = color;
	    "print-quality" = 5;
	    sides = "one-sided";
	}
    */
    
    return 0;
}

- (int)startJob:(PKPrintSettings *)printSettings ofType:(NSString *)contentType {
    NSLog(@"I has job! %@ %@", contentType, printSettings.dict);
    
    return 0;
}

- (int)sendData:(const char *)bytes ofLength:(int)length {
    NSData *data = [NSData dataWithBytes:bytes length:length]; // To copy, or not to copy!
    return 0;
}

- (int)finishJob {
    
}

- (int)abortJob {

}

%end

%group Log
%hook CPPrinterProxy
- (void)setTXTRecord:(NSDictionary *)TXTRecord { %log; %orig; }
- (NSDictionary *)TXTRecord { %log; NSDictionary * r = %orig; NSLog(@" = %@", r); return r; }
- (void)setScheme:(NSString *)scheme { %log; %orig; }
- (NSString *)scheme { %log; NSString * r = %orig; NSLog(@" = %@", r); return r; }
- (void)setHostname:(NSString *)hostname { %log; %orig; }
- (NSString *)hostname { %log; NSString * r = %orig; NSLog(@" = %@", r); return r; }
- (void)setPort:(NSNumber *)port { %log; %orig; }
- (NSNumber *)port { %log; NSNumber * r = %orig; NSLog(@" = %@", r); return r; }
- (NSString *)name { %log; NSString * r = %orig; NSLog(@" = %@", r); return r; }
- (void)setUuid:(NSString *)uuid { %log; %orig; }
- (NSString *)uuid { %log; NSString * r = %orig; NSLog(@" = %@", r); return r; }
- (void)setPrintInfoSupported:(NSDictionary *)printInfoSupported { %log; %orig; }
- (NSDictionary *)printInfoSupported { %log; NSDictionary * r = %orig; NSLog(@" = %@", r); return r; }
+(BOOL)printerLookupWithName:(id)arg1 andTimeout:(double)arg2 { %log; BOOL r = %orig; NSLog(@" = %d", r); return r; }
+(id)printerWithName:(id)arg1 { %log; id r = %orig; NSLog(@" = %@", r); return r; }
+(BOOL)urfIsOptional { %log; BOOL r = %orig; NSLog(@" = %d", r); return r; }
+(id)requiredPDL { %log; id r = %orig; NSLog(@" = %@", r); return r; }
+(id)hardcodedURIs { %log; id r = %orig; NSLog(@" = %@", r); return r; }
+(id)nameForHardcodedURI:(id)arg1 { %log; id r = %orig; NSLog(@" = %@", r); return r; }
+(struct _ipp_s*)getAttributes:(void**)arg1 count:(int)arg2 fromURI:(id)arg3 { %log; struct _ipp_s* r = %orig; NSLog(@" = %p", r); return r; }
-(id)initWithName:(id)arg1 TXT:(id)arg2 { %log; id r = %orig; NSLog(@" = %@", r); return r; }
-(id)initWithName:(id)arg1 TXTRecord:(id)arg2 { %log; id r = %orig; NSLog(@" = %@", r); return r; }
-(void)setPrivateObject:(id)arg1 forKey:(id)arg2 { %log; %orig; }
-(id)privateObjectForKey:(id)arg1 { %log; id r = %orig; NSLog(@" = %@", r); return r; }
-(id)displayName { %log; id r = %orig; NSLog(@" = %@", r); return r; }
-(id)localName { %log; id r = %orig; NSLog(@" = %@", r); return r; }
-(id)location { %log; id r = %orig; NSLog(@" = %@", r); return r; }
-(BOOL)isBonjour { %log; BOOL r = %orig; NSLog(@" = %d", r); return r; }
-(BOOL)resolveWithTimeout:(int)arg1 { %log; BOOL r = %orig; NSLog(@" = %d", r); return r; }
-(void)resolve { %log; %orig; }
-(void)setAccessStateFromTXT:(id)arg1 { %log; %orig; }
-(BOOL)knowsReadyPaperList { %log; BOOL r = %orig; NSLog(@" = %d", r); return r; }
-(BOOL)isPaperReady:(id)arg1 { %log; BOOL r = %orig; NSLog(@" = %d", r); return r; }
-(id)paperListForDuplexMode:(id)arg1 { %log; id r = %orig; NSLog(@" = %@", r); return r; }
-(id)matchedPaper:(id)arg1 preferBorderless:(BOOL)arg2 withDuplexMode:(id)arg3 didMatch:(BOOL*)arg4 { %log; id r = %orig; NSLog(@" = %@", r); return r; }
-(void)cancelUnlock { %log; %orig; }
-(void)unlockWithCompletionHandler:(id)arg1 { %log; %orig; }
-(int)printURL:(id)arg1 ofType:(id)arg2 printSettings:(id)arg3 { %log; int r = %orig; NSLog(@" = %d", r); return r; }
-(int)startJob:(id)arg1 ofType:(id)arg2 { %log; int r = %orig; NSLog(@" = %d", r); return r; }
-(struct _ipp_s*)createRequest:(id)arg1 ofType:(id)arg2 url:(id)arg3 { %log; struct _ipp_s* r = %orig; NSLog(@" = %p", r); return r; }
-(struct _ipp_s*)getPrinterAttributes { %log; struct _ipp_s* r = %orig; NSLog(@" = %p", r); return r; }
-(int)sendData:(void *)arg1 ofLength:(int)arg2 { %log; int r = %orig; NSLog(@" = %d", r); return r; }
-(int)finishJob { %log; int r = %orig; NSLog(@" = %d", r); return r; }
-(int)finalizeJob:(int)arg1 { %log; int r = %orig; NSLog(@" = %d", r); return r; }
-(int)abortJob { %log; int r = %orig; NSLog(@" = %d", r); return r; }
-(void)updateType { %log; %orig; }
-(void)reconfirmWithForce:(BOOL)arg1 { %log; %orig; }
-(void)aggdAppsAndPrinters { %log; %orig; }
-(int)feedOrientation:(id)arg1 { %log; int r = %orig; NSLog(@" = %d", r); return r; }
-(void)identifySelf { %log; %orig; }
-(void)checkOperations:(struct _ipp_s*)arg1 { %log; %orig; }
-(struct _ipp_s*)newMediaColFromPaper:(id)arg1 Source:(id)arg2 Type:(id)arg3 DoMargins:(BOOL)arg4 { %log; struct _ipp_s* r = %orig; NSLog(@" = %p", r); return r; }
%end
%end

%ctor {
    if (!objc_getClass("CPPrinterProxy")) {
        %init;
        %init(Log);
    }
}