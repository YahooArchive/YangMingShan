//
//  YMSPhotoPickerViewController.m
//  YangMingShan
//
//  Copyright 2016 Yahoo Inc.
//  Licensed under the terms of the BSD license. Please see LICENSE file in the project root for terms.
//

#import "YMSPhotoPickerViewController.h"

#import <Photos/Photos.h>

#import "UIScrollView+YMSAdditions.h"
#import "UIViewController+YMSPhotoHelper.h"
#import "YMSAlbumPickerViewController.h"
#import "YMSCameraCell.h"
#import "YMSPhotoCell.h"
#import "YMSSinglePhotoViewController.h"

static NSString * const YMSCameraCellNibName = @"YMSCameraCell";
static NSString * const YMSPhotoCellNibName = @"YMSPhotoCell";
static const NSUInteger YMSNumberOfPhotoColumns = 3;
static const CGFloat YMSNavigationBarMaxTopSpace = 44.0;
static const CGFloat YMSNavigationBarOriginalTopSpace = 0.0;
static const CGFloat YMSPhotoFetchScaleResizingRatio = 0.75;

@interface YMSPhotoPickerViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPhotoLibraryChangeObserver>

@property (nonatomic, weak) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, weak) IBOutlet UIView *navigationBarBackgroundView;
@property (nonatomic, weak) IBOutlet UICollectionView *photoCollectionView;
@property (nonatomic, strong) PHImageManager *imageManager;
@property (nonatomic, weak) AVCaptureSession *session;
@property (nonatomic, strong) NSArray *collectionItems;
@property (nonatomic, strong) NSDictionary *currentCollectionItem;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *navigationBarTopLayoutConstraint;
@property (nonatomic, strong) NSMutableArray *selectedPhotos;
@property (nonatomic, strong) UIBarButtonItem *doneItem;
@property (nonatomic, assign) BOOL needToSelectFirstPhoto;
@property (nonatomic, assign) CGSize cellPortraitSize;
@property (nonatomic, assign) CGSize cellLandscapeSize;

- (IBAction)dismiss:(id)sender;
- (IBAction)presentAlbumPickerView:(id)sender;
- (IBAction)finishPickingPhotos:(id)sender;
- (void)updateViewWithCollectionItem:(NSDictionary *)collectionItem;
- (void)refreshPhotoSelection;
- (void)fetchCollections;
- (BOOL)allowsMultipleSelection;
- (BOOL)canAddPhoto;
- (IBAction)presentSinglePhoto:(id)sender;
- (void)setupCellSize;

@end

@implementation YMSPhotoPickerViewController

- (instancetype)init
{
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle bundleForClass:self.class]];
    if (self) {
        self.selectedPhotos = [NSMutableArray array];
        self.numberOfPhotoToSelect = 1;
        self.shouldReturnImageForSingleSelection = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set PHCachingImageManager here because you don't know photo album permission is allowed in init function
    self.imageManager = [[PHCachingImageManager alloc] init];

    self.view.tintColor = self.theme.tintColor;

    self.photoCollectionView.delegate = self;
    self.photoCollectionView.dataSource = self;
    
    UINib *cellNib = [UINib nibWithNibName:YMSCameraCellNibName bundle:[NSBundle bundleForClass:YMSCameraCell.class]];
    [self.photoCollectionView registerNib:cellNib forCellWithReuseIdentifier:YMSCameraCellNibName];
    cellNib = [UINib nibWithNibName:YMSPhotoCellNibName bundle:[NSBundle bundleForClass:YMSPhotoCell.class]];
    [self.photoCollectionView registerNib:cellNib forCellWithReuseIdentifier:YMSPhotoCellNibName];
    self.photoCollectionView.allowsMultipleSelection = self.allowsMultipleSelection;

    [self fetchCollections];

    UINavigationItem *navigationItem = [[UINavigationItem alloc] init];
    navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss:)];

    if (self.allowsMultipleSelection) {
        // Add done button for multiple selections
        self.doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finishPickingPhotos:)];
        self.doneItem.enabled = NO;
        navigationItem.rightBarButtonItem = self.doneItem;
    }

    self.navigationBar.items = @[navigationItem];

    if (![self.theme.navigationBarBackgroundColor isEqual:[UIColor whiteColor]]) {
        [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [self.navigationBar setShadowImage:[UIImage new]];
        self.navigationBarBackgroundView.backgroundColor = self.theme.navigationBarBackgroundColor;
    }
    
    [self updateViewWithCollectionItem:[self.collectionItems firstObject]];

    self.cellPortraitSize = self.cellLandscapeSize = CGSizeZero;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.photoCollectionView.collectionViewLayout invalidateLayout];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [YMSPhotoPickerTheme sharedInstance].statusBarStyle;
}

#pragma mark - Getters

- (YMSPhotoPickerTheme *)theme
{
    return [YMSPhotoPickerTheme sharedInstance];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // +1 for camera cell
    PHFetchResult *fetchResult = self.currentCollectionItem[@"assets"];
    
    return fetchResult.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {   // Camera Cell
        YMSCameraCell *cameraCell = [collectionView dequeueReusableCellWithReuseIdentifier:YMSCameraCellNibName forIndexPath:indexPath];

        self.session = cameraCell.session;
        
        if (![self.session isRunning]) {
            [self.session startRunning];
        }
        
        return cameraCell;
    }    
    
    YMSPhotoCell *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:YMSPhotoCellNibName forIndexPath:indexPath];

    PHFetchResult *fetchResult = self.currentCollectionItem[@"assets"];
    
    PHAsset *asset = fetchResult[indexPath.item-1];
    photoCell.representedAssetIdentifier = asset.localIdentifier;
    
    CGFloat scale = [UIScreen mainScreen].scale * YMSPhotoFetchScaleResizingRatio;
    CGSize imageSize = CGSizeMake(CGRectGetWidth(photoCell.frame) * scale, CGRectGetHeight(photoCell.frame) * scale);
    
    [photoCell loadPhotoWithManager:self.imageManager forAsset:asset targetSize:imageSize];

    [photoCell.longPressGestureRecognizer addTarget:self action:@selector(presentSinglePhoto:)];

    if ([self.selectedPhotos containsObject:asset]) {
        NSUInteger selectionIndex = [self.selectedPhotos indexOfObject:asset];
        photoCell.selectionOrder = selectionIndex+1;
    }

    return photoCell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[YMSPhotoCell class]]) {
        [(YMSPhotoCell *)cell animateHighlight:YES];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if (!self.canAddPhoto
        || cell.isSelected) {
        return NO;
    }
    if ([cell isKindOfClass:[YMSPhotoCell class]]) {
        YMSPhotoCell *photoCell = (YMSPhotoCell *)cell;
        [photoCell setNeedsAnimateSelection];
        photoCell.selectionOrder = self.selectedPhotos.count+1;
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self yms_presentCameraCaptureViewWithDelegate:self];
    }
    else if (NO == self.allowsMultipleSelection) {
        if (NO == self.shouldReturnImageForSingleSelection) {
            PHFetchResult *fetchResult = self.currentCollectionItem[@"assets"];
            PHAsset *asset = fetchResult[indexPath.item-1];
            [self.selectedPhotos addObject:asset];
            [self finishPickingPhotos:nil];
        } else {
            PHFetchResult *fetchResult = self.currentCollectionItem[@"assets"];
            PHAsset *asset = fetchResult[indexPath.item-1];
            
            // Prepare the options to pass when fetching the live photo.
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            options.networkAccessAllowed = YES;
            options.resizeMode = PHImageRequestOptionsResizeModeExact;
            
            CGSize targetSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
            
            [self.imageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *image, NSDictionary *info) {
                if (image && [self.delegate respondsToSelector:@selector(photoPickerViewController:didFinishPickingImage:)]) {
                    [self.delegate photoPickerViewController:self didFinishPickingImage:[self yms_orientationNormalizedImage:image]];
                }
                else {
                    [self dismiss:nil];
                }
            }];
        }
    }
    else {
        PHFetchResult *fetchResult = self.currentCollectionItem[@"assets"];
        PHAsset *asset = fetchResult[indexPath.item-1];
        [self.selectedPhotos addObject:asset];
        self.doneItem.enabled = YES;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[YMSPhotoCell class]]) {
        [(YMSPhotoCell *)cell animateHighlight:NO];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[YMSPhotoCell class]]) {
        [(YMSPhotoCell *)cell setNeedsAnimateSelection];
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0) {
        // Camera cell doesn't need to be deselected
        return;
    }
    PHFetchResult *fetchResult = self.currentCollectionItem[@"assets"];
    PHAsset *asset = fetchResult[indexPath.item-1];

    NSUInteger removedIndex = [self.selectedPhotos indexOfObject:asset];

    // Reload order higher than removed cell
    for (NSInteger i=removedIndex+1; i<self.selectedPhotos.count; i++) {
        PHAsset *needReloadAsset = self.selectedPhotos[i];
        YMSPhotoCell *cell = (YMSPhotoCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:[fetchResult indexOfObject:needReloadAsset]+1 inSection:indexPath.section]];
        cell.selectionOrder = cell.selectionOrder-1;
    }

    [self.selectedPhotos removeObject:asset];
    if (self.selectedPhotos.count == 0) {
        self.doneItem.enabled = NO;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (CGSizeEqualToSize(CGSizeZero, self.cellPortraitSize)
        || CGSizeEqualToSize(CGSizeZero, self.cellLandscapeSize)) {
        [self setupCellSize];
    }

    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft
        || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight) {
        return self.cellLandscapeSize;
    }
    return self.cellPortraitSize;
}

#pragma mark - IBActions

- (IBAction)dismiss:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(photoPickerViewControllerDidCancel:)]) {
        [self.delegate photoPickerViewControllerDidCancel:self];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)presentAlbumPickerView:(id)sender
{
    YMSAlbumPickerViewController *albumPickerViewController = [[YMSAlbumPickerViewController alloc] initWithCollectionItems:self.collectionItems selectedCollectionItem:self.currentCollectionItem dismissalHandler:^(NSDictionary *selectedCollectionItem) {
        if (![self.currentCollectionItem isEqual:selectedCollectionItem]) {
            [self updateViewWithCollectionItem:selectedCollectionItem];
        }
        else {
            // If collection view doesn't update, camera won't start to run
            if (![self.session isRunning]) {
                [self.session startRunning];
            }
        }
    }];
    albumPickerViewController.view.tintColor = self.theme.tintColor;

    [self presentViewController:albumPickerViewController animated:YES completion:nil];
}

- (IBAction)finishPickingPhotos:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(photoPickerViewController:didFinishPickingImages:)]) {
        [self.delegate photoPickerViewController:self didFinishPickingImages:[self.selectedPhotos copy]];
    }
    else {
        [self dismiss:nil];
    }
}

- (IBAction)presentSinglePhoto:(id)sender
{
    if ([sender isKindOfClass:[UILongPressGestureRecognizer class]]) {
        UILongPressGestureRecognizer *gesture = sender;
        if (gesture.state != UIGestureRecognizerStateBegan) {
            return;
        }
        NSIndexPath *indexPath = [self.photoCollectionView indexPathForCell:(YMSPhotoCell *)gesture.view];

        PHFetchResult *fetchResult = self.currentCollectionItem[@"assets"];

        PHAsset *asset = fetchResult[indexPath.item-1];

        YMSSinglePhotoViewController *presentedViewController = [[YMSSinglePhotoViewController alloc] initWithPhotoAsset:asset imageManager:self.imageManager dismissalHandler:^(BOOL selected) {
            if (selected && [self collectionView:self.photoCollectionView shouldSelectItemAtIndexPath:indexPath]) {
                [self.photoCollectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                [self collectionView:self.photoCollectionView didSelectItemAtIndexPath:indexPath];
            }
        }];
        presentedViewController.view.tintColor = self.theme.tintColor;

        [self presentViewController:presentedViewController animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{

        // Enable camera preview when user allow it first time
        if (![self.session isRunning]) {
            [self.photoCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
        }

        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        if (![image isKindOfClass:[UIImage class]]) {
            return;
        }

        // Save the image to Photo Album
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollection *collection = self.currentCollectionItem[@"collection"];
            if (collection.assetCollectionType == PHAssetCollectionTypeSmartAlbum) {
                // Cannot save to smart albums other than "all photos", pick it and dismiss
                [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            }
            else {
                PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                PHObjectPlaceholder *placeholder = [assetRequest placeholderForCreatedAsset];
                PHAssetCollectionChangeRequest *albumChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection assets:self.currentCollectionItem[@"assets"]];
                [albumChangeRequest addAssets:@[placeholder]];
            }
        } completionHandler:^(BOOL success, NSError *error) {
            if (success) {
                self.needToSelectFirstPhoto = YES;
            }

            if (!self.allowsMultipleSelection) {
                if ([self.delegate respondsToSelector:@selector(photoPickerViewController:didFinishPickingImage:)]) {
                    [self.delegate photoPickerViewController:self didFinishPickingImage:image];
                }
                else {
                    [self dismiss:nil];
                }
            }
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^(){
        [self.photoCollectionView deselectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO];

        // Enable camera preview when user allow it first time
        if (![self.session isRunning]) {
            [self.photoCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
        }
    }];
}

#pragma mark - Privates

- (void)updateViewWithCollectionItem:(NSDictionary *)collectionItem
{
    self.currentCollectionItem = collectionItem;
    PHCollection *photoCollection = self.currentCollectionItem[@"collection"];
    
    UIButton *albumButton = [UIButton buttonWithType:UIButtonTypeSystem];
    albumButton.tintColor = self.theme.titleLabelTextColor;
    albumButton.titleLabel.font = self.theme.titleLabelFont;
    [albumButton addTarget:self action:@selector(presentAlbumPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [albumButton setTitle:photoCollection.localizedTitle forState:UIControlStateNormal];
    UIImage *arrowDownImage = [UIImage imageNamed:@"YMSIconSpinnerDropdwon" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    arrowDownImage = [arrowDownImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [albumButton setImage:arrowDownImage forState:UIControlStateNormal];
    [albumButton sizeToFit];
    albumButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, albumButton.frame.size.width - (arrowDownImage.size.width) + 10, 0.0, 0.0);
    albumButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, -arrowDownImage.size.width, 0.0, arrowDownImage.size.width + 10);
    // width + 10 for the space between text and image
    albumButton.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(albumButton.bounds) + 10, CGRectGetHeight(albumButton.bounds));

    [self.navigationBar.items firstObject].titleView = albumButton;

    [self.photoCollectionView reloadData];
    [self refreshPhotoSelection];
}

- (UIImage *)yms_orientationNormalizedImage:(UIImage *)image
{
    if (image.imageOrientation == UIImageOrientationUp) return image;

    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

- (BOOL)allowsMultipleSelection
{
    return (self.numberOfPhotoToSelect != 1);
}

- (void)refreshPhotoSelection
{
    PHFetchResult *fetchResult = self.currentCollectionItem[@"assets"];
    NSUInteger selectionNumber = self.selectedPhotos.count;

    for (int i=0; i<fetchResult.count; i++) {
        PHAsset *asset = [fetchResult objectAtIndex:i];
        if ([self.selectedPhotos containsObject:asset]) {

            // Display selection
            [self.photoCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:i+1 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            YMSPhotoCell *cell = (YMSPhotoCell *)[self.photoCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i+1 inSection:0]];
            cell.selectionOrder = [self.selectedPhotos indexOfObject:asset]+1;

            selectionNumber--;
            if (selectionNumber == 0) {
                break;
            }
        }
    }
}

- (BOOL)canAddPhoto
{
    return (self.selectedPhotos.count < self.numberOfPhotoToSelect
            || self.numberOfPhotoToSelect == 0);
}

- (void)fetchCollections
{
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];

    NSMutableArray *allAblums = [NSMutableArray array];

    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];

    __block __weak void (^weakFetchAlbums)(PHFetchResult *collections);
    void (^fetchAlbums)(PHFetchResult *collections);
    weakFetchAlbums = fetchAlbums = ^void(PHFetchResult *collections) {
        // create fecth options
        PHFetchOptions *options = [PHFetchOptions new];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];

        for (PHCollection *collection in collections) {
            if ([collection isKindOfClass:[PHAssetCollection class]]) {
                PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
                PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
                if (assetsFetchResult.count > 0) {
                    [allAblums addObject:@{@"collection": assetCollection
                                           , @"assets": assetsFetchResult}];
                }
            }
            else if ([collection isKindOfClass:[PHCollectionList class]]) {
                // If there are more sub-folders, dig into the collection to fetch the albums
                PHCollectionList *collectionList = (PHCollectionList *)collection;
                PHFetchResult *fetchResult = [PHCollectionList fetchCollectionsInCollectionList:(PHCollectionList *)collectionList options:nil];
                weakFetchAlbums(fetchResult);
            }
        }
    };

    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    fetchAlbums(topLevelUserCollections);

    for (PHAssetCollection *collection in smartAlbums) {
        PHFetchOptions *options = [PHFetchOptions new];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];

        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
        if (assetsFetchResult.count > 0) {

            // put the "all photos" in the first index
            if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                [allAblums insertObject:@{@"collection": collection
                                          , @"assets": assetsFetchResult} atIndex:0];
            }
            else {
                [allAblums addObject:@{@"collection": collection
                                       , @"assets": assetsFetchResult}];
            }
        }
    }
    self.collectionItems = [allAblums copy];
}

- (void)setupCellSize
{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.photoCollectionView.collectionViewLayout;

    // Fetch shorter length
    CGFloat arrangementLength = MIN(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));

    CGFloat minimumInteritemSpacing = layout.minimumInteritemSpacing;
    UIEdgeInsets sectionInset = layout.sectionInset;

    CGFloat totalInteritemSpacing = MAX((YMSNumberOfPhotoColumns - 1), 0) * minimumInteritemSpacing;
    CGFloat totalHorizontalSpacing = totalInteritemSpacing + sectionInset.left + sectionInset.right;

    // Caculate size for portrait mode
    CGFloat size = (CGFloat)floor((arrangementLength - totalHorizontalSpacing) / YMSNumberOfPhotoColumns);
    self.cellPortraitSize = CGSizeMake(size, size);

    // Caculate size for landsacpe mode
    arrangementLength = MAX(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    NSUInteger numberOfPhotoColumnsInLandscape = (arrangementLength - sectionInset.left + sectionInset.right)/size;
    totalInteritemSpacing = MAX((numberOfPhotoColumnsInLandscape - 1), 0) * minimumInteritemSpacing;
    totalHorizontalSpacing = totalInteritemSpacing + sectionInset.left + sectionInset.right;
    size = (CGFloat)floor((arrangementLength - totalHorizontalSpacing) / numberOfPhotoColumnsInLandscape);
    self.cellLandscapeSize = CGSizeMake(size, size);
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    // Check if there are changes to the assets we are showing.
    PHFetchResult *fetchResult = self.currentCollectionItem[@"assets"];
    
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:fetchResult];
    if (collectionChanges == nil) {

        [self fetchCollections];

        if (self.needToSelectFirstPhoto) {
            self.needToSelectFirstPhoto = NO;

            fetchResult = [self.collectionItems firstObject][@"assets"];
            PHAsset *asset = [fetchResult firstObject];
            [self.selectedPhotos addObject:asset];
            self.doneItem.enabled = YES;
        }

        return;
    }
    
    /*
     Change notifications may be made on a background queue. Re-dispatch to the
     main queue before acting on the change as we'll be updating the UI.
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        // Get the new fetch result.
        PHFetchResult *fetchResult = [collectionChanges fetchResultAfterChanges];
        NSInteger index = [self.collectionItems indexOfObject:self.currentCollectionItem];
        self.currentCollectionItem = @{
                                       @"assets": fetchResult,
                                       @"collection": self.currentCollectionItem[@"collection"]
                                       };
        if (index != NSNotFound) {
            NSMutableArray *updatedCollectionItems = [self.collectionItems mutableCopy];
            [updatedCollectionItems replaceObjectAtIndex:index withObject:self.currentCollectionItem];
            self.collectionItems = [updatedCollectionItems copy];
        }
        UICollectionView *collectionView = self.photoCollectionView;
        
        if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]
            || ([collectionChanges removedIndexes].count > 0
                && [collectionChanges changedIndexes].count > 0)) {
            // Reload the collection view if the incremental diffs are not available
            [collectionView reloadData];
        }
        else {
            /*
             Tell the collection view to animate insertions and deletions if we
             have incremental diffs.
             */
            [collectionView performBatchUpdates:^{
                
                NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
                NSMutableArray *removeIndexPaths = [NSMutableArray arrayWithCapacity:removedIndexes.count];
                [removedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    [removeIndexPaths addObject:[NSIndexPath indexPathForItem:idx+1 inSection:0]];
                }];
                if ([removedIndexes count] > 0) {
                    [collectionView deleteItemsAtIndexPaths:removeIndexPaths];
                }
                
                NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
                NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:insertedIndexes.count];
                [insertedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    [insertIndexPaths addObject:[NSIndexPath indexPathForItem:idx+1 inSection:0]];
                }];
                if ([insertedIndexes count] > 0) {
                    [collectionView insertItemsAtIndexPaths:insertIndexPaths];
                }
                
                NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
                NSMutableArray *changedIndexPaths = [NSMutableArray arrayWithCapacity:changedIndexes.count];
                [changedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:0];
                    if (![removeIndexPaths containsObject:indexPath]) {
                        // In case reload selected cell, they were didSelected and re-select. Ignore them to prevent weird transition.
                        if (self.needToSelectFirstPhoto) {
                            if (![collectionView.indexPathsForSelectedItems containsObject:indexPath]) {
                                [changedIndexPaths addObject:indexPath];
                            }
                        }
                        else {
                            [changedIndexPaths addObject:indexPath];
                        }
                    }
                }];
                if ([changedIndexes count] > 0) {
                    [collectionView reloadItemsAtIndexPaths:changedIndexPaths];
                }
            } completion:^(BOOL finished) {
                if (self.needToSelectFirstPhoto) {
                    self.needToSelectFirstPhoto = NO;

                    PHAsset *asset = [fetchResult firstObject];
                    [self.selectedPhotos addObject:asset];
                    self.doneItem.enabled = YES;
                }
                [self refreshPhotoSelection];
            }];
        }
    });
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Measure table view scolling position is between the expectation
    if (scrollView.contentOffset.y > YMSNavigationBarOriginalTopSpace
        && scrollView.contentOffset.y + CGRectGetHeight(scrollView.bounds) < scrollView.contentSize.height - 1) {
        CGFloat topLayoutConstraintConstant = self.navigationBarTopLayoutConstraint.constant - (scrollView.contentOffset.y - scrollView.lastContentOffset.y);

        // When next top constant is longer than maximum
        if (topLayoutConstraintConstant < -YMSNavigationBarMaxTopSpace) {
            self.navigationBarTopLayoutConstraint.constant = -YMSNavigationBarMaxTopSpace;
        }
        // When next top constant is smaller than the minimum
        else if (topLayoutConstraintConstant > YMSNavigationBarOriginalTopSpace) {
            self.navigationBarTopLayoutConstraint.constant = YMSNavigationBarOriginalTopSpace;
        }
        // Adjust navigation bar top space
        else {
            self.navigationBarTopLayoutConstraint.constant = topLayoutConstraintConstant;
        }

        CGFloat navigationBarAlphaStatus = 1.0 - self.navigationBarTopLayoutConstraint.constant/(YMSNavigationBarOriginalTopSpace - YMSNavigationBarMaxTopSpace);
        self.navigationBar.alpha = navigationBarAlphaStatus;
    }

    // Measure the scroll direction for adating animation in scrollViewDidEndDragging:
    [scrollView yms_scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // measure the end point to add animation
    if (self.navigationBarTopLayoutConstraint.constant > -YMSNavigationBarMaxTopSpace
        && self.navigationBarTopLayoutConstraint.constant < YMSNavigationBarOriginalTopSpace) {

        [UIView animateWithDuration:0.3 animations:^{
            if (scrollView.scrollDirection == YMSScrollViewScrollDirectionUp) {
                self.navigationBarTopLayoutConstraint.constant = -YMSNavigationBarMaxTopSpace;
            }
            else if (scrollView.scrollDirection == YMSScrollViewScrollDirectionDown) {
                self.navigationBarTopLayoutConstraint.constant = YMSNavigationBarOriginalTopSpace;
            }

            CGFloat navigationBarAlphaStatus = 1.0 - self.navigationBarTopLayoutConstraint.constant/(YMSNavigationBarOriginalTopSpace - YMSNavigationBarMaxTopSpace);
            self.navigationBar.alpha = navigationBarAlphaStatus;

            [self.view layoutIfNeeded];
        }];
    }
}

@end
