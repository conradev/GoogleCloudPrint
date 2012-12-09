#import <Preferences/PSViewController.h>

@protocol PSViewControllerOffsetProtocol
- (float)verticalContentOffset;
- (void)setDesiredVerticalContentOffsetItemNamed:(NSString *)name;
- (void)setDesiredVerticalContentOffset:(float)offset;
@end

@interface PSTableCell : UITableViewCell
+ (int)cellTypeFromString:(NSString *)cellType;
@end

@interface PSListController : PSViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIAlertViewDelegate, UIPopoverControllerDelegate, PSViewControllerOffsetProtocol>

@property(nonatomic) BOOL forceSynchronousIconLoadForCreatedCells;

+ (BOOL)displaysButtonBar;

- (id)initForContentSize:(CGSize)size;

- (id)specifiers;
- (void)reloadSpecifiers;
- (id)loadSpecifiersFromPlistName:(id)arg1 target:(id)arg2;

- (id)bundle;
- (id)table;

- (NSString *)specifierID;
- (void)setSpecifierID:(NSString *)specID;
- (void)migrateSpecifierMetadataFrom:(id)arg1 to:(id)arg2;
- (void)reload;
- (void)loseFocus;

- (void)returnPressedAtEnd;
- (void)prepareSpecifiersMetadata;
- (id)findFirstVisibleResponder;
- (BOOL)shouldSelectResponderOnAppearance;
- (void)createPrequeuedPSTableCells:(unsigned int)arg1 etched:(BOOL)arg2;
- (BOOL)shouldReloadSpecifiersOnResume;
- (void)reloadIconForSpecifierForBundle:(id)arg1;
- (void)pushController:(id)arg1 animate:(BOOL)arg2;
- (void)lazyLoadBundle:(id)arg1;
- (id)popupStylePopoverController;
- (void)showPINSheet:(id)arg1;

- (Class)tableViewClass;
- (Class)backgroundViewClass;
- (int)tableStyle;
- (id)tableBackgroundColor;
- (id)contentScrollView;

- (void)popoverController:(id)arg1 animationCompleted:(int)arg2;
- (void)dismissPopoverAnimated:(BOOL)animate;
- (void)dismissPopover;

- (BOOL)containsSpecifier:(PSSpecifier *)spec;
- (void)selectRowForSpecifier:(PSSpecifier *)spec;
- (id)specifierForID:(NSString *)specID;
- (int)indexForIndexPath:(NSIndexPath *)indexPath;
- (id)indexPathForIndex:(int)index;
- (id)indexPathForSpecifier:(PSSpecifier *)spec;
- (id)specifierAtIndex:(int)index;
- (int)indexOfSpecifier:(PSSpecifier *)spec;
- (int)indexOfSpecifierID:(NSString *)specID;

- (void)createGroupIndices;
- (int)numberOfGroups;
- (int)indexOfGroup:(int)group;
- (id)specifiersInGroup:(int)group;
- (int)rowsForGroup:(int)group;
- (int)indexForRow:(int)row inGroup:(int)group;

- (BOOL)getGroup:(int *)group row:(int *)row ofSpecifierAtIndex:(int)index;
- (BOOL)getGroup:(int *)group row:(int *)row ofSpecifier:(PSSpecifier *)spec;
- (BOOL)getGroup:(int *)group row:(int *)row ofSpecifierID:(NSString *)specID;

- (id)controllerForSpecifier:(PSSpecifier *)spec;
- (id)controllerForRowAtIndexPath:(id)arg1;

- (void)confirmationViewCancelledForSpecifier:(PSSpecifier *)spec;
- (void)confirmationViewAcceptedForSpecifier:(PSSpecifier *)spec;

- (void)showConfirmationSheetForSpecifier:(PSSpecifier *)spec;
- (void)showConfirmationViewForSpecifier:(PSSpecifier *)spec;
- (void)showConfirmationViewForSpecifier:(PSSpecifier *)spec useAlert:(BOOL)arg2 swapAlertButtons:(BOOL)arg3;

- (void)updateSpecifiersInRange:(NSRange)range withSpecifiers:(id)arg2;
- (void)updateSpecifiers:(id)arg1 withSpecifiers:(id)arg2;

