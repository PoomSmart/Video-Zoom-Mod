#import <substrate.h>
#define PLIST_PATH @"/var/mobile/Library/Preferences/com.PS.VideoZoomMod.plist"

@class AVCaptureDeviceFormat, PLCameraController, UIImagePickerController;

static BOOL (*_logos_orig$_ungrouped$AVCaptureDeviceFormat$supportsDynamicCrop)(AVCaptureDeviceFormat*, SEL);
static BOOL _logos_method$_ungrouped$AVCaptureDeviceFormat$supportsDynamicCrop(AVCaptureDeviceFormat*, SEL);

static BOOL (*_logos_orig$_ungrouped$AVCaptureDeviceFormat$supportsVideoZoom)(AVCaptureDeviceFormat*, SEL);
static BOOL _logos_method$_ungrouped$AVCaptureDeviceFormat$supportsVideoZoom(AVCaptureDeviceFormat*, SEL);

static float (*_logos_orig$_ungrouped$PLCameraController$maximumZoomFactorForDevice$)(PLCameraController*, SEL, id);
static float _logos_method$_ungrouped$PLCameraController$maximumZoomFactorForDevice$(PLCameraController*, SEL, id);

static float (*_logos_orig$_ungrouped$PLCameraController$minimumZoomFactorForDevice$)(PLCameraController*, SEL, id);
static float _logos_method$_ungrouped$PLCameraController$minimumZoomFactorForDevice$(PLCameraController*, SEL, id);

static void (*_logos_orig$_ungrouped$UIImagePickerController$viewWillAppear$)(UIImagePickerController*, SEL, BOOL);
static void _logos_method$_ungrouped$UIImagePickerController$viewWillAppear$(UIImagePickerController*, SEL, BOOL); 

static float (*_logos_orig$_ungrouped$AVCaptureDeviceFormat$videoMaxZoomFactor)(AVCaptureDeviceFormat*, SEL);
static float _logos_method$_ungrouped$AVCaptureDeviceFormat$videoMaxZoomFactor(AVCaptureDeviceFormat*, SEL);

// I don't know what it is but I wanna enable this too :P
// Also it's related with video zoom according to API
static BOOL _logos_method$_ungrouped$AVCaptureDeviceFormat$supportsDynamicCrop(AVCaptureDeviceFormat* self, SEL _cmd)
{
	return YES;
}

static BOOL _logos_method$_ungrouped$AVCaptureDeviceFormat$supportsVideoZoom(AVCaptureDeviceFormat* self, SEL _cmd)
{
	return YES;
}

static float _logos_method$_ungrouped$PLCameraController$maximumZoomFactorForDevice$(PLCameraController* self, SEL _cmd, id device)
{
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PLIST_PATH];
	if (dict == nil || [dict objectForKey:@"MaxFactor"] == nil)
		return 5.0f;
	float factor = [[dict objectForKey:@"MaxFactor"] floatValue];
	if (factor > 1)
		return factor;
	return 5.0f;
}

static float _logos_method$_ungrouped$PLCameraController$minimumZoomFactorForDevice$(PLCameraController* self, SEL _cmd, id device)
{
	return 1.0f;
}

static float _logos_method$_ungrouped$AVCaptureDeviceFormat$videoMaxZoomFactor(AVCaptureDeviceFormat* self, SEL _cmd)
{
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PLIST_PATH];
	if (dict == nil || [dict objectForKey:@"MaxFactor"] == nil)
		return 5.0f;
	float factor = [[dict objectForKey:@"MaxFactor"] floatValue];
	if (factor > 1)
		return factor;
	return 5.0f;
}

