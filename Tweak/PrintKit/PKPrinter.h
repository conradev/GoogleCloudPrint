#import <Foundation/NSObject.h>

@interface PKPrinter : NSObject {
	NSString* name;
	int type;
	int accessState;
	NSDictionary* printInfoSupported;
	struct _http_s* job_http;
	NSMutableDictionary* privateData;
	NSMutableSet* mediaReady;
	NSMutableDictionary* specialFeedOrientation;
	int maxPDFKBytes;
	int maxJPEGKBytes;
	int maxJPEGXDimension;
	int maxJPEGYDimension;
	int maxCopies;
	int preferred_landscape;
	BOOL isLocal;
	BOOL hasIdentifyPrinterOp;
	int kind;
}

@property (retain, nonatomic) NSDictionary *TXTRecord;
@property (retain, nonatomic) NSString *scheme;
@property (retain, nonatomic) NSString *hostname;
@property (retain, nonatomic) NSNumber *port;
@property (readonly, retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSString *uuid;

@property int kind;
@property int type;
@property int accessState;

@property BOOL hasPrintInfoSupported;
@property (retain, nonatomic) NSDictionary *printInfoSupported;

@property BOOL isAdobeRGBSupported;
@property BOOL isLocal;
@property BOOL isIPPS;
@property BOOL hasIdentifyPrinterOp;

+(BOOL)printerLookupWithName:(id)arg1 andTimeout:(double)arg2;
+(id)printerWithName:(id)arg1;
+(BOOL)urfIsOptional;
+(id)requiredPDL;
+(id)hardcodedURIs;
+(id)nameForHardcodedURI:(id)arg1;
+(struct _ipp_s*)getAttributes:(void**)arg1 count:(int)arg2 fromURI:(id)arg3;

-(id)initWithName:(id)arg1 TXT:(id)arg2;
-(id)initWithName:(id)arg1 TXTRecord:(id)arg2;

-(void)setPrivateObject:(id)arg1 forKey:(id)arg2;
-(id)privateObjectForKey:(id)arg1;

-(id)displayName;
-(id)localName;
-(id)location;

-(BOOL)isBonjour;
-(BOOL)resolveWithTimeout:(int)arg1;
-(void)resolve;
-(void)setAccessStateFromTXT:(id)arg1;

-(BOOL)knowsReadyPaperList;
-(BOOL)isPaperReady:(id)arg1;
-(id)paperListForDuplexMode:(id)arg1;
-(id)matchedPaper:(id)arg1 preferBorderless:(BOOL)arg2 withDuplexMode:(id)arg3 didMatch:(BOOL*)arg4;

-(void)cancelUnlock;
-(void)unlockWithCompletionHandler:(id)arg1;

-(int)printURL:(id)arg1 ofType:(id)arg2 printSettings:(id)arg3;
-(int)startJob:(id)arg1 ofType:(id)arg2;
-(struct _ipp_s*)createRequest:(id)arg1 ofType:(id)arg2 url:(id)arg3;
-(struct _ipp_s*)getPrinterAttributes;
-(int)sendData:(void *)arg1 ofLength:(int)arg2;
-(int)finishJob;
-(int)finalizeJob:(int)arg1;
-(int)abortJob;

-(void)updateType;
-(void)reconfirmWithForce:(BOOL)arg1;
-(void)aggdAppsAndPrinters;
-(int)feedOrientation:(id)arg1;
-(void)identifySelf;
-(void)checkOperations:(struct _ipp_s*)arg1;
-(struct _ipp_s*)newMediaColFromPaper:(id)arg1 Source:(id)arg2 Type:(id)arg3 DoMargins:(BOOL)arg4;

@end