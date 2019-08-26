// Stops the bluring effect from happening in the control center
%hook CCUIHeaderPocketView
-(void)setBackgroundAlpha:(double)arg1 {
    arg1 = 0.0;
    %orig;
}
%end

// Removes the bottom inset
%hook UIWindow
-(UIEdgeInsets )safeAreaInsets {
    UIEdgeInsets oldInsets = %orig;
    UIEdgeInsets newInsets = UIEdgeInsetsMake(oldInsets.top,oldInsets.left,0.0,oldInsets.right);
    return newInsets;
}
%end

// All the hooks for the iPhone X statusbar.
%group StatusBarX

%hook UIStatusBar_Base
+ (Class)_implementationClass {
    return NSClassFromString(@"UIStatusBar_Modern");
}
+ (void)_setImplementationClass:(Class)arg1 {
    %orig(NSClassFromString(@"UIStatusBar_Modern"));
}
+ (Class)_statusBarImplementationClass {
	return NSClassFromString(@"UIStatusBar_Modern");
}
%end

// Fixes the Instagram Status Bar
@interface IGNavigationBar : UIView
@end

%hook IGNavigationBar
- (void)layoutSubviews {
    %orig;
    CGRect _frame = self.frame;
    _frame.origin.y = 20;
    self.frame = _frame;
}
%end

%hook UIStatusBarWindow
+ (void)setStatusBar:(Class)arg1 {
    %orig(NSClassFromString(@"UIStatusBar_Modern"));
}
%end

// Fix control center from crashing on iOS 12.
%hook _UIStatusBarVisualProvider_iOS
+ (Class)class {
    return NSClassFromString(@"_UIStatusBarVisualProvider_Split58");
}
%end

// Fix status bar in YouTube.
@interface YTHeaderContentComboView : UIView
- (UIView*)headerView;
@end

%hook YTHeaderContentComboView
- (void)layoutSubviews {
    %orig;
        CGRect headerViewFrame = [[self headerView] frame];
        headerViewFrame.origin.y += 20;
        [[self headerView] setFrame:headerViewFrame];
        [self setBackgroundColor:[[self headerView] backgroundColor]];
    }
%end
%end

// Hides the homebar in the springboard
%hook MTLumaDodgePillView
- (id)initWithFrame:(struct CGRect)arg1 {
	return NULL;
}
%end

// Enables Lockscreen shortcurs
%hook SBDashBoardQuickActionsViewController
+ (BOOL)deviceSupportsButtons {
	return YES;
}
- (BOOL)hasCamera {
	return YES;
}
- (BOOL)hasFlashlight {
	return YES;
}
%end

// Moves Lockscreen shortcuts to where they should be
@interface UIView (SpringBoardAdditions)
- (void)sb_removeAllSubviews;
@end

@interface SBDashBoardQuickActionsView : UIView
- (void)_layoutQuickActionButtons;
@end

%hook SBDashBoardQuickActionsView
- (void)_layoutQuickActionButtons {
	%orig;
	for (UIView *subview in self.subviews) {
		if (subview.frame.origin.x < 50) {
			CGRect flashlight = subview.frame;
			CGFloat flashlightOffset = subview.alpha > 0 ? (flashlight.origin.y - 90) : flashlight.origin.y;
			subview.frame = CGRectMake(46, flashlightOffset, 50, 50);
		} else {
			CGFloat _screenWidth = [UIScreen mainScreen].bounds.size.width;
			CGRect camera = subview.frame;
			CGFloat cameraOffset = subview.alpha > 0 ? (camera.origin.y - 90) : camera.origin.y;
			subview.frame = CGRectMake(_screenWidth - 96, cameraOffset, 50, 50);
		}
        #pragma clang diagnostic ignored "-Wunused-value"
        [subview init];
	}
}
%end

// Brings the iPhone X Keybaord
%hook UIKeyboardImpl
+ (UIEdgeInsets)deviceSpecificPaddingForInterfaceOrientation:(long long)arg1 inputMode:(id)arg2 {
		UIEdgeInsets orig = %orig;
        orig.bottom = 40;
		return orig;
}
%end

