#import "PFFilterTableViewController.h"
#import "PFFilterManager.h"
#import "Model/PFFilter.h"
#import "SafeFunctions.h"

@interface FLEXObjectExplorerViewController: UIViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)shouldShowDescription;

@property (nonatomic, readonly) id object;

@end

%hook FLEXObjectExplorerViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (![self shouldShowDescription] || !self.object) {
        return %orig;
    }

    if (section == 0) {
        return %orig + 1;
    }
    return %orig;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self shouldShowDescription] || !self.object) {
        return %orig;
    }

    if (indexPath.section == 0) {
        if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
            UITableViewCell *cell = [[[UITableViewCell alloc] init] autorelease];
        
            cell.textLabel.text = @"Hidden Variations";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            if ([[PFFilterManager sharedManager] enabled]) {
                cell.textLabel.textColor = [UIColor blackColor];
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            } else {
                cell.textLabel.textColor = [UIColor lightGrayColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }

            return cell;
        }
    }
    return %orig;
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self shouldShowDescription] || !self.object) {
        return %orig;
    }

    if (indexPath.section == 0 && indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
        return NO;
    }
    return %orig;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self shouldShowDescription] || !self.object) {
        return %orig;
    }

    if (indexPath.section == 0 && indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
        return [[PFFilterManager sharedManager] enabled];
    }
    return %orig;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self shouldShowDescription] || !self.object) {
        return %orig;
    }

    if (indexPath.section == 0 && indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
        return 44.0;
    }
    return %orig;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self shouldShowDescription] || !self.object) {
        %orig;
    } else if (indexPath.section == 0 && indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
        if ([[PFFilterManager sharedManager] enabled]) {
            PFFilterTableViewController *ctrl = [[[PFFilterTableViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
            ctrl.viewToExplore = self.object;
            ctrl.manager = [PFFilterManager sharedManager];

            [self.navigationController pushViewController:ctrl animated:YES];
        }

        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        %orig;
    }
}

%end

@interface UIView ()

@property (nonatomic, assign) BOOL pf_hide;
-(id)_viewControllerForAncestor;

-(BOOL)pf_shouldHide;
-(void)pf_hideIfNecessary;

@end

@interface UIViewController ()

@property (getter=_window,nonatomic,readonly) UIWindow *window;

@end

%hook UIView

%property (nonatomic, assign) BOOL pf_hide;

%new
-(BOOL)pf_shouldHide {
    if (!self.superview && ![self isKindOfClass:[UIWindow class]]) {
        return NO;
    }

    UIViewController *vc = [self _viewControllerForAncestor];

    Class flexWindowClass = NSClassFromString(@"FLEXWindow");

    UIView *theView = self;
    UIView *lastSuperview = self;

    while (!vc && ![theView valueForKey:@"_window"] && theView) {
        vc = [theView.superview _viewControllerForAncestor];
        if (theView.superview) {
            lastSuperview = theView.superview;
        }
        theView = theView.superview;
    }

    if (!lastSuperview.superview && ![lastSuperview isKindOfClass:[UIWindow class]]) {
        return NO;
    }
    
    if ([vc._window isKindOfClass:flexWindowClass] || [[lastSuperview valueForKey:@"_window"] isKindOfClass:flexWindowClass] || [self isKindOfClass:flexWindowClass]) {
        return NO;
    }

    NSString *frameString = [NSString stringWithFormat:@"%@", [self valueForKey:@"frame"]];

    PFFilter *filter = [[PFFilterManager sharedManager] filterForClass:[self class] frame:frameString];

    BOOL shouldHide = NO;

    if (filter) {
        shouldHide = YES;

        for (PFProperty *prop in filter.properties) {
            @try {
                NSString *value = [NSString stringWithFormat:@"%@", [self valueForKeyPath:prop.key]];

                if (prop.equals) {
                    if (![value isEqual:prop.value]) {
                        shouldHide = NO;

                        break;
                    }
                } else {
                    if ([value rangeOfString:prop.value].location == NSNotFound) {
                        shouldHide = NO;

                        break;
                    }
                }
            } @catch (NSException *exception) {
                
            }
        }
    }

    return shouldHide;
}

%new
-(void)pf_hideIfNecessary {
    if (self.alpha != 0.0 && [self pf_shouldHide]) {
        self.pf_hide = YES;
        self.alpha = 0.0;
    } else {
        self.pf_hide = NO;
    }
}

-(void)setBounds:(CGRect)arg1 {
    %orig;

    [self pf_hideIfNecessary];
}

-(void)setCenter:(CGPoint)arg1 {
    %orig;

    [self pf_hideIfNecessary];
}

-(void)setFrame:(CGRect)arg1 {
    %orig;

    [self pf_hideIfNecessary];
}

-(void)layoutSubviews {
    %orig;

    [self pf_hideIfNecessary];
}

-(void)setAlpha:(double)arg1 {
    if (self.pf_hide) {
        self.pf_hide = NO;
        %orig(0.0);
    } else if ([self pf_shouldHide]) {
        %orig(0.0);
    } else {
        %orig;
    }
}

-(void)setHidden:(BOOL)arg1 {
    %orig;

    [self pf_hideIfNecessary];
}

%end

%ctor {
    BOOL isSpringBoard = [safe_getBundleIdentifier() isEqual:@"com.apple.springboard"];
    BOOL shouldInit = NO;

    NSString *executablePath = safe_getExecutablePath();
    if (executablePath) {
        BOOL isApplication = [executablePath hasPrefix:@"/var/containers/Bundle/Application"] ||
                            [executablePath hasPrefix:@"/Applications"] ||
                            [executablePath containsString:@"/procursus/Applications"] ||
                            [executablePath hasSuffix:@"CoreServices/SpringBoard.app/SpringBoard"];
        shouldInit = isSpringBoard || isApplication;
        if (shouldInit) {
            %init;
        }
    }

    if (isSpringBoard) {
        [[PFFilterManager sharedManager] initForSpringBoard];
    }
}
