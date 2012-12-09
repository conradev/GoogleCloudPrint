#import <UIKit/UIKit.h>

#import <Preferences/PSController.h>

@class PSSpecifier;

@interface PSRootController : UINavigationController <PSController, UINavigationControllerDelegate>

+ (BOOL)processedBundle:(id)arg1 parentController:(id)arg2 parentSpecifier:(id)arg3 bundleControllers:(id *)arg4 settings:(id)arg5;
+ (id)readPreferenceValue:(PSSpecifier *)specifier;
+ (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier;
+ (void)writePreference:(PSSpecifier *)specifier;

- (id)initWithTitle:(NSString *)arg1 identifier:(id)identifier;
- (BOOL)deallocating;

- (NSArray *)specifiers;

- (void)didDismissFormSheetView;
- (void)willDismissFormSheetView;
- (void)didDismissPopupView;
- (void)willDismissPopupView;

- (void)sendWillBecomeActive;
- (void)sendWillResignActive;

- (BOOL)busy;
- (void)taskFinished:(id)task;
- (void)addTask:(id)task;
- (BOOL)taskIsRunning:(id)task;
- (NSString *)tasksDescription;

- (NSString *)aggregateDictionaryPath;
- (UIView *)contentViewForTopController;
- (void)statusBarWillChangeHeight:(NSNotification *)notification;

@end