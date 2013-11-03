//
//  DogCell.m
//  Fetch
//
//  Created by Andrew Miller on 2013/11/02.
//  Copyright (c) 2013 Fetch. All rights reserved.
//

#import "DogCell.h"

@interface DogCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *gradientView;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation DogCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(UICollectionView*)collectionView
{
    return (UICollectionView*)self.superview;
}

- (void)setDog:(Dog *)dog
{
    if(_dog != dog) {
        _dog = dog;
        
        self.label.text = dog.name;
        
        if([self.gradientView.subviews count] < 2) {
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = self.gradientView.bounds;
            gradient.colors = [NSArray arrayWithObjects:
                               (id)[[UIColor colorWithRed:0/255.0
                                                    green:0/255.0
                                                     blue:0/255.0
                                                    alpha:0.0] CGColor],
                               (id)[[UIColor colorWithRed:0/255.0
                                                    green:0/255.0
                                                     blue:0/255.0
                                                    alpha:0.7] CGColor],
                               nil];
            
            [self.gradientView.layer insertSublayer:gradient atIndex:0];
        }

        if(dog.photoCached) {
            self.imageView.image = dog.photo;
            
            // Fade in, but only if it is the first time we've displayed this image
            if(!dog.imageDisplayed) {
                self.imageView.alpha = 0.0;
                [UIView animateWithDuration:0.5 animations:^{
                    self.imageView.alpha = 1.0;
                }];
                dog.imageDisplayed = true;
            }
        } else {
            [dog photoWithBlock:^(Dog* photoDog) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Got photo for %@", photoDog.name);
                    NSIndexPath *indexPath = [self.collectionView indexPathForCell: self];
                    if(self.dog == photoDog && indexPath)
                        [self.collectionView reloadItemsAtIndexPaths:
                         [NSArray arrayWithObject:indexPath]];
                    else
                        NSLog(@"Skipping image update because data changed");
                });
            }];
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
