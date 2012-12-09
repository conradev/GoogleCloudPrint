#import <Foundation/NSObject.h>

@interface PSSpecifier : NSObject

+ (id)emptyGroupSpecifier;
+ (id)groupSpecifierWithName:(NSString *)name;
+ (id)preferenceSpecifierNamed:(NSString *)name target:(id)target set:(SEL)setter get:(SEL)getter detail:(Class)detailControllerClass cell:(int)cellType edit:(Class)editPaneClass;

+ (int)keyboardTypeForString:(id)arg1;
+ (int)autoCapsTypeForString:(id)arg1;
+ (int)autoCorrectionTypeForNumber:(id)arg1;

@property(nonatomic) BOOL showContentString;
@property(nonatomic) SEL controllerLoadAction;
@property(nonatomic) SEL buttonAction;
@property(nonatomic) SEL confirmationCancelAction;
@property(nonatomic) SEL confirmationAction;
@property(retain, nonatomic) NSString *name;
@property(retain, nonatomic) NSString *identifier;
@property(retain, nonatomic) NSArray *values;
@property(retain, nonatomic) NSDictionary *shortTitleDictionary;
@property(retain, nonatomic) NSDictionary *titleDictionary;
@property(retain, nonatomic) id userInfo;
@property(nonatomic) Class editPaneClass;
@property(nonatomic) int cellType;
@property(nonatomic) Class detailControllerClass;
@property(nonatomic) id target;

- (int)titleCompare:(id)arg1;
- (void)setKeyboardType:(int)arg1 autoCaps:(int)arg2 autoCorrection:(int)arg3;
- (void)setupIconImageWithPath:(id)arg1;
- (void)setupIconImageWithBundle:(id)arg1;
- (void)setValues:(id)arg1 titles:(id)arg2 shortTitles:(id)arg3;
- (void)setValues:(id)arg1 titles:(id)arg2;
- (void)loadValuesAndTitlesFromDataSource;

- (id)properties;
- (void)setProperties:(id)arg1;
- (void)removePropertyForKey:(id)arg1;
- (void)setProperty:(id)arg1 forKey:(id)arg2;
- (id)propertyForKey:(id)arg1;

@end