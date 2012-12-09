#import <Preferences/PSRootController.h>

extern NSString * const PSSetupCustomClassKey;

@class PSSpecifier;

@interface PSSetupController : PSRootController

- (BOOL)popupStyleIsModal;
- (BOOL)usePopupStyle;

- (id)controller;
- (void)setupController;
- (void)popControllerOnParent;
- (void)pushControllerOnParentWithSpecifier:(PSSpecifier *)specifier;
- (void)dismiss;
- (void)dismissAnimated:(BOOL)animated;

@end