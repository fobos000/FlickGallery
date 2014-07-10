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
@property (nonatomic, strong, readwrite) NSString *currentSearchTerm;
@property (nonatomic, strong) NSString *currentPlaceId;
@property (nonatomic) NSInteger page;
@property (nonatomic) NSInteger totalCount;

@end

@implementation FGFlickrDataSource

- (id)initWithAPIKey:(NSString *)apiKey
{
    self = [super init];
    if (self) {
        _flickr = [[Flickr alloc] init];
        _flickr.apiKey = apiKey;
        _searchResults = [@[] mutableCopy];
        _page = 0;
    }
    return self;
}

- (void)resetSearch
{
    self.searchResults = [@[] mutableCopy];
    self.page = 0;
    self.totalCount = 0;
    self.currentSearchTerm = nil;
    self.currentPlaceId = nil;
}

- (NSInteger)numberOfResults
{
    return self.searchResults.count;
}

- (void)searchFlickrForTerm:(NSString *)term completionBlock:(void (^)(NSError *error))completionBlock
{
    NSString *searchTerm = [term lowercaseString];
    if (![searchTerm isEqualToString:self.currentSearchTerm]) {
        [self resetSearch];
        self.currentSearchTerm = searchTerm;
    }
    
    if (!self.currentPlaceId) {
        [self.flickr searchFlickrForLocation:term completionBlock:^(NSString *placeId, NSError *error) {
            if (!error) {
                [self searchFlickrByPlace:placeId completionBlock:completionBlock];
                self.currentPlaceId = placeId;
            } else {
                if (completionBlock) {
                    completionBlock(error);
                }
            }
        }];
    } else {
        [self searchFlickrByPlace:self.currentPlaceId completionBlock:completionBlock];
    }
}

- (void)searchFlickrByPlace:(NSString *)placeId completionBlock:(void (^)(NSError *error))completionBlock
{
    [self.flickr searchFlickrForTerm:placeId page:self.page + 1 completionBlock:^(NSString *searchTerm, NSArray *results, NSInteger totalCount, NSError *error) {
        if (!error) {
            [self.searchResults addObjectsFromArray:results];
            self.page += 1;
            self.totalCount = totalCount;
        }
        if (completionBlock) {
            completionBlock(error);
        }
    }];
}

- (BOOL)canLoadNextPage
{
    return self.totalCount > self.searchResults.count;
}

- (void)loadNextPageWithCompletionBlock:(void (^)(NSError *error))completionBlock
{
    if ([self canLoadNextPage]) {
        [self searchFlickrForTerm:self.currentSearchTerm completionBlock:completionBlock];
    } else {
        if (completionBlock) {
            completionBlock(nil);
        }
    }
}

- (void)loadPhotoAtIndex:(NSInteger)index completionBlock:(PhotoCompletionBlock)completionBlock;
{
    FlickrPhoto *flickrPhotoAtIndex = self.searchResults[index];
    
    if (flickrPhotoAtIndex.largeImage) {
        completionBlock(index, flickrPhotoAtIndex.largeImage);
    } else {
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
