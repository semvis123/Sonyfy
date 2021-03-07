TARGET := iphone:clang:latest:13.0
INSTALL_TARGET_PROCESSES = SpringBoard
THEOS_DEVICE_IP = 192.168.2.1
DEBUG = 1
include $(THEOS)/makefiles/common.mk
ARCHS = arm64 arm64e
TWEAK_NAME = sonyfy

sonyfy_FILES = Tweak.xm
sonyfy_CFLAGS = -fobjc-arc -std=c++17

include $(THEOS_MAKE_PATH)/tweak.mk
