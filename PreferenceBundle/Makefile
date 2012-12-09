include theos/makefiles/common.mk

BUNDLE_NAME = CloudPrintSettings
CloudPrintSettings_FILES = CloudPrintSettingsController.m OAuth2AuthorizationSetup.m OAuth2AuthorizationController.m
CloudPrintSettings_CFLAGS = -fobjc-arc -I. -I../Tweak/
CloudPrintSettings_INSTALL_PATH = /Library/PreferenceBundles/
CloudPrintSettings_FRAMEWORKS = UIKit
CloudPrintSettings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk