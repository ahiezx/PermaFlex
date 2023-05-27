ARCHS = arm64e
THEOS_PACKAGE_SCHEME = rootless
TARGET = iphone:latest:14.5
SUBPROJECTS += permaflexpreferences

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PermaFlex
PermaFlex_FILES = Tweak.xm SafeFunctions.xm PFFilterTableViewController.m PFFilterDetailTableViewController.m Cells/PFPropertyCell.m Model/PFProperty.m Model/PFFilter.m PFFilterManager.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

include $(THEOS_MAKE_PATH)/aggregate.mk