%hook UIKeyboardDockView
- (CGRect)bounds {
		CGRect bounds = %orig;
        bounds.size.height += 20;
		return bounds;
}
%end

// Enables Floating Dock
%hook SBFloatingDockController
+ (BOOL)isFloatingDockSupported {
    return YES;
}
%end

// Enables Multitasking Capabilities 
%hook SBPlatformController
-(long long)medusaCapabilities {
    return 2;
}
%end

%hook SBMainWorkspace
-(BOOL)isMedusaEnabled {
    return YES;
}
%end

%hook SBApplication
-(BOOL)isMedusaCapable {
    return YES;
}
%end

// Allows for 5 icons on the dock
%hook SBDockIconListView
+ (NSUInteger)maxIcons {
	return 5;
}
%end

// Removes dots on Home Screen
%hook SBIconListPageControl 
- (id)initWithFrame:(CGRect)arg1 {
    return NULL;
}
%end

// Removes Icon Labels
%hook SBIconView
- (CGRect)_frameForLabel {
  return CGRectNull;
}
%end

// Plays with the icon layout
@interface SBRootIconListView : UIView
@end

%hook SBRootIconListView
-(CGFloat)verticalIconPadding {
	return 15;
}
%end 

// Allows Dragging of items
%hook UIDragInteraction 
-(bool)isEnabled {
    return YES;
}
%end 

%hook _UIDraggingSession
-(BOOL)_shouldCancelOnAppDeactivation {
    return NO;
}
%end 

// Allows items to be dragged outside of an app
%hook _UIDragSessionImpl 
-(BOOL)_draggingSession:(id)arg1 shouldCancelOnAppDeactivationWithDefault:(BOOL)arg2 {
    arg2 = NO;
    return %orig;
}
%end

// Allows photos from the photos app to be dragged
%hook PXDragAndDropSettings
- (bool)dragOutEnabled {
    return YES;
}
%end

// Adds the iPhone X Gestures
%group InsetX	

extern "C" CFPropertyListRef MGCopyAnswer(CFStringRef);

typedef unsigned long long addr_t;

static addr_t step64(const uint8_t *buf, addr_t start, size_t length, uint32_t what, uint32_t mask) {
	addr_t end = start + length;
	while (start < end) {
		uint32_t x = *(uint32_t *)(buf + start);
		if ((x & mask) == what) {
			return start;
		}
		start += 4;
	}
	return 0;
}

static addr_t find_branch64(const uint8_t *buf, addr_t start, size_t length) {
	return step64(buf, start, length, 0x14000000, 0xFC000000);
}

static addr_t follow_branch64(const uint8_t *buf, addr_t branch) {
	long long w;
	w = *(uint32_t *)(buf + branch) & 0x3FFFFFF;
	w <<= 64 - 26;
	w >>= 64 - 26 - 2;
	return branch + w;
}

static CFPropertyListRef (*orig_MGCopyAnswer_internal)(CFStringRef property, uint32_t *outTypeCode);
CFPropertyListRef new_MGCopyAnswer_internal(CFStringRef property, uint32_t *outTypeCode) {
    CFPropertyListRef r = orig_MGCopyAnswer_internal(property, outTypeCode);
	#define k(string) CFEqual(property, CFSTR(string))
     NSString* bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
if (k("oPeik/9e8lQWMszEjbPzng") || k("ArtworkTraits")) {
        CFMutableDictionaryRef copy = CFDictionaryCreateMutableCopy(NULL, 0, (CFDictionaryRef)r);
        CFRelease(r);
        CFNumberRef num;
        uint32_t deviceSubType = 0x984;
        num = CFNumberCreate(NULL, kCFNumberIntType, &deviceSubType);
        CFDictionarySetValue(copy, CFSTR("ArtworkDeviceSubType"), num);
        return copy;
} else if ((k("8olRm6C1xqr7AJGpLRnpSw") || k("PearlIDCapability")) && [bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
        return (__bridge CFPropertyListRef)@YES;
    } 
	return r;
}
%end

// Enables PiP in iOS' video player.
%group PIP
extern "C" Boolean MGGetBoolAnswer(CFStringRef);
%hookf(Boolean, MGGetBoolAnswer, CFStringRef key) {
#define keyy(key_) CFEqual(key, CFSTR(key_))
    if (keyy("nVh/gwNpy7Jv1NOk00CMrw"))
        return YES;
    return %orig;
}
%end

// Adds the Padlock to the lockscreen.
%group ProudLock
extern "C" Boolean MGGetBoolAnswer(CFStringRef);
%hookf(Boolean, MGGetBoolAnswer, CFStringRef key) {
#define keyyy(key_) CFEqual(key, CFSTR(key_))
    if (keyyy("z5G/N9jcMdgPm8UegLwbKg") || keyyy("IsEmulatedDevice"))
        return YES;
    return %orig;
}

#define CGRectSetY(rect, y) CGRectMake(rect.origin.x, y, rect.size.width, rect.size.height)

%hook SBFLockScreenDateView
- (void)layoutSubviews {
        %orig;
        UIView* timeView = MSHookIvar<UIView*>(self, "_timeLabel");
        UIView* dateSubtitleView = MSHookIvar<UIView*>(self, "_dateSubtitleView");
        UIView* customSubtitleView = MSHookIvar<UIView*>(self, "_customSubtitleView");
        [timeView setFrame:CGRectSetY(timeView.frame, timeView.frame.origin.y + 28)];
        [dateSubtitleView setFrame:CGRectSetY(dateSubtitleView.frame, dateSubtitleView.frame.origin.y + 28)];
        [customSubtitleView setFrame:CGRectSetY(customSubtitleView.frame, customSubtitleView.frame.origin.y + 28)];
}
%end

%hook SBUIBiometricResource
- (id)init {
	id r = %orig;
	
	MSHookIvar<BOOL>(r, "_hasMesaHardware") = NO;
	MSHookIvar<BOOL>(r, "_hasPearlHardware") = YES;
	
	return r;
}
%end

%hook PKGlyphView
- (void)setHidden:(BOOL)arg1 {
		arg1 = NO;
		return;
}
%end

// Move notifiications down to better fit having the Padlock on the lockscreen
%hook NCNotificationListCollectionView
- (void)setFrame:(CGRect)frame {
		frame = CGRectMake(frame.origin.x,frame.origin.y + 25,frame.size.width,frame.size.height);
		%orig(frame);
}
%end

%hook SBDashBoardAdjunctListView
- (void)setFrame:(CGRect)frame {
		frame = CGRectMake(0,frame.origin.y + 25,frame.size.width,frame.size.height);
		%orig(frame);
}

%end

// Make Settings app show Face ID instead of Touch ID
%hook PSUIPrefsListController
-(BOOL)shouldShowFaceID {
    return YES;
}
-(BOOL)shouldShowTouchID {
    return NO;
}
%end
%end

%ctor {
    @autoreleasepool {
         %init(StatusBarX);
            MSImageRef libGestalt = MSGetImageByName("/usr/lib/libMobileGestalt.dylib");

                void *MGCopyAnswerFn = MSFindSymbol(libGestalt, "_MGCopyAnswer");
                const uint8_t *MGCopyAnswer_ptr = (const uint8_t *)MGCopyAnswer;
                addr_t branch = find_branch64(MGCopyAnswer_ptr, 0, 8);
                addr_t branch_offset = follow_branch64(MGCopyAnswer_ptr, branch);
                MSHookFunction(((void *)((const uint8_t *)MGCopyAnswerFn + branch_offset)), (void *)new_MGCopyAnswer_internal, (void **)&orig_MGCopyAnswer_internal);
            
         %init(InsetX);
         %init(PIP);
         %init(ProudLock);

        %init(_ungrouped);
	}
}
