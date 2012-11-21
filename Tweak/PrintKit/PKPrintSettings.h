#import <Foundation/NSObject.h>

@class PKPrinter, PKPaper;

@interface PKPrintSettings : NSObject {
    NSMutableDictionary *_dict;
    PKPaper *paper;
}

@property(retain, nonatomic) NSMutableDictionary *dict;
@property(retain, nonatomic) PKPaper *paper;

+ (id)default;
+ (id)photo;
+ (id)printSettingsForPrinter:(PKPrinter *)printer;

- (id)objectForKey:(id)key;
- (void)removeObjectForKey:(id)key;
- (void)setObject:(id)object forKey:(id)key;
- (id)settingsDict;

@end

