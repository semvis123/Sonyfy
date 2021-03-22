TARGET := iphone:clang:latest:13.0
INSTALL_TARGET_PROCESSES = SpringBoard
THEOS_DEVICE_IP = 192.168.2.1
DEBUG = 1
include $(THEOS)/makefiles/common.mk
ARCHS = arm64 arm64e
TWEAK_NAME = Sonyfy
SUBPROJECTS += SonyfyApp
Sonyfy_FILES = Tweak.xm
Sonyfy_CFLAGS = -fobjc-arc -std=c++17
Sonyfy_LIBRARIES = rocketbootstrap
Sonyfy_FRAMEWORKS = Foundation CoreFoundation AVFoundation
Sonyfy_PRIVATE_FRAMEWORKS = AppSupport 
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
