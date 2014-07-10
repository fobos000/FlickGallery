//
//  FGTableViewCell.m
//  FlickGallery
//
//  Created by Ostap Horbach on 7/9/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "FGTableViewCell.h"

@interface FGTableViewCell ()

@property (nonatomic, strong) IBOutlet UIImageView *photoView;

@end

@implementation FGTableViewCell

- (void)setPhoto:(UIImage *)photo
{
    self.photoView.image = photo;
}

@end
