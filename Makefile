# Clang
TARGET_CC=xcrun -sdk iphoneos clang
TARGET_CXX=xcrun -sdk iphoneos clang++
TARGET_LD=xcrun -sdk iphoneos clang++

SUBPROJECTS = Tweak

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
