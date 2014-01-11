#import <substrate.h>
// IMPORTANT: This tweak is compiled from the edited logos.pl, which the "re-%init error" is removed.

#define PLIST_PATH @"/var/mobile/Library/Preferences/com.PS.VideoZoomMod.plist"

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
		return 5.0;
	CGFloat factor = (CGFloat)[[dict objectForKey:@"MaxFactor"] floatValue];
	if (factor > 1)
		return factor;
	return 5.0;
}


%end

%end

%group PLCameraController

%hook PLCameraController

- (CGFloat)maximumZoomFactorForDevice:(id)device
{
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PLIST_PATH];
	if (dict == nil || [dict objectForKey:@"MaxFactor"] == nil)
		return 5.0;
	CGFloat factor = (CGFloat)[[dict objectForKey:@"MaxFactor"] floatValue];
	if (factor > 1)
		return factor;
	return 5.0;
}

- (CGFloat)minimumZoomFactorForDevice:(id)device
{
	return 1.0;
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
}

%end

%end


%ctor {
	if (objc_getClass("AVCaptureDeviceFormat") != NULL)
		%init(AVCaptureDeviceFormat);
	if (objc_getClass("PLCameraController") != NULL)
		%init(PLCameraController);
	if (objc_getClass("UIImagePickerController") != NULL)
		%init(UIImagePickerController);
}
