TARGET := iphone:clang:13.3.1
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SonyfyApp
SonyfyApp_FILES = Tweak.xm
SonyfyApp_CFLAGS = -fobjc-arc -std=c++17

include $(THEOS_MAKE_PATH)/tweak.mk