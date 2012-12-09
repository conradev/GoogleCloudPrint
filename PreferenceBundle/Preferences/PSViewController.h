#import <UIKit/UIKit.h>

#import <Preferences/PSController.h>

@interface PSViewController : UIViewController <PSController>

- (void)formSheetViewDidDisappear;
- (void)formSheetViewWillDisappear;
- (void)popupViewDidDisappear;
- (void)popupViewWillDisappear;

@end