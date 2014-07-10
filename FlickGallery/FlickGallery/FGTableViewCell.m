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

- (void)awakeFromNib
{
    [self.contentView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.contentView.layer setBorderWidth:0.5f];
}

- (void)setPhoto:(UIImage *)photo
{
    self.photoView.image = photo;
    
    if (photo) {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.5f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        
        [self.photoView.layer addAnimation:transition forKey:nil];
        [self.contentView.layer setBorderWidth:0.0f];
    } else {
        [self.contentView.layer setBorderWidth:0.5f];
    }
}

@end
