//
//  YMSAlbumPickerViewController.m
//  YangMingShan
//
//  Copyright 2016 Yahoo Inc.
//  Licensed under the terms of the BSD license. Please see LICENSE file in the project root for terms.
//

#import "YMSAlbumPickerViewController.h"

#import <Photos/Photos.h>

#import "UIScrollView+YMSAdditions.h"
#import "UITableViewCell+YMSConfig.h"
#import "YMSAlbumCell.h"
#import "YMSPhotoPickerTheme.h"

static const CGFloat YMSNavigationBarMaxTopSpace = 44.0;
static const CGFloat YMSNavigationBarOriginalTopSpace = 0.0;

@interface YMSAlbumPickerViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) void (^dismissalHandler)(NSDictionary *);
@property (nonatomic, strong) NSDictionary *selectedCollectionItem;
@property (nonatomic, strong) NSArray *collectionItems;
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, weak) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, weak) IBOutlet UIView *navigationBarBackgroundView;
@property (nonatomic, weak) IBOutlet UITableView *albumListTableView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *navigationBarTopLayoutConstraint;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, assign) CGFloat footerViewHeight;
@property (nonatomic, strong) UIView *headerView;

- (IBAction)dismiss:(id)sender;

@end

@implementation YMSAlbumPickerViewController

- (instancetype)initWithCollectionItems:(NSArray<NSDictionary *> *)collectionItems selectedCollectionItem:(NSDictionary *)collectionItem dismissalHandler:(void (^)(NSDictionary *))dismissalHandler
{
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle bundleForClass:self.class]];
    if (self) {
        self.selectedCollectionItem = collectionItem;
        self.collectionItems = collectionItems;
        self.dismissalHandler = dismissalHandler;
        self.imageManager = [[PHCachingImageManager alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    UINavigationItem *navigationItem = [[UINavigationItem alloc] init];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss:)];
    navigationItem.leftBarButtonItem = cancelItem;

    self.navigationBar.items = @[navigationItem];
    
    if (![[YMSPhotoPickerTheme sharedInstance].navigationBarBackgroundColor isEqual:[UIColor whiteColor]]) {
        [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [self.navigationBar setShadowImage:[UIImage new]];
        self.navigationBarBackgroundView.backgroundColor = [YMSPhotoPickerTheme sharedInstance].navigationBarBackgroundColor;
        self.albumListTableView.tintColor = [YMSPhotoPickerTheme sharedInstance].navigationBarBackgroundColor;
    }

    self.albumListTableView.delegate = self;
    self.albumListTableView.dataSource = self;

    UINib *cellNib = [UINib nibWithNibName:@"YMSAlbumCell" bundle:[NSBundle bundleForClass:YMSAlbumCell.class]];
    
    [self.albumListTableView registerNib:cellNib forCellReuseIdentifier:[YMSAlbumCell yms_cellIdentifier]];
    self.footerViewHeight = CGRectGetHeight(self.view.bounds) * 2;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    if (!self.footerView) {
        self.albumListTableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, -self.footerViewHeight, 0.0);
        self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), self.footerViewHeight)];
        self.footerView.backgroundColor = [UIColor whiteColor];
        self.albumListTableView.tableFooterView = self.footerView;
    }

    if (!self.headerView) {
        self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), 6.0)];
        self.headerView.backgroundColor = [UIColor whiteColor];
        self.albumListTableView.tableHeaderView = self.headerView;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [YMSPhotoPickerTheme sharedInstance].statusBarStyle;
}

#pragma mark - IBActions

- (IBAction)dismiss:(id)sender
{
    if (self.dismissalHandler) {
        self.dismissalHandler(self.selectedCollectionItem);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.collectionItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YMSAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:[YMSAlbumCell yms_cellIdentifier]];
    
    NSDictionary *collectionItem = [self.collectionItems objectAtIndex:indexPath.row];
    
    PHFetchResult *fetchResult = collectionItem[@"assets"];
    PHCollection *collection = collectionItem[@"collection"];
    
    cell.albumName = collection.localizedTitle;
    cell.photosCount = fetchResult.count;
    if ([collectionItem isEqual:self.selectedCollectionItem]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    
    PHAsset *asset = [fetchResult firstObject];
    cell.representedAssetIdentifier = asset.localIdentifier;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(40.0 * scale, 40.0 * scale);
    
    [self.imageManager requestImageForAsset:asset
                                 targetSize:targetSize
                                contentMode:PHImageContentModeAspectFill
                                    options:nil
                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                  // Set the cell's thumbnail image if it's still showing the same asset.
                                  if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
                                      cell.thumbnailImage = result;
                                  }
                              }];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *collectionItem = [self.collectionItems objectAtIndex:indexPath.row];
    self.selectedCollectionItem = collectionItem;
    
    [tableView reloadData];
    [self dismiss:nil];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Measure table view scolling position is between the expectation
    if (scrollView.contentOffset.y > YMSNavigationBarOriginalTopSpace
        && scrollView.contentOffset.y + CGRectGetHeight(scrollView.bounds) < scrollView.contentSize.height - 1 - self.footerViewHeight) {
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
