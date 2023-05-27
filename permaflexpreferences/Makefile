ARCHS = arm64e

BUNDLE_NAME = PermaFlexPreferences
PermaFlexPreferences_FILES = ../SafeFunctions.xm PFRootListController.xm PFApp.m PFAppCell.m ../PFFilterManager.xm ../Model/PFFilter.m ../Model/PFProperty.m PFClassesListController.m ../PFFilterTableViewController.m ../PFFilterDetailTableViewController.m ../Cells/PFPropertyCell.m
PermaFlexPreferences_INSTALL_PATH = /var/jb/Library/PreferenceBundles
PermaFlexPreferences_FRAMEWORKS = UIKit
PermaFlexPreferences_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/var/jb/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/var/jb/Library/PreferenceLoader/Preferences/PermaFlexPreferences.plist$(ECHO_END)
