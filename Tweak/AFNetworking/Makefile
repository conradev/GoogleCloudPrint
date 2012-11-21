include theos/makefiles/common.mk

CLASS_DIR = Submodule/AFNetworking/

SUBPROJECT_NAME = AFNetworking
AFNetworking_FILES = $(CLASS_DIR)/AFHTTPClient.m $(CLASS_DIR)/AFHTTPRequestOperation.m $(CLASS_DIR)/AFJSONRequestOperation.m $(CLASS_DIR)/AFURLConnectionOperation.m
AFNetworking_CFLAGS = -fobjc-arc -I$(CLASS_DIR)
AFNetworking_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/subproject.mk
