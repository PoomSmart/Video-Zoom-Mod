#import <substrate.h>
#import "../PS.h"

#define PLIST_PATH @"/var/mobile/Library/Preferences/com.PS.VideoZoomMod.plist"
#define AutoNoSwipe [[[NSDictionary dictionaryWithContentsOfFile:PLIST_PATH] objectForKey:@"AutoNoSwipe"] boolValue]

@interface PLCameraController
- (CGFloat)maximumZoomFactorForDevice:(id)device;
@end

@interface CAMCaptureController
- (CGFloat)maximumZoomFactorForDevice:(id)device;
@end

@interface PLCameraView
- (int)cameraDevice;
- (void)_setSwipeToModeSwitchEnabled:(BOOL)enabled;
@end

@interface CAMCameraView
- (int)cameraDevice;
- (void)_setSwipeToModeSwitchEnabled:(BOOL)enabled;
@end

static CGFloat videoMaxZoomFactor()
{
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PLIST_PATH];
	id value = dict[@"MaxFactor"];
	if (dict == nil || value == nil)
		return 5;
	CGFloat factor = (CGFloat)[value floatValue];
	if (factor > 1)
		return factor;
	return 5;
}

%group AVCaptureDeviceFormat

%hook AVCaptureDeviceFormat

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
	return 1;
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
	return 1;
}

%end

%end

%group PLCameraView

%hook PLCameraView

- (BOOL)_zoomIsAllowed
{
	return self.cameraDevice == 1 ? YES : %orig;
}

%end

%end

%group CAMCameraView

%hook CAMCameraView

- (BOOL)_zoomIsAllowed
{
	return self.cameraDevice == 1 ? YES : %orig;
}

%end

%end

%group CAMZoomSlider

%hook CAMZoomSlider

- (void)makeVisible
{
	if (AutoNoSwipe)
		[[self delegate] _setSwipeToModeSwitchEnabled:NO];
	%orig;
}

- (void)_hideZoomSlider:(id)arg
{
	if (AutoNoSwipe)
		[[self delegate] _setSwipeToModeSwitchEnabled:YES];
	%orig;
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
	return old_MGGetSInt32Answer(string);
}


%ctor
{
	dlopen("/System/Library/Frameworks/AVFoundation.framework/AVFoundation", RTLD_LAZY);
	dlopen("/System/Library/PrivateFrameworks/PhotoLibrary.framework/PhotoLibrary", RTLD_LAZY);
	dlopen("/System/Library/PrivateFrameworks/CameraKit.framework/CameraKit", RTLD_LAZY);
	MSHookFunction(MGGetSInt32Answer MSHake(MGGetSInt32Answer));
	if (isiOS8) {
		%init(AVCaptureDeviceFormat_FigRecorder);
		%init(CAMCaptureController);
		%init(CAMCameraView);
	} else {
		%init(AVCaptureDeviceFormat);
		%init(PLCameraController);
		%init(PLCameraView);
	}
	%init(CAMZoomSlider);
}
