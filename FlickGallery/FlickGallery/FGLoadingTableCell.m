//
//  FGLoadingTableCell.m
//  FlickGallery
//
//  Created by Ostap Horbach on 7/10/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "FGLoadingTableCell.h"

@interface FGLoadingTableCell ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation FGLoadingTableCell

- (void)prepareForReuse
{
    [self.activityIndicator startAnimating];
}

@end