- (void)reloadSpecifierID:(NSString *)specID;
- (void)reloadSpecifierID:(NSString *)specID animated:(BOOL)animate;
- (void)reloadSpecifier:(PSSpecifier *)spec;
- (void)reloadSpecifier:(PSSpecifier *)spec animated:(BOOL)animate;
- (void)reloadSpecifierAtIndex:(int)index;
- (void)reloadSpecifierAtIndex:(int)index animated:(BOOL)animate;

- (void)addSpecifiersFromArray:(id)arg1 animated:(BOOL)animate;
- (void)addSpecifiersFromArray:(id)arg1;
- (void)addSpecifier:(PSSpecifier *)spec animated:(BOOL)animate;
- (void)addSpecifier:(PSSpecifier *)spec;

- (void)insertSpecifier:(PSSpecifier *)spec atEndOfGroup:(int)group;
- (void)insertSpecifier:(PSSpecifier *)spec afterSpecifierID:(NSString *)specID;
- (void)insertSpecifier:(PSSpecifier *)spec afterSpecifier:(PSSpecifier *)spec;
- (void)insertSpecifier:(PSSpecifier *)spec atIndex:(int)index;
- (void)insertSpecifier:(PSSpecifier *)spec atEndOfGroup:(int)group animated:(BOOL)animate;
- (void)insertSpecifier:(PSSpecifier *)spec afterSpecifierID:(NSString *)specID animated:(BOOL)animate;
- (void)insertSpecifier:(PSSpecifier *)spec afterSpecifier:(PSSpecifier *)spec animated:(BOOL)animate;
- (void)insertSpecifier:(PSSpecifier *)spec atIndex:(int)index animated:(BOOL)animate;

- (void)removeLastSpecifieranimated:(BOOL)animate;
- (void)removeLastSpecifier;
- (void)removeSpecifierAtIndex:(int)index;
- (void)removeSpecifierID:(NSString *)specID;
- (void)removeSpecifier:(PSSpecifier *)spec;
- (void)removeSpecifierAtIndex:(int)index animated:(BOOL)animate;
- (void)removeSpecifierID:(NSString *)specID animated:(BOOL)animate;
- (void)removeSpecifier:(PSSpecifier *)spec animated:(BOOL)animate;

- (void)replaceContiguousSpecifiers:(NSArray *)specs withSpecifiers:(id)arg2 animated:(BOOL)animate;
- (void)replaceContiguousSpecifiers:(NSArray *)specs withSpecifiers:(id)arg2;

- (void)insertContiguousSpecifiers:(NSArray *)specs atEndOfGroup:(int)group;
- (void)insertContiguousSpecifiers:(NSArray *)specs afterSpecifierID:(NSString *)specID;
- (void)insertContiguousSpecifiers:(NSArray *)specs afterSpecifier:(PSSpecifier *)spec;
- (void)insertContiguousSpecifiers:(NSArray *)specs atIndex:(int)index;
- (void)insertContiguousSpecifiers:(NSArray *)specs atEndOfGroup:(int)group animated:(BOOL)animate;
- (void)insertContiguousSpecifiers:(NSArray *)specs afterSpecifierID:(NSString *)specID animated:(BOOL)animate;
- (void)insertContiguousSpecifiers:(NSArray *)specs afterSpecifier:(PSSpecifier *)spec animated:(BOOL)animate;
- (void)insertContiguousSpecifiers:(NSArray *)specs atIndex:(int)index animated:(BOOL)animate;

- (void)removeContiguousSpecifiers:(NSArray *)specs;
- (void)removeContiguousSpecifiers:(NSArray *)specs animated:(BOOL)animate;

- (BOOL)performConfirmationCancelActionForSpecifier:(PSSpecifier *)spec;
- (BOOL)performConfirmationActionForSpecifier:(PSSpecifier *)spec;
- (BOOL)performButtonActionForSpecifier:(PSSpecifier *)spec;
- (BOOL)performLoadActionForSpecifier:(PSSpecifier *)spec;
- (BOOL)performActionForSpecifier:(PSSpecifier *)spec;

- (void)setCachesCells:(BOOL)cache;
- (void)setReusesCells:(BOOL)reuse;
- (id)cachedCellForSpecifierID:(NSString *)specID;
- (id)cachedCellForSpecifier:(PSSpecifier *)spec;
- (void)clearCache;

@end