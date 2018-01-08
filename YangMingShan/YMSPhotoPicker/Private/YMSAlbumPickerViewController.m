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

@interface YMSAlbumPickerViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) void (^dismissalHandler)(NSDictionary *);
@property (nonatomic, strong) NSDictionary *selectedCollectionItem;
@property (nonatomic, strong) NSArray *collectionItems;
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, weak) IBOutlet UIView *navigationBarBackgroundView;
@property (nonatomic, weak) IBOutlet UITableView *albumListTableView;
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

    self.navigationItem.leftBarButtonItem = navigationItem.leftBarButtonItem;
    
    if (![[YMSPhotoPickerTheme sharedInstance].navigationBarBackgroundColor isEqual:[UIColor whiteColor]]) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:[UIImage new]];
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
        if (@available(iOS 11.0, *)) {
            self.albumListTableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, -self.footerViewHeight, 0.0);
        }
        else {
            self.albumListTableView.contentInset = UIEdgeInsetsMake(CGRectGetMaxY(self.navigationController.navigationBar.frame), 0.0, -self.footerViewHeight, 0.0);
        }
        
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

@end
