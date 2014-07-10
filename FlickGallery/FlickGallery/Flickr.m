//
//  Flickr.m
//  Flickr Search
//
//  Created by Brandon Trebitowski on 6/28/12.
//  Copyright (c) 2012 Brandon Trebitowski. All rights reserved.
//

#import "Flickr.h"
#import "FlickrPhoto.h"

static NSString* const kFlickrAPIKey = @"d02c877c0a4220890f14fc95f8b16983";

@implementation Flickr

+ (NSString *)flickrLocationSearchURLForSearchTerm:(NSString *)searchTerm
{
    NSString *term = [searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.places.find&api_key=%@&query=%@&format=json&nojsoncallback=1",
            kFlickrAPIKey, term];
}

+ (NSString *)flickrSearchURLForSearchTerm:(NSString *)searchTerm page:(NSInteger)page
{
    NSString *term = [searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&place_id=%@&page=%d&per_page=20&format=json&nojsoncallback=1",
            kFlickrAPIKey, term, page];
}

+ (NSString *)flickrPhotoURLForFlickrPhoto:(FlickrPhoto *) flickrPhoto size:(NSString *) size
{
    if(!size)
    {
        size = @"q";
    }
    return [NSString stringWithFormat:@"http://farm%d.staticflickr.com/%d/%lld_%@_%@.jpg",flickrPhoto.farm,flickrPhoto.server,flickrPhoto.photoID,flickrPhoto.secret,size];
}

- (void)searchFlickrForLocation:(NSString *)location completionBlock:(FlickrLocationSearchCompletionBlock)completionBlock
{
    NSString *searchURL = [Flickr flickrLocationSearchURLForSearchTerm:location];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        NSError *error = nil;
        NSString *searchResultString = [NSString stringWithContentsOfURL:[NSURL URLWithString:searchURL]
                                                                encoding:NSUTF8StringEncoding
                                                                   error:&error];
        
        if (error != nil) {
            completionBlock(nil, error);
        } else {
            // Parse the JSON Response
            NSData *jsonData = [searchResultString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *searchResultsDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                              options:kNilOptions
                                                                                error:&error];
            if (error != nil) {
                completionBlock(nil, error);
            } else {
                NSArray *places = searchResultsDict[@"places"][@"place"];
                NSDictionary *firstPlace = places.firstObject;
                if (firstPlace) {
                    NSString *placeId = [firstPlace objectForKey:@"place_id"];
                    completionBlock(placeId, nil);
                } else {
                    error = [NSError errorWithDomain:@"Flickr" code:-1 userInfo:nil];
                    completionBlock(nil, error);
                }
            }
        }
    });
}

- (void)searchFlickrForTerm:(NSString *)term page:(NSInteger)page completionBlock:(FlickrPhotoSearchCompletionBlock)completionBlock
{
    NSString *searchURL = [Flickr flickrSearchURLForSearchTerm:term page:page];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        NSError *error = nil;
        NSString *searchResultString = [NSString stringWithContentsOfURL:[NSURL URLWithString:searchURL]
                                                           encoding:NSUTF8StringEncoding
                                                              error:&error];
        if (error != nil) {
            completionBlock(term, nil, 0, error);
        }
        else
        {
            // Parse the JSON Response
            NSData *jsonData = [searchResultString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *searchResultsDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                              options:kNilOptions
                                                                                error:&error];
            if(error != nil)
            {
                completionBlock(term, nil, 0, error);
            } else {
                NSString * status = searchResultsDict[@"stat"];
                if ([status isEqualToString:@"fail"]) {
                    NSError * error = [[NSError alloc] initWithDomain:@"FlickrSearch" code:0 userInfo:@{NSLocalizedFailureReasonErrorKey: searchResultsDict[@"message"]}];
                    completionBlock(term, nil, 0, error);
                } else {
                    NSInteger totalCount = [searchResultsDict[@"photos"][@"total"] integerValue];
                    NSArray *objPhotos = searchResultsDict[@"photos"][@"photo"];
                    NSMutableArray *flickrPhotos = [@[] mutableCopy];
                    for(NSMutableDictionary *objPhoto in objPhotos)
                    {
                        FlickrPhoto *photo = [[FlickrPhoto alloc] init];
                        photo.farm = [objPhoto[@"farm"] intValue];
                        photo.server = [objPhoto[@"server"] intValue];
                        photo.secret = objPhoto[@"secret"];
                        photo.photoID = [objPhoto[@"id"] longLongValue];
                        
                        NSString *searchURL = [Flickr flickrPhotoURLForFlickrPhoto:photo size:@"m"];
                        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:searchURL]
                                                                  options:0
                                                                    error:&error];
                        UIImage *image = [UIImage imageWithData:imageData];
                        photo.thumbnail = image;
                        
                        [flickrPhotos addObject:photo];
                    }
                    
                    completionBlock(term, flickrPhotos, totalCount, nil);
                }
            }
        }
    });
}

+ (void)loadImageForPhoto:(FlickrPhoto *)flickrPhoto thumbnail:(BOOL)thumbnail completionBlock:(FlickrPhotoCompletionBlock) completionBlock
{
    
    NSString *size = thumbnail ? @"m" : @"b";
    
    NSString *searchURL = [Flickr flickrPhotoURLForFlickrPhoto:flickrPhoto size:size];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        NSError *error = nil;
        
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:searchURL]
                                                  options:0
                                                    error:&error];
        if(error)
        {
            completionBlock(nil,error);
        }
        else
        {
            UIImage *image = [UIImage imageWithData:imageData];
            if([size isEqualToString:@"m"])
            {
                flickrPhoto.thumbnail = image;
            }
            else
            {
                flickrPhoto.largeImage = image;
            }
            completionBlock(image,nil);
        }
        
    });
}



@end
