//
//  Dog.h
//  Fetch
//
//  Created by Andrew Miller on 2013/11/02.
//  Copyright (c) 2013 Fetch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Dog : NSObject
@property (readonly) NSString *name;
@property (readonly) NSURL *photoURL;
@property (readonly, nonatomic) UIImage *photo;

-(bool)photoCached;

-(Dog*)initWithDictionary:(NSDictionary*)dictionary;
- (void)photoWithBlock:(void(^)(Dog *))block;
@end
