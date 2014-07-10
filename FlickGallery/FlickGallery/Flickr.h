//
//  Flickr.h
//  Flickr Search
//
//  Created by Brandon Trebitowski on 6/28/12.
//  Copyright (c) 2012 Brandon Trebitowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FlickrPhoto;

typedef void (^FlickrLocationSearchCompletionBlock)(NSString *placeId, NSError *error);
typedef void (^FlickrPhotoSearchCompletionBlock)(NSString *searchTerm, NSArray *results, NSInteger totalCount, NSError *error);
typedef void (^FlickrPhotoCompletionBlock)(UIImage *photoImage, NSError *error);

@interface Flickr : NSObject

@property(strong) NSString *apiKey;

- (void)searchFlickrForLocation:(NSString *)location completionBlock:(FlickrLocationSearchCompletionBlock)completionBlock;
- (void)searchFlickrForTerm:(NSString *)term page:(NSInteger)page completionBlock:(FlickrPhotoSearchCompletionBlock)completionBlock;
+ (void)loadImageForPhoto:(FlickrPhoto *)flickrPhoto thumbnail:(BOOL)thumbnail completionBlock:(FlickrPhotoCompletionBlock)completionBlock;
+ (NSString *)flickrPhotoURLForFlickrPhoto:(FlickrPhoto *) flickrPhoto size:(NSString *) size;

@end
