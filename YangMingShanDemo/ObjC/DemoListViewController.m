//
//  DemoListViewController.m
//  YangMingShanDemo
//
//  Copyright 2016 Yahoo Inc.
//  Licensed under the terms of the BSD license. Please see LICENSE file in the project root for terms.
//

#import "DemoListViewController.h"

static NSString * const CellIdentifier = @"reuseIdentifier";

@interface DemoListViewController ()

@property (nonatomic, strong) NSArray *listArray;

@end

@implementation DemoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSDictionary *photoPickerInfo = @{@"title": @"YMSPhotoPicker",
                                      @"description": @"Photo & Album picker",
                                      @"segueIdentifier": @"goToPhotoViewIdentifier"};
    self.listArray = @[photoPickerInfo];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    NSDictionary *cellInfo = [self.listArray objectAtIndex:indexPath.row];

    cell.textLabel.text = [cellInfo objectForKey:@"title"];
    cell.detailTextLabel.text = [cellInfo objectForKey:@"description"];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellInfo = [self.listArray objectAtIndex:indexPath.row];

    [self performSegueWithIdentifier:[cellInfo objectForKey:@"segueIdentifier"] sender:self];
}

@end
