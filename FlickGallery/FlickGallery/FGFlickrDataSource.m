//
//  FGFlickrDataSource.m
//  FlickGallery
//
//  Created by Ostap Horbach on 7/9/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "FGFlickrDataSource.h"
#import "Flickr.h"
#import "FlickrPhoto.h"

#define kPerPage 20

@interface FGFlickrDataSource ()

@property (nonatomic, strong) Flickr *flickr;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, strong) NSString *currentSearchTerm;
@property (nonatomic) NSInteger page;
@property (nonatomic, strong) NSMutableDictionary *imageLoadingQueue;
@property (nonatomic) BOOL stopLoading;
@property (nonatomic, strong) dispatch_queue_t loadingQueue;

@end

@implementation FGFlickrDataSource

- (id)initWithAPIKey:(NSString *)apiKey
{
    self = [super init];
    if (self) {
        _flickr = [[Flickr alloc] init];
        _flickr.apiKey = apiKey;
        _searchResults = [@[] mutableCopy];
        _page = 1;
        _imageLoadingQueue = [@{} mutableCopy];
//        _loadingQueue
    }
    return self;
}

- (void)resetSearch
{
    self.searchResults = [@[] mutableCopy];
    self.imageLoadingQueue = [@{} mutableCopy];
    self.stopLoading = YES;
    self.page = 1;
}

- (NSInteger)numberOfResults
{
    return self.searchResults.count;
}

- (void)searchFlickrForTerm:(NSString *)term completionBlock:(void (^)(NSError *error))completionBlock
{
    NSString *searchTerm = [term lowercaseString];
    if (![searchTerm isEqualToString:self.currentSearchTerm]) {
        self.currentSearchTerm = searchTerm;
        [self resetSearch];
    }
    
    [self.flickr searchFlickrForTerm:term page:self.page completionBlock:^(NSString *searchTerm, NSArray *results, NSError *error) {
        if (!error) {
            [self.searchResults addObjectsFromArray:results];
//            [self loadPhotosForSearchResults:results];
        }
        if (completionBlock) {
            completionBlock(error);
        }
    }];
}

- (BOOL)canLoadNextPage
{
    return self.page * kPerPage >= self.searchResults.count;
}

- (void)loadNextPageWithCompletionBlock:(void (^)(NSError *error))completionBlock
{
    if ([self canLoadNextPage]) {
        self.page++;
        [self searchFlickrForTerm:self.currentSearchTerm completionBlock:completionBlock];
    } else {
        if (completionBlock) {
            completionBlock(nil);
        }
    }
}

- (void)loadPhotosForSearchResults:(NSArray *)searchResults
{
    [[searchResults copy] enumerateObjectsUsingBlock:^(FlickrPhoto *flickrPhoto, NSUInteger idx, BOOL *stop) {
        
        
        [Flickr loadImageForPhoto:flickrPhoto thumbnail:NO completionBlock:^(UIImage *photoImage, NSError *error) {
            if (self.stopLoading) {
                self.stopLoading = NO;
                return;
            }
            if (!error) {
                PhotoCompletionBlock block = [self.imageLoadingQueue objectForKey:@(idx)];
                if (block) {
                    [self.imageLoadingQueue removeObjectForKey:@(idx)];
                    block(idx, photoImage);
                }
            }
        }];
    }];
}

- (void)loadPhotoAtIndex:(NSInteger)index completionBlock:(PhotoCompletionBlock)completionBlock;
{
    FlickrPhoto *flickrPhotoAtIndex = self.searchResults[index];
    
    if (flickrPhotoAtIndex.largeImage) {
        completionBlock(index, flickrPhotoAtIndex.largeImage);
    } else {
//        [self.imageLoadingQueue setObject:completionBlock forKey:@(index)];
        [Flickr loadImageForPhoto:flickrPhotoAtIndex thumbnail:NO completionBlock:^(UIImage *photoImage, NSError *error) {
            if (!error) {
                completionBlock(index, photoImage);
            } else {
                completionBlock(index, nil);
            }
        }];
    }
}

@end
