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

@interface FGGalleryViewController ()

@property (nonatomic, strong) FGFlickrDataSource *flickrDataSource;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;

@end

@implementation FGGalleryViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = self.searchBar;

    _flickrDataSource = [[FGFlickrDataSource alloc] initWithAPIKey:@"ec093a13c4c99829b40e15b515111cf1"];
    [_flickrDataSource searchFlickrForTerm:@"London" completionBlock:^(NSError *error) {
        if (error) {
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        return 40;
    }
    return tableView.rowHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.flickrDataSource.numberOfResults) {
        [self.flickrDataSource loadNextPageWithCompletionBlock:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
