TARGET := iphone:clang:latest:14.0


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MrBeastify-ObjC

THEOS_PACKAGE_SCHEME=rootless

MrBeastify-ObjC_FILES = Tweak.x
MrBeastify-ObjC_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
