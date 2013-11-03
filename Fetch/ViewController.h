//
//  ViewController.h
//  Fetch
//
//  Created by Andrew Miller on 2013/11/02.
//  Copyright (c) 2013 Fetch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController
                            <CLLocationManagerDelegate,
                             UICollectionViewDataSource,
                             UICollectionViewDelegateFlowLayout>


@end
