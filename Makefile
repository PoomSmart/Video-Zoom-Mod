DEBUG = 0
GO_EASY_ON_ME = 1
ARCHS = armv7 arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = VideoZoomEnabler
VideoZoomEnabler_FILES = Tweak.xm
VideoZoomEnabler_LIBRARIES = MobileGestalt

include $(THEOS_MAKE_PATH)/tweak.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp -R VZM $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/VZM$(ECHO_END)
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -name .DS_Store | xargs rm -rf$(ECHO_END)
