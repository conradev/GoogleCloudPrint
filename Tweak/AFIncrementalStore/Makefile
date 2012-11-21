include theos/makefiles/common.mk

CLASS_DIR = Submodule/AFIncrementalStore/

SUBPROJECT_NAME = AFIncrementalStore
AFIncrementalStore_FILES = $(CLASS_DIR)/AFIncrementalStore.m $(CLASS_DIR)/AFRESTClient.m
AFIncrementalStore_CFLAGS = -fobjc-arc -I$(CLASS_DIR) -I../AFNetworking/Submodule/AFNetworking/
AFIncrementalStore_FRAMEWORKS = CoreData

include $(THEOS_MAKE_PATH)/subproject.mk
