TARGET := iphone:clang:latest:13.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SonyfyApp
SonyfyApp_FILES = Tweak.xm
SonyfyApp_CFLAGS = -fobjc-arc -std=c++17
SonyfyApp_LIBRARIES = rocketbootstrap
SonyfyApp_PRIVATE_FRAMEWORKS = AppSupport 

include $(THEOS_MAKE_PATH)/tweak.mk