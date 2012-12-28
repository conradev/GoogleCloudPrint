include theos/makefiles/common.mk

TWEAK_NAME = CloudPrintConnector
CloudPrintConnector_FILES = PKPrinterBrowser.x CPPrinterProxy.m
CloudPrintConnector_CFLAGS = -I.
CloudPrintConnector_PRIVATE_FRAMEWORKS = PrintKit

TOOL_NAME = cpconnectord
cpconnectord_SUBPROJECTS = AFNetworking AFIncrementalStore AFOAuth2Client
cpconnectord_FILES = main.m CloudPrintAPIClient.m GoogleOAuth2Client.m CloudPrintIncrementalStore.m CloudPrintXPCBridge.m CPPrinterProxy.m CPJob.m CPPrinter.m
cpconnectord_CFLAGS = -fobjc-arc -I. -I./AFIncrementalStore/Submodule/AFIncrementalStore -I./AFNetworking/Submodule/AFNetworking -I./AFOAuth2Client/Submodule/AFOAuth2Client -include ./AFNetworking/Prefix.pch
cpconnectord_FRAMEWORKS = Security SystemConfiguration
cpconnectord_PRIVATE_FRAMEWORKS = PrintKit
cpconnectord_INSTALL_PATH = /usr/libexec
cpconnectord_CODESIGN_FLAGS = -SEntitlements.plist

include $(THEOS_MAKE_PATH)/tool.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-cpconnectord-stage::
	$(ECHO_NOTHING)$(FAKEROOT) chown root:wheel $(THEOS_STAGING_DIR)/Library/LaunchDaemons/org.thebigboss.cpconnector.plist$(ECHO_END)
