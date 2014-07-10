//
//  FGGalleryViewController.m
//  FlickGallery
//
//  Created by Ostap Horbach on 7/9/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "FGGalleryViewController.h"
#import "FGTableViewCell.h"
#import "FGFlickrDataSource.h"
#import "SVProgressHUD.h"

#define kLoadingCellHeight 40

@interface FGGalleryViewController () <UISearchBarDelegate>

@property (nonatomic, strong) FGFlickrDataSource *flickrDataSource;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;

@end

@implementation FGGalleryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchBar.delegate = self;
    self.navigationItem.titleView = self.searchBar;
    
    self.flickrDataSource = [[FGFlickrDataSource alloc] initWithAPIKey:@"ec093a13c4c99829b40e15b515111cf1"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self performSearch:@"Rome"];
}

#pragma mark - 

- (void)performSearch:(NSString *)searchTerm
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [self.flickrDataSource searchFlickrForTerm:searchTerm completionBlock:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [self showFailureAlert];
            } else {
                [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
                [self.tableView reloadData];
            }
            [SVProgressHUD dismiss];
        });
    }];
}

- (void)showFailureAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"Failed to load pictures :(\nTry again later"
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = self.flickrDataSource.numberOfResults;
    
    if (self.flickrDataSource.canLoadNextPage) {
        numberOfRows += 1;
    }
    
    return numberOfRows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.flickrDataSource.numberOfResults) {
        return [self photoCellAtIndexPath:indexPath];
    } else {
        return [self loadingCell];
    }
}

- (UITableViewCell *)photoCellAtIndexPath:(NSIndexPath *)indexPath
{
    FGTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PhotoCell" forIndexPath:indexPath];
    [cell setPhoto:nil];
    
    [self.flickrDataSource loadPhotoAtIndex:indexPath.row completionBlock:^(NSInteger index, UIImage *photo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            if ([self cellAtIndexPathIsVisible:indexPath]) {
                [cell setPhoto:photo];
            }
        });
    }];
    
    return cell;
}

- (UITableViewCell *)loadingCell
{
    UITableViewCell *loadingCell = [self.tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
    return loadingCell;
}

- (BOOL)cellAtIndexPathIsVisible:(NSIndexPath *)indexPath
{
    BOOL test = [self.tableView cellForRowAtIndexPath:indexPath] != nil;
    return test;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.flickrDataSource.numberOfResults) {
        return kLoadingCellHeight;
    }
    return tableView.rowHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.flickrDataSource.numberOfResults) {
        [self.flickrDataSource loadNextPageWithCompletionBlock:^(NSError *error) {
            if (error) {
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }];
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.text = self.flickrDataSource.currentSearchTerm;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *trimmedSearchTerm = [searchBar.text
                                   stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedSearchTerm.length > 0) {
        [self performSearch:trimmedSearchTerm];
    }
    [searchBar resignFirstResponder];
}

@end
