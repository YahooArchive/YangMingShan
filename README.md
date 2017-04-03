<img src="media/yangmingshan-banner@2x.png">

[![Build Status](https://travis-ci.org/yahoo/YangMingShan.svg?branch=master)](https://travis-ci.org/yahoo/YangMingShan)
[![CocoaPods](https://img.shields.io/cocoapods/v/YangMingShan.svg?maxAge=2592000?style=flat-square)](https://cocoapods.org/?q=yangmingshan)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

YangMingShan is a collection of iOS UI components that we created while building Yahoo apps. The reason we open source it is to share useful and common components with the community. Feel free to open the feature request ticket for new UI component you see on Yahoo apps or send pull-request to benefit open source community.

Installation
-------

YangMingShan can be installed via [CocoaPods](http://cocoapods.org/). Simply add

```ruby
pod 'YangMingShan'
```

to your Podfile.

YangMingShan also supports [Carthage](https://github.com/Carthage/Carthage). Simply add

```
github "yahoo/YangMingShan"
```
to your Cartfile.

The Components

A
-------

### YMSPhotoPicker

YMSPhotoPicker is an UIComponent that let you select multiple photos from your albums. You can also take a photo inside YMSPhotoPicker and select it with other photos. It has the exposed theme YMSPhotoPickerTheme that you can customize several parts of YMSPhotoPicker.

Part of the code in this package was derived from Yahoo Messenger and Yahoo Taiwan Auctions.

<img src="media/ymsphotopicker-demo.gif" alt="Square Cash Style Bar" width="300"/>
<img src="media/ymsphotopicker-theme.gif" alt="Square Cash Style Bar" width="300"/>

#### Usage

Add ```NSPhotoLibraryUsageDescription``` and ```NSCameraUsageDescription``` to your App Info.plist to specify the reason for accessing photo library and camera. See [Cocoa Keys](https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html) for more details.

#####Objective-C

Import

```objective-c
@import YangMingShan;
```

Add delegate to your view controller

```objective-c
@interface YourViewController ()<YMSPhotoPickerViewControllerDelegate>
```

Present default photo picker. Note it is only available for single selection

```objective-c
[self yms_presentAlbumPhotoViewWithDelegate:self];
```

Or init picker with limited photo selection of 10

```objective-c
YMSPhotoPickerViewController *pickerViewController = [[YMSPhotoPickerViewController alloc] init];
pickerViewController.numberOfPhotoToSelect = 10;
```

With customized theme
```objective-c
UIColor *customColor = [UIColor colorWithRed:64.0/255.0 green:0.0 blue:144.0/255.0 alpha:1.0];
UIColor *customCameraColor = [UIColor colorWithRed:86.0/255.0 green:1.0/255.0 blue:236.0/255.0 alpha:1.0];

pickerViewController.theme.titleLabelTextColor = [UIColor whiteColor];
        pickerViewController.theme.navigationBarBackgroundColor = customColor;
pickerViewController.theme.tintColor = [UIColor whiteColor];
pickerViewController.theme.orderTintColor = customCameraColor;
pickerViewController.theme.cameraVeilColor = customCameraColor;
pickerViewController.theme.cameraIconColor = [UIColor whiteColor];
pickerViewController.theme.statusBarStyle = UIStatusBarStyleLightContent;
```

Present customized picker
```objective-c
[self yms_presentCustomAlbumPhotoView:pickerViewController delegate:self];
```

Implement photoPickerViewControllerDidReceivePhotoAlbumAccessDenied: and photoPickerViewControllerDidReceiveCameraAccessDenied: to observe photo album and camera access denied occur

```objective-c
- (void)photoPickerViewControllerDidReceivePhotoAlbumAccessDenied:(YMSPhotoPickerViewController *)picker
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Allow photo album access?", nil) message:NSLocalizedString(@"Need your permission to access photo albums", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alertController addAction:dismissAction];
    [alertController addAction:settingsAction];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)photoPickerViewControllerDidReceiveCameraAccessDenied:(YMSPhotoPickerViewController *)picker
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Allow camera access?", nil) message:NSLocalizedString(@"Need your permission to take a photo", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alertController addAction:dismissAction];
    [alertController addAction:settingsAction];

    // The access denied of camera is always happened on picker, present alert on it to follow the view hierarchy
    [picker presentViewController:alertController animated:YES completion:nil];
}
```

Implement photoPickerViewController:didFinishPickingImages: while you expect there are multiple photo selections

```objective-c
- (void)photoPickerViewController:(YMSPhotoPickerViewController *)picker didFinishPickingImages:(NSArray *)photoAssets
{
    [picker dismissViewControllerAnimated:YES completion:^() {
        // Remember images you get here is PHAsset array, you need to implement PHImageManager to get UIImage data by yourself
        PHImageManager *imageManager = [[PHImageManager alloc] init];

        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.networkAccessAllowed = YES;
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        options.synchronous = YES;

        NSMutableArray *mutableImages = [NSMutableArray array];

        for (PHAsset *asset in photoAssets) {
            CGSize targetSize = CGSizeMake((CGRectGetWidth(self.collectionView.bounds) - 20*2) * [UIScreen mainScreen].scale, (CGRectGetHeight(self.collectionView.bounds) - 20*2) * [UIScreen mainScreen].scale);
            [imageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *image, NSDictionary *info) {
                [mutableImages addObject:image];
            }];
        }

		// Assign to Array with images
        self.images = [mutableImages copy];
    }];
}
```

#####Swift

Import

```swift
import YangMingShan
```

Add delegate to your view controller

```swift
class YourViewController: UIViewController, YMSPhotoPickerViewControllerDelegate
```

Present default photo picker. Note it is only available for single selection

```swift
self.yms_presentAlbumPhotoViewWithDelegate(self)
```

Or init picker with limited photo selection of 10

```swift
let pickerViewController = YMSPhotoPickerViewController.init()
pickerViewController.numberOfPhotoToSelect = 10
```

With customized theme

```swift
let customColor = UIColor.init(red: 64.0/255.0, green: 0.0, blue: 144.0/255.0, alpha: 1.0)
let customCameraColor = UIColor.init(red: 86.0/255.0, green: 1.0/255.0, blue: 236.0/255.0, alpha: 1.0)

pickerViewController.theme.titleLabelTextColor = UIColor.whiteColor()
pickerViewController.theme.navigationBarBackgroundColor = customColor
pickerViewController.theme.tintColor = UIColor.whiteColor()
pickerViewController.theme.orderTintColor = customCameraColor
pickerViewController.theme.cameraVeilColor = customCameraColor
pickerViewController.theme.cameraIconColor = UIColor.whiteColor()
pickerViewController.theme.statusBarStyle = .LightContent
```

Present customized picker

```swift
self.yms_presentCustomAlbumPhotoView(pickerViewController, delegate: self)
```

Implement photoPickerViewControllerDidReceivePhotoAlbumAccessDenied(picker:) and photoPickerViewControllerDidReceiveCameraAccessDenied(picker:) to obesrve photo album and camera access denied occur

```swift
func photoPickerViewControllerDidReceivePhotoAlbumAccessDenied(_ picker: YMSPhotoPickerViewController!) {
    let alertController = UIAlertController(title: "Allow photo album access?", message: "Need your permission to access photo albums", preferredStyle: .alert)
    let dismissAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in
        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
    }
    alertController.addAction(dismissAction)
    alertController.addAction(settingsAction)

    self.present(alertController, animated: true, completion: nil)
}

func photoPickerViewControllerDidReceiveCameraAccessDenied(_ picker: YMSPhotoPickerViewController!) {
    let alertController = UIAlertController(title: "Allow camera album access?", message: "Need your permission to take a photo", preferredStyle: .alert)
    let dismissAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in
        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
    }
    alertController.addAction(dismissAction)
    alertController.addAction(settingsAction)

    // The access denied of camera is always happened on picker, present alert on it to follow the view hierarchy
    picker.present(alertController, animated: true, completion: nil)
}
```

Implement photoPickerViewController(picker:didFinishPickingImages:) while you expect there are mutiple photo selections

```swift
func photoPickerViewController(picker: YMSPhotoPickerViewController!, didFinishPickingImages photoAssets: [PHAsset]!) {
    // Remember images you get here is PHAsset array, you need to implement PHImageManager to get UIImage data by yourself
    picker.dismissViewControllerAnimated(true) {
        let imageManager = PHImageManager.init()
        let options = PHImageRequestOptions.init()
        options.deliveryMode = .HighQualityFormat
        options.resizeMode = .Exact
        options.synchronous = true

        let mutableImages: NSMutableArray! = []

        for asset: PHAsset in photoAssets
        {
            let scale = UIScreen.mainScreen().scale
            let targetSize = CGSizeMake((CGRectGetWidth(self.collectionView.bounds) - 20*2) * scale, (CGRectGetHeight(self.collectionView.bounds) - 20*2) * scale)
            imageManager.requestImageForAsset(asset, targetSize: targetSize, contentMode: .AspectFill, options: options, resultHandler: { (image, info) in
                    mutableImages.addObject(image!)
            })
        }
        // Assign to Array with images
        self.images = mutableImages.copy() as? NSArray
    }
}
```

### Instruction

  - **Sample Codes** has been written in YangMangShanDemo project. You can read code to know about "How to implement these features in your project". Just use github to clone YangMingShan to your local disk. It should run well with your Xcode.
  - **API Reference Documents** > Please refer the [gh-pages](https://yahoo.github.io/YangMingShan/) in YangMingShan project. We use [appledoc](https://github.com/tomaz/appledoc) to generate this document. The command line we generate current document is
```shell
appledoc --output {TARGET_FOLDER} --project-name "YangMingShan" --project-company "Yahoo" --company-id "com.yahoo" --no-warn-undocumented-object --keep-intermediate-files --ignore Private {YANGMINGSHAN_LOCOCAL_ROPOSITORY}

```  

### License

This software is free to use under the Yahoo Inc. BSD license.
See the [LICENSE] for license text and copyright information.

[LICENSE]: https://github.com/yahoo/YangMingShan/blob/master/LICENSE.md
