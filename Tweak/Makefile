include theos/makefiles/common.mk

TWEAK_NAME = CloudPrintConnector
CloudPrintConnector_FILES = PKPrinterBrowser.x CPPrinterProxy.x
CloudPrintConnector_CFLAGS = -I.
CloudPrintConnector_PRIVATE_FRAMEWORKS = PrintKit

TOOL_NAME = cpconnectord
cpconnectord_SUBPROJECTS = AFNetworking AFIncrementalStore AFOAuth2Client
cpconnectord_FILES = main.m CloudPrintAPIClient.m CloudPrintIncrementalStore.m CloudPrintXPCBridge.x CPPrinterProxy.x CPJob.m CPPrinter.m
cpconnectord_CFLAGS = -fobjc-arc -I. -I./AFIncrementalStore/Submodule/AFIncrementalStore -I./AFNetworking/Submodule/AFNetworking
cpconnectord_LDFLAGS = -lsubstrate
cpconnectord_PRIVATE_FRAMEWORKS = PrintKit
cpconnectord_INSTALL_PATH = /usr/libexec

include $(THEOS_MAKE_PATH)/tool.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-cpconnectord-stage::
	$(ECHO_NOTHING)$(FAKEROOT) chown root:wheel $(THEOS_STAGING_DIR)/Library/LaunchDaemons/org.thebigboss.cpconnector.plist$(ECHO_END)
