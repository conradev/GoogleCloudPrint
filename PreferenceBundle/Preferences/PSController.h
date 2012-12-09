#import <Foundation/NSObject.h>

#import <Preferences/PSSpecifier.h>

@class PSRootController;

@protocol PSController <NSObject>

@property (retain, nonatomic) PSSpecifier *specifier;
@property (assign, nonatomic) PSRootController *rootController;
@property (assign, nonatomic) UIViewController<PSController> *parentController;

- (void)willBecomeActive;
- (void)willResignActive;
- (void)didWake;
- (void)didUnlock;
- (void)willUnlock;
- (void)didLock;

- (BOOL)canBeShownFromSuspendedState;
- (void)suspend;

- (void)statusBarWillAnimateByHeight:(float)height;
- (void)pushController:(id<PSController>)controller;
- (void)handleURL:(NSURL *)url;

- (id)readPreferenceValue:(PSSpecifier *)specifier;
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier;

@end