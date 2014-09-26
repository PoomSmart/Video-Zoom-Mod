#import <substrate.h>
#import "../PS.h"
// IMPORTANT: This tweak is compiled from the edited logos.pl, which the "re-%init error" is removed.

#define PLIST_PATH @"/var/mobile/Library/Preferences/com.PS.VideoZoomMod.plist"
#define AutoNoSwipe [[[NSDictionary dictionaryWithContentsOfFile:PLIST_PATH] objectForKey:@"AutoNoSwipe"] boolValue]

@interface PLCameraController
- (CGFloat)maximumZoomFactorForDevice:(id)device;
@end

@interface PLCameraView
- (int)cameraDevice;
- (void)_setSwipeToModeSwitchEnabled:(BOOL)enabled;
@end

%group AVCaptureDeviceFormat

%hook AVCaptureDeviceFormat

// I don't know what it is but I wanna enable this too :P
// Also it's related with video zoom according to API
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
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PLIST_PATH];
	if (dict == nil || [dict objectForKey:@"MaxFactor"] == nil)
		return 5;
	CGFloat factor = (CGFloat)[[dict objectForKey:@"MaxFactor"] floatValue];
	if (factor > 1)
		return factor;
	return 5;
}


%end

%end

%group PLCameraController

%hook PLCameraController

- (CGFloat)maximumZoomFactorForDevice:(id)device
{
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PLIST_PATH];
	if (dict == nil || [dict objectForKey:@"MaxFactor"] == nil)
		return 5;
	CGFloat factor = (CGFloat)[[dict objectForKey:@"MaxFactor"] floatValue];
	if (factor > 1)
		return factor;
	return 5;
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

%group UIImagePickerController

%hook UIImagePickerController

- (void)viewWillAppear:(BOOL)view
{
	%orig;
	if (objc_getClass("AVCaptureDeviceFormat") != NULL)
		%init(AVCaptureDeviceFormat);
	if (objc_getClass("PLCameraController") != NULL)
		%init(PLCameraController);
	if (objc_getClass("PLCameraView") != NULL)
		%init(PLCameraView);
	if (objc_getClass("CAMZoomSlider") != NULL)
		%init(CAMZoomSlider);
}

%end

%end

SInt32 (*old_MGGetSInt32Answer)(CFStringRef);
SInt32 replaced_MGGetSInt32Answer(CFStringRef string)
{
	#define k(key) CFEqual(string, CFSTR(key))
	if (k("RearFacingCameraMaxVideoZoomFactor") || k("FrontFacingCameraMaxVideoZoomFactor")) {
		NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PLIST_PATH];
		if (dict == nil || [dict objectForKey:@"MaxFactor"] == nil)
			return 5;
		CGFloat factor = (CGFloat)[[dict objectForKey:@"MaxFactor"] floatValue];
		if (factor > 1)
			return roundf(factor);
		return 5;
	}
	return old_MGGetSInt32Answer(string);
}


%ctor {
	MSHookFunction(((void *)MSFindSymbol(NULL, "_MGGetSInt32Answer")), (void *)replaced_MGGetSInt32Answer, (void **)&old_MGGetSInt32Answer);
	if (objc_getClass("AVCaptureDeviceFormat") != NULL)
		%init(AVCaptureDeviceFormat);
	if (objc_getClass("PLCameraController") != NULL)
		%init(PLCameraController);
	if (objc_getClass("PLCameraView") != NULL)
		%init(PLCameraView);
	if (objc_getClass("CAMZoomSlider") != NULL)
		%init(CAMZoomSlider);
	if (objc_getClass("UIImagePickerController") != NULL)
		%init(UIImagePickerController);
}
