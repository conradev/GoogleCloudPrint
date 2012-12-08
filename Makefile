TARGET = iphone:clang:latest:6.0
ARCHS = armv7

SUBPROJECTS = Tweak PreferenceBundle

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
