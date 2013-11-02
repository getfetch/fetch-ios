//
//  ViewController.m
//  Fetch
//
//  Created by Andrew Miller on 2013/11/02.
//  Copyright (c) 2013 Fetch. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *zipCodeLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *zipCodeActivity;

@end

@implementation ViewController

CLLocationManager *locationManager;
NSString *zipCode;
bool gettingZipCode;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getDogs
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Getting Dogs"
                          message:[NSString stringWithFormat:
                                   @"Getting dogs for location %@", zipCode]
                          delegate:nil
                          cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
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

@end
