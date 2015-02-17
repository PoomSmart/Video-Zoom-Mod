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

%group AVCaptureDeviceFormat_pre8

%hook AVCaptureDeviceFormat

- (BOOL)supportsVideoZoom
{
	return YES;
}

%end

%end

%group AVCaptureDeviceFormat

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

%end

%group AVCaptureDeviceFormat_FigRecorder

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

%end

%group PLCameraController

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

%end

%group CAMCaptureController

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

%end

%group PLCameraView

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

%group CAMCameraView

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

%group CAMZoomSlider

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

%group FigCaptureSourceFormat

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
	%init(FigCaptureSourceFormat);
	if (!is_mediaserverd()) {
		dlopen("/System/Library/Frameworks/AVFoundation.framework/AVFoundation", RTLD_LAZY);
		dlopen("/System/Library/PrivateFrameworks/PhotoLibrary.framework/PhotoLibrary", RTLD_LAZY);
		dlopen("/System/Library/PrivateFrameworks/CameraKit.framework/CameraKit", RTLD_LAZY);
		MSHookFunction(MGGetSInt32Answer, MSHake(MGGetSInt32Answer));
		if (isiOS8Up) {
			%init(AVCaptureDeviceFormat_FigRecorder);
			%init(CAMCaptureController);
			%init(CAMCameraView);
		} else {
			%init(AVCaptureDeviceFormat_pre8);
			%init(PLCameraController);
			%init(PLCameraView);
		}
		%init(AVCaptureDeviceFormat);
		%init(CAMZoomSlider);
	}
}
