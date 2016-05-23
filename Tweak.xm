#import <substrate.h>
#import "../PS.h"

#define PLIST_PATH @"/var/mobile/Library/Preferences/com.PS.VideoZoomMod.plist"
#define AutoNoSwipe [[NSDictionary dictionaryWithContentsOfFile:PLIST_PATH][@"AutoNoSwipe"] boolValue]

static CGFloat videoMaxZoomFactor()
{
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PLIST_PATH];
	id value = dict[@"MaxFactor"];
	if (dict == nil || value == nil)
		return 5.0f;
	CGFloat factor = [value floatValue];
	if (factor > 1.0f)
		return factor;
	return 5.0f;
}

%group preiOS8

%hook AVCaptureDeviceFormat

- (BOOL)supportsVideoZoom
{
	return YES;
}

%end

%hook PLCameraController

- (CGFloat)maximumZoomFactorForDevice:(id)device
{
	return videoMaxZoomFactor();
}

- (CGFloat)minimumZoomFactorForDevice:(id)device
{
	return 1.0f;
}

%end

%hook PLCameraView

- (BOOL)_zoomIsAllowed
{
	if (self.cameraDevice == 1) {
		MSHookIvar<NSInteger>([%c(PLCameraController) sharedInstance], "_cameraDevice") = 0;
		BOOL orig = %orig;
		MSHookIvar<NSInteger>([%c(PLCameraController) sharedInstance], "_cameraDevice") = 1;
		return orig;
	}
	return %orig;
}

%end

%end

%group iOS8

%hook AVCaptureDeviceFormat_FigRecorder

- (BOOL)supportsDynamicCrop
{
	return YES;
}

- (BOOL)supportsVideoZoom
{
	return YES;
}

- (CGFloat)videoMaxZoomFactor
{
	return videoMaxZoomFactor();
}

%end

%hook CAMCaptureController

- (CGFloat)maximumZoomFactorForDevice:(id)device
{
	return videoMaxZoomFactor();
}

- (CGFloat)minimumZoomFactorForDevice:(id)device
{
	return 1.0f;
}

%end

%hook CAMCameraView

- (BOOL)_zoomIsAllowed
{
	if (self.cameraDevice == 1) {
		MSHookIvar<NSInteger>([%c(CAMCaptureController) sharedInstance], "_cameraDevice") = 0;
		BOOL orig = %orig;
		MSHookIvar<NSInteger>([%c(CAMCaptureController) sharedInstance], "_cameraDevice") = 1;
		return orig;
	}
	return %orig;
}

%end

%end

%group Common

%hook AVCaptureDeviceFormat

- (BOOL)supportsDynamicCrop
{
	return YES;
}

- (CGFloat)videoMaxZoomFactor
{
	return videoMaxZoomFactor();
}

%end

%hook CAMZoomSlider

- (void)makeVisible
{
	if (AutoNoSwipe)
		[(NSObject <cameraViewDelegate> *)[self delegate] _setSwipeToModeSwitchEnabled:NO];
	%orig;
}

- (void)_hideZoomSlider:(id)arg
{
	if (AutoNoSwipe)
		[(NSObject <cameraViewDelegate> *)[self delegate] _setSwipeToModeSwitchEnabled:YES];
	%orig;
}

%end

%end

%group mediaserverd

%hook FigCaptureSourceFormat

- (BOOL)isVideoZoomSupported
{
	return YES;
}

- (BOOL)isVideoZoomDynamicSensorCropSupported
{
	return YES;
}

%end

%end

extern "C" SInt32 MGGetSInt32Answer(CFStringRef);
MSHook(SInt32, MGGetSInt32Answer, CFStringRef string)
{
	#define k(key) CFEqual(string, CFSTR(key))
	if (k("RearFacingCameraMaxVideoZoomFactor") || k("FrontFacingCameraMaxVideoZoomFactor")) {
		SInt32 factor = roundf(videoMaxZoomFactor());
		return factor;
	}
	return _MGGetSInt32Answer(string);
}

BOOL is_mediaserverd()
{
	NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
	NSUInteger count = args.count;
	if (count != 0) {
		NSString *executablePath = args[0];
		return [[executablePath lastPathComponent] isEqualToString:@"mediaserverd"];
	}
	return NO;
}

%ctor
{
	dlopen("/System/Library/PrivateFrameworks/Celestial.framework/Celestial", RTLD_LAZY);
	%init(mediaserverd);
	if (!is_mediaserverd()) {
		dlopen("/System/Library/Frameworks/AVFoundation.framework/AVFoundation", RTLD_LAZY);
		if (isiOS9Up)
			dlopen("/System/Library/PrivateFrameworks/CameraUI.framework/CameraUI", RTLD_LAZY);
		else if (isiOS8)
			dlopen("/System/Library/PrivateFrameworks/CameraKit.framework/CameraKit", RTLD_LAZY);
		else
			dlopen("/System/Library/PrivateFrameworks/PhotoLibrary.framework/PhotoLibrary", RTLD_LAZY);
		MSHookFunction(MGGetSInt32Answer, MSHake(MGGetSInt32Answer));
		if (!isiOS9Up) {
			if (isiOS8) {
				%init(iOS8);
			} else {
				%init(preiOS8);
			}
		}
		%init(Common);
	}
}