//
//  FGFlickrDataSource.h
//  FlickGallery
//
//  Created by Ostap Horbach on 7/9/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PhotoCompletionBlock)(NSInteger index, UIImage *photo);

@interface FGFlickrDataSource : NSObject

@property (nonatomic, readonly) NSInteger numberOfResults;

- (id)initWithAPIKey:(NSString *)apiKey;

- (void)searchFlickrForTerm:(NSString *)term completionBlock:(void (^)(NSError *error))completionBlock;
- (void)loadNextPageWithCompletionBlock:(void (^)(NSError *error))completionBlock;
- (void)loadPhotoAtIndex:(NSInteger)index completionBlock:(PhotoCompletionBlock)completionBlock;

@end
