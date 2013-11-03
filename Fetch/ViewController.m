//
//  ViewController.m
//  Fetch
//
//  Created by Andrew Miller on 2013/11/02.
//  Copyright (c) 2013 Fetch. All rights reserved.
//

#import "ViewController.h"
#import "Dog.h"
#import "DogCell.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *zipCodeLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *zipCodeActivity;
@property (weak, nonatomic) IBOutlet UICollectionView *dogsView;

@end

@implementation ViewController

CLLocationManager *locationManager;
NSString *zipCode;
bool gettingZipCode;
NSMutableArray *dogs;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [locationManager startUpdatingLocation];
    
    self.dogsView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getDogs
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString:@"http://getfetch.co/data/dogs.json"]];
        NSError* error;
        NSArray *json = [NSJSONSerialization
                JSONObjectWithData:data
                options:kNilOptions
                error:&error];
        
        dogs = [[NSMutableArray alloc] init];
        for(int i = 0; i < [json count]; i++)
            [dogs addObject:[[Dog alloc]initWithDictionary:json[i]]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.dogsView reloadData];
        });
    });
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);

    [self.zipCodeActivity stopAnimating];
    self.zipCodeLabel.text = @"Error";
    [self.zipCodeLabel setHidden:false];

    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error"
                               message:@"Failed to Get Your Location"
                               delegate:nil
                               cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil && !gettingZipCode) {
        gettingZipCode = true;
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];

        [self.zipCodeActivity startAnimating];
        [self.zipCodeLabel setHidden:true];
        NSLog(@"Getting zip code");
        [geocoder reverseGeocodeLocation:currentLocation
                       completionHandler:^(NSArray *placemarks, NSError *error) {
                           if(error == nil && [placemarks count] > 0) {
                               CLPlacemark *placemark = [placemarks lastObject];
                               zipCode = placemark.postalCode;
                               self.zipCodeLabel.text = placemark.postalCode;
                               [locationManager stopUpdatingLocation];
                               [self getDogs];
                           } else {
                               NSLog(@"%@", error.debugDescription);
                               self.zipCodeLabel.text = @"Error";
                           }
                           NSLog(@"Done getting zip code");
                           [self.zipCodeActivity stopAnimating];
                           [self.zipCodeLabel setHidden:false];
                           gettingZipCode = false;
        }];
    }
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    if(dogs)
        return [dogs count];
    else
        return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    DogCell *cell = [collectionView
                     dequeueReusableCellWithReuseIdentifier:@"DogCell"
                     forIndexPath:indexPath];
    
    cell.dog = dogs[indexPath.row];
    return cell;
}

@end