static void _logos_method$_ungrouped$UIImagePickerController$viewWillAppear$(UIImagePickerController* self, SEL _cmd, BOOL view) {
	_logos_orig$_ungrouped$UIImagePickerController$viewWillAppear$(self, _cmd, view);
	Class _logos_class$_ungrouped$AVCaptureDeviceFormat = objc_getClass("AVCaptureDeviceFormat");
	MSHookMessageEx(_logos_class$_ungrouped$AVCaptureDeviceFormat, @selector(supportsDynamicCrop), (IMP)&_logos_method$_ungrouped$AVCaptureDeviceFormat$supportsDynamicCrop, (IMP*)&_logos_orig$_ungrouped$AVCaptureDeviceFormat$supportsDynamicCrop);
	MSHookMessageEx(_logos_class$_ungrouped$AVCaptureDeviceFormat, @selector(supportsVideoZoom), (IMP)&_logos_method$_ungrouped$AVCaptureDeviceFormat$supportsVideoZoom, (IMP*)&_logos_orig$_ungrouped$AVCaptureDeviceFormat$supportsVideoZoom);
	MSHookMessageEx(_logos_class$_ungrouped$AVCaptureDeviceFormat, @selector(videoMaxZoomFactor), (IMP)&_logos_method$_ungrouped$AVCaptureDeviceFormat$videoMaxZoomFactor, (IMP*)&_logos_orig$_ungrouped$AVCaptureDeviceFormat$videoMaxZoomFactor);
	Class _logos_class$_ungrouped$PLCameraController = objc_getClass("PLCameraController"); MSHookMessageEx(_logos_class$_ungrouped$PLCameraController, @selector(maximumZoomFactorForDevice:), (IMP)&_logos_method$_ungrouped$PLCameraController$maximumZoomFactorForDevice$, (IMP*)&_logos_orig$_ungrouped$PLCameraController$maximumZoomFactorForDevice$);
	MSHookMessageEx(_logos_class$_ungrouped$PLCameraController, @selector(minimumZoomFactorForDevice:), (IMP)&_logos_method$_ungrouped$PLCameraController$minimumZoomFactorForDevice$, (IMP*)&_logos_orig$_ungrouped$PLCameraController$minimumZoomFactorForDevice$);
	Class _logos_class$_ungrouped$UIImagePickerController = objc_getClass("UIImagePickerController");
	MSHookMessageEx(_logos_class$_ungrouped$UIImagePickerController, @selector(viewWillAppear:), (IMP)&_logos_method$_ungrouped$UIImagePickerController$viewWillAppear$, (IMP*)&_logos_orig$_ungrouped$UIImagePickerController$viewWillAppear$);
}

%ctor {
	Class _logos_class$_ungrouped$AVCaptureDeviceFormat = objc_getClass("AVCaptureDeviceFormat");
	MSHookMessageEx(_logos_class$_ungrouped$AVCaptureDeviceFormat, @selector(supportsDynamicCrop), (IMP)&_logos_method$_ungrouped$AVCaptureDeviceFormat$supportsDynamicCrop, (IMP*)&_logos_orig$_ungrouped$AVCaptureDeviceFormat$supportsDynamicCrop);
	MSHookMessageEx(_logos_class$_ungrouped$AVCaptureDeviceFormat, @selector(supportsVideoZoom), (IMP)&_logos_method$_ungrouped$AVCaptureDeviceFormat$supportsVideoZoom, (IMP*)&_logos_orig$_ungrouped$AVCaptureDeviceFormat$supportsVideoZoom);
	MSHookMessageEx(_logos_class$_ungrouped$AVCaptureDeviceFormat, @selector(videoMaxZoomFactor), (IMP)&_logos_method$_ungrouped$AVCaptureDeviceFormat$videoMaxZoomFactor, (IMP*)&_logos_orig$_ungrouped$AVCaptureDeviceFormat$videoMaxZoomFactor);
	Class _logos_class$_ungrouped$PLCameraController = objc_getClass("PLCameraController"); MSHookMessageEx(_logos_class$_ungrouped$PLCameraController, @selector(maximumZoomFactorForDevice:), (IMP)&_logos_method$_ungrouped$PLCameraController$maximumZoomFactorForDevice$, (IMP*)&_logos_orig$_ungrouped$PLCameraController$maximumZoomFactorForDevice$);
	MSHookMessageEx(_logos_class$_ungrouped$PLCameraController, @selector(minimumZoomFactorForDevice:), (IMP)&_logos_method$_ungrouped$PLCameraController$minimumZoomFactorForDevice$, (IMP*)&_logos_orig$_ungrouped$PLCameraController$minimumZoomFactorForDevice$);
	Class _logos_class$_ungrouped$UIImagePickerController = objc_getClass("UIImagePickerController");
	MSHookMessageEx(_logos_class$_ungrouped$UIImagePickerController, @selector(viewWillAppear:), (IMP)&_logos_method$_ungrouped$UIImagePickerController$viewWillAppear$, (IMP*)&_logos_orig$_ungrouped$UIImagePickerController$viewWillAppear$);
}

