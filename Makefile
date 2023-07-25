TARGET := iphone:clang:latest:14.0

INSTALL_TARGET_PROCESSES = YouTube

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MrBeastify-ObjC

THEOS_PACKAGE_SCHEME=rootless

MrBeastify-ObjC_FILES = $(wildcard *.x)
MrBeastify-ObjC_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
