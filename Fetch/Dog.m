//
//  Dog.m
//  Fetch
//
//  Created by Andrew Miller on 2013/11/02.
//  Copyright (c) 2013 Fetch. All rights reserved.
//

#import "Dog.h"

@implementation Dog
@synthesize photo = _photo;

-(Dog *)initWithDictionary:(NSDictionary *)dictionary
{
    _name = [dictionary objectForKey:@"name"];
    NSString *photoURLString = [dictionary objectForKey:@"photoUrls"][0];
    if(![photoURLString hasPrefix:@"http"])
        photoURLString = [NSString stringWithFormat:@"http://getfetch.co%@",
                          photoURLString];
    _photoURL = [NSURL URLWithString:photoURLString];
    return self;
}

-(bool)photoCached
{
    return _photo != nil;
}

- (UIImage *)photo {
    if(!self.photoCached) {
        NSLog(@"Downloading photo for %@, %@", self.name, self.photoURL);
        _photo = [UIImage imageWithData:
                  [NSData dataWithContentsOfURL:self.photoURL]];
    }
    
    return _photo;
}

- (void)photoWithBlock:(void(^)(Dog *))block {
    if(_photo) {
        block(self);
    } else {
        dispatch_queue_t downloadQueue = dispatch_queue_create("Image Download",
                                                               NULL);
        dispatch_async(downloadQueue, ^{
            [self photo];
            block(self);
        });
    }
}


@end
