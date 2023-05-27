#include <UIKit/UIKit.h>
#import <crt_externs.h>

extern char** *_NSGetArgv();

NSString *safe_getExecutablePath();

NSString *safe_getBundleIdentifier();