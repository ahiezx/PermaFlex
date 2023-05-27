#import "SafeFunctions.h"

extern char** *_NSGetArgv();

NSString *safe_getExecutablePath() {
	char *executablePathC = **_NSGetArgv();
	return [NSString stringWithUTF8String:executablePathC];
}

NSString *safe_getBundleIdentifier() {
	CFBundleRef mainBundle = CFBundleGetMainBundle();

	if (mainBundle != NULL) {
		CFStringRef bundleIdentifierCF = CFBundleGetIdentifier(mainBundle);

		return (__bridge NSString *)bundleIdentifierCF;
	}

	return nil;
}