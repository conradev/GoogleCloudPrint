#import <Foundation/NSObject.h>

@class PKPrinter;

@protocol PKPrinterBrowserDelegate
@required
-(void)addPrinter:(PKPrinter *)printer moreComing:(BOOL)coming;
-(void)removePrinter:(PKPrinter *)printer moreGoing:(BOOL)going;
@end

@interface PKPrinterBrowser : NSObject {
	id<PKPrinterBrowserDelegate> delegate;
	struct _DNSServiceRef_t* mainBrowserRef;
	struct _DNSServiceRef_t* ippBrowserRef;
	struct _DNSServiceRef_t* ippsBrowserRef;
	struct _DNSServiceRef_t* localippBrowserRef;
	struct _DNSServiceRef_t* localippsBrowserRef;
	NSMutableDictionary* printers;
	NSMutableDictionary* printersByUUID;
	NSFileHandle* handle;
	unsigned char originalCellFlag;
	unsigned char originalWifiFlag;
	id printersQueue;
	NSMutableArray* pendingList;
}

@property (nonatomic,retain) NSMutableDictionary* printers;
@property (nonatomic,retain) NSMutableDictionary* printersByUUID;
@property (nonatomic,retain) NSFileHandle* handle;
@property (assign,nonatomic) id<PKPrinterBrowserDelegate> delegate;
@property (nonatomic,copy) id printersQueue;
@property (nonatomic,retain) NSMutableArray* pendingList;

+ (id)browserWithDelegate:(id)arg1;

- (id)initWithDelegate:(id)arg1;

- (void)reissueTXTQuery:(id)arg1;
- (void)queryHardcodedPrinters;
- (void)addBlockToPendingList:(id)arg1;
- (void)addLimboPrinter:(id)arg1 local:(BOOL)arg2;
- (void)addQueryResult:(id)arg1 toPrinter:(id)arg2;
- (void)removePrinter:(id)arg1;

- (void)browseCallback:(unsigned)arg1 interface:(unsigned)arg2 name:(void *)arg3 regType:(void *)arg4 domain:(void *)arg5;
- (void)browseLocalCallback:(unsigned)arg1 interface:(unsigned)arg2 name:(void *)arg3 regType:(void *)arg4 domain:(void *)arg5;
- (void)queryCallback:(int)arg1 flags:(unsigned)arg2 fullName:(void *)arg3 rdlen:(unsigned short)arg4 rdata:(const void**)arg5;

@end