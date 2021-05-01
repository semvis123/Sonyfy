TARGET := iphone:clang:14.4

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = sonyfyPreferences

sonyfyPreferences_FILES = SPBRootListController.m
sonyfyPreferences_FRAMEWORKS = UIKit
sonyfyPreferences_PRIVATE_FRAMEWORKS = Preferences
sonyfyPreferences_INSTALL_PATH = /Library/PreferenceBundles
sonyfyPreferences_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
