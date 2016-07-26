//
//  DemoPhotoViewController.m
//  YangMingShanDemo
//
//  Copyright 2016 Yahoo Inc.
//  Licensed under the terms of the BSD license. Please see LICENSE file in the project root for terms.
//

#import "DemoPhotoViewController.h"

#import "DemoImageViewCell.h"

#import "UIViewController+YMSPhotoHelper.h"

static NSString * const CellIdentifier = @"imageCellIdentifier";

@interface DemoPhotoViewController ()<YMSPhotoPickerViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSArray *images;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UITextField *numberOfPhotoSelectionTextField;

- (IBAction)presentPhotoPicker:(id)sender;
- (IBAction)deletePhotoImage:(id)sender;

@end

@implementation DemoPhotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(presentPhotoPicker:)];
    self.navigationItem.rightBarButtonItem = barButtonItem;

    [self.collectionView registerNib:[UINib nibWithNibName:@"DemoImageViewCell" bundle:nil] forCellWithReuseIdentifier:@"imageCellIdentifier"];
}

#pragma mark - IBActions

- (IBAction)presentPhotoPicker:(id)sender
{
    NSString *numberOfPhotoSelectionString = self.numberOfPhotoSelectionTextField.text;
    if (numberOfPhotoSelectionString.length > 0
        && [numberOfPhotoSelectionString integerValue] != 1) {
        // Custom selection number
        YMSPhotoPickerViewController *pickerViewController = [[YMSPhotoPickerViewController alloc] init];
        pickerViewController.numberOfPhotoToSelect = [numberOfPhotoSelectionString integerValue];

        UIColor *customColor = [UIColor colorWithRed:248.0/255.0 green:217.0/255.0 blue:44.0/255.0 alpha:1.0];

        pickerViewController.theme.titleLabelTextColor = [UIColor blackColor];
        pickerViewController.theme.navigationBarBackgroundColor = customColor;
        pickerViewController.theme.tintColor = [UIColor blackColor];
        pickerViewController.theme.orderTintColor = customColor;
        pickerViewController.theme.orderLabelTextColor = [UIColor blackColor];
        pickerViewController.theme.cameraVeilColor = customColor;
        pickerViewController.theme.cameraIconColor = [UIColor whiteColor];
        pickerViewController.theme.statusBarStyle = UIStatusBarStyleDefault;

        [self yms_presentCustomAlbumPhotoView:pickerViewController delegate:self];
    }
    else {
        [[YMSPhotoPickerTheme sharedInstance] reset];
        [self yms_presentAlbumPhotoViewWithDelegate:self];
    }
}

- (IBAction)deletePhotoImage:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *deleteButton = (UIButton *)sender;
        NSMutableArray *mutableImages = [NSMutableArray arrayWithArray:self.images];
        [mutableImages removeObjectAtIndex:deleteButton.tag];
        self.images = [mutableImages copy];
        [self.collectionView performBatchUpdates:^{
            [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:deleteButton.tag inSection:0]]];
        } completion:nil];
    }
}

#pragma mark - YMSPhotoPickerViewControllerDelegate

- (void)photoPickerViewControllerDidReceivePhotoAlbumAccessDenied:(YMSPhotoPickerViewController *)picker
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Allow photo album access?", nil) message:NSLocalizedString(@"Need your permission to access photo albumbs", nil) preferredStyle:UIAlertControllerStyleAlert];
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

- (void)photoPickerViewController:(YMSPhotoPickerViewController *)picker didFinishPickingImage:(UIImage *)image
{
    [picker dismissViewControllerAnimated:YES completion:^() {
        self.images = @[image];
        [self.collectionView reloadData];
    }];
}

- (void)photoPickerViewController:(YMSPhotoPickerViewController *)picker didFinishPickingImages:(NSArray *)photoAssets
{
    [picker dismissViewControllerAnimated:YES completion:^() {

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

        self.images = [mutableImages copy];
        [self.collectionView reloadData];
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DemoImageViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.photoImage = [self.images objectAtIndex:indexPath.item];
    cell.deleteButton.tag = indexPath.item;
    [cell.deleteButton addTarget:self action:@selector(deletePhotoImage:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetWidth(collectionView.bounds), CGRectGetHeight(collectionView.bounds));
}


@end
