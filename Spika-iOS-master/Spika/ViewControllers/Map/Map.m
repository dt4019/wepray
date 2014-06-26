//
//  Map.m
//  WePray
//
//  Created by BaoAnh on 6/15/14.
//  Copyright (c) 2014 BaoAnh. All rights reserved.
//

#import "Map.h"

#import "AppDelegate.h"

@interface Map ()

@end

@implementation Map

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"People arround me";
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    else
    {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    [mapView setMapType:MKMapTypeStandard];
    [mapView setZoomEnabled:YES];
    [mapView setScrollEnabled:YES];
    
    [self showCureentLocation];
    
//    [self getListUsers];
    
    [self startUpdates];
    
    
    // load list friends
    [[AlertViewManager defaultManager] showHUD];
    
    ModelUser *user = [UserManager defaultManager].getLoginedUser;
    
    NSString *latitude;
    NSString *longitude;
    NSArray *locations = [user.about componentsSeparatedByString:@","];
    if (locations.count == 2) {
        latitude = [locations firstObject];
        longitude = [locations lastObject];
    }
    
//    void(^successBlock)(id result) = ^(id result) {
//        [[AlertViewManager defaultManager] dismiss];
//        dataSource = [[NSMutableArray alloc]initWithArray:result];
//        [self pinUserToMap:user];
//        for (ModelUser *_user in dataSource) {
//            int index = [dataSource indexOfObject:_user] + 1;
////            double latitude = 10.779442 + index * 0.001;
////            double longitude = 106.632817 + index * 0.001;
//            _user.about = [NSString stringWithFormat:@"%f,%f", [latitude doubleValue] + index * 0.001, [longitude doubleValue] + index * 0.001];
//            [self pinUserToMap:_user];
//        }
//    };
//    
//    [[DatabaseManager defaultManager] findUserContactList:user
//                                                  success:successBlock
//                                                    error:nil];
    
    
    [[DatabaseManager defaultManager] findUsersContainingString:@""
                                                        fromAge:@0
                                                          toAge:@0
                                                         gender:@""
                                                        success:^(NSArray *users) {
                                                            [[AlertViewManager defaultManager] dismiss];
                                                            dataSource = [[NSMutableArray alloc]initWithArray:users];
                                                            [self pinUserToMap:user];
                                                            for (ModelUser *_user in dataSource) {
                                                                //             _user.about = [NSString stringWithFormat:@"%f,%f", [latitude doubleValue] + index * 0.001, [longitude doubleValue] + index * 0.001];
                                                                [self pinUserToMap:_user];
                                                            }
                                                        }
                                                          error:^(NSString *errorString) {
                                                              [[AlertViewManager defaultManager] dismiss];
                                                          }];
}
- (void)viewWillAppear:(BOOL)animated{
}
// Add this Method
- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Setting the title of the tab.
- (NSString *)tabTitle
{
    return @"People arround me";
}

#pragma mark - Delegate of MapView
-(MKAnnotationView *)mapView:(MKMapView *)_mapView viewForAnnotation: (id <MKAnnotation>)annotation {
    MKPinAnnotationView *pinView = nil;
//    if(annotation != mapView.userLocation)
//    {
//        static NSString *defaultPinID = @"com.invasivecode.pin";
//        pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
//        if ( pinView == nil ) pinView = [[MKPinAnnotationView alloc]
//                                         initWithAnnotation:annotation reuseIdentifier:defaultPinID] ;
//        pinView.pinColor = MKPinAnnotationColorRed;
//        pinView.canShowCallout = YES;
//        pinView.animatesDrop = YES;
//    }
//    else {
//        [mapView.userLocation setTitle:@"I am here"];
//    }
    
    if ([annotation conformsToProtocol:@protocol(JPSThumbnailAnnotationProtocol)]) {
        return [((NSObject<JPSThumbnailAnnotationProtocol> *)annotation) annotationViewInMap:mapView];
    }
    return pinView;
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Your location could not be determined." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manage didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	// Disable future updates to save power.
    [locationManager stopUpdatingLocation];
    
    if(self._address == nil){
        // view location by longtitude and latitude
        [self viewLocationFromLongtitudeAndLatitude:newLocation];
        // create current user info
        
        ModelUser *user = [[ModelUser alloc]init];
        user.name = @"Me";
        user.email = @"";
        user.thumbImageUrl = @"https://www.remindnmore.com/images/individual.png";
        user.about = [NSString stringWithFormat:@"%f,%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude];
        // add current user to list
        [dataSource addObject:user];
        // pin all users to map
        for (ModelUser *user in dataSource) {
            [self pinUserToMap:user];
        }
    }else{
        // view location by address
        [self viewLocationByAddress:self._address];
    }
    
    
}

- (void)mapView:(MKMapView *)_mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)]) {
        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didSelectAnnotationViewInMap:mapView];
    }
}

- (void)mapView:(MKMapView *)_mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)]) {
        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didDeselectAnnotationViewInMap:mapView];
    }
}

#pragma mark - Show current location
-(void)showCureentLocation{
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta=0.2;
    span.longitudeDelta=0.2;
    locationManager = [[CLLocationManager alloc]init];
    CLLocationCoordinate2D location = [locationManager.location coordinate];
    
    region.span=span;
    region.center = location;
    
    mapView.showsUserLocation = TRUE;
    
//    [mapView setRegion:region animated:TRUE];
//    [mapView regionThatFits:region];
}
#pragma mark - Start update
- (void)startUpdates
{
    NSLog(@"Starting Location Updates");
    
    if (locationManager == nil)
        locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    
    // You have some options here, though higher accuracy takes longer to resolve.
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [locationManager startUpdatingLocation];
    
}
#pragma mark - Get longtitude and latitude from address
- (CLLocationCoordinate2D) geoCodeUsingAddress:(NSString *)address
{
    double latitude = 0, longitude = 0;
    NSString *esc_addr =  [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    if (result) {
        NSScanner *scanner = [NSScanner scannerWithString:result];
        if ([scanner scanUpToString:@"\"lat\" :" intoString:nil] && [scanner scanString:@"\"lat\" :" intoString:nil]) {
            [scanner scanDouble:&latitude];
            if ([scanner scanUpToString:@"\"lng\" :" intoString:nil] && [scanner scanString:@"\"lng\" :" intoString:nil]) {
                [scanner scanDouble:&longitude];
            }
        }
    }
    CLLocationCoordinate2D center;
    center.latitude = latitude;
    center.longitude = longitude;
    return center;
}
#pragma mark - View location from address
-(void)viewLocationByAddress:(NSString*)_strAddress{
    CLLocationCoordinate2D location = [self geoCodeUsingAddress:_strAddress];
    MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };
    region.center.latitude = location.latitude ;
    region.center.longitude = location.longitude;
    region.span.longitudeDelta = 0.01f;
    region.span.latitudeDelta = 0.01f;
    [mapView setRegion:region animated:YES];
    [mapView setDelegate:self];
    
    DisplayMap *ann = [[DisplayMap alloc] init];
    ann.coordinate = region.center;
    ann.title = self._address;
    [mapView addAnnotation:ann];
}
#pragma mark - View location longtitude and latitude
-(void)viewLocationFromLongtitudeAndLatitude:(CLLocation *)location{
    MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };
    region.center.latitude = location.coordinate.latitude ;
    region.center.longitude = location.coordinate.longitude;
    region.span.longitudeDelta = 0.01f;
    region.span.latitudeDelta = 0.01f;
    [mapView setRegion:region animated:YES];
    [mapView setDelegate:self];
    
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       NSLog(@"reverseGeocodeLocation:completionHandler: Completion Handler called!");
                       
                       if (error){
                           NSLog(@"Geocode failed with error: %@", error);
                           return;
                           
                       }
                       
                       // get name address by location
                       CLPlacemark *placemark = [placemarks objectAtIndex:0];
                       
                       DisplayMap *ann = [[DisplayMap alloc] init];
                       ann.coordinate = region.center;
                       
                       NSString *_street =      placemark.subThoroughfare;
                       NSString *_district =    placemark.subLocality;
                       if(_street == nil){
                           _street = @"";
                       }
                       if(_district == nil){
                           _district = @"";
                       }
                       NSString *title_ = [_street stringByAppendingString:[NSString stringWithFormat:@"  %@", _district]];
                       ann.title = title_;
                       
                       NSString *_state =       placemark.administrativeArea;
                       NSString *_country =     placemark.country;
                       if(_state == nil){
                           _state = @"";
                       }
                       if(_country == nil){
                           _country = @"";
                       }
                       NSString *_subTitle = [_state stringByAppendingString:[NSString stringWithFormat:@"  %@", _country]];
                       ann.subtitle = _subTitle;
                       
                       [mapView addAnnotation:ann];
                   }];
    
}

- (void)pinUserToMap:(ModelUser *)user{
    JPSThumbnail *thumbnail = [[JPSThumbnail alloc] init];
//    thumbnail.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:user.image]]];
    if (user.thumbImageUrl) {
        thumbnail.urlImage = [NSURL URLWithString:user.thumbImageUrl];
    }
    thumbnail.title = user.name;
    thumbnail.subtitle = user.email;
    // get latitude and longitude from about
    NSString *latitude;
    NSString *longitude;
    NSArray *locations = [user.about componentsSeparatedByString:@","];
    if (locations.count == 2) {
        latitude = [locations firstObject];
        longitude = [locations lastObject];
        
        thumbnail.coordinate = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
        thumbnail.disclosureBlock = ^{
            NSLog(@"selected Empire");
            [[AppDelegate getInstance].tabBarController setSelectedIndex:0];
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowProfile object:user];
        };
        
        [mapView addAnnotation:[JPSThumbnailAnnotation annotationWithThumbnail:thumbnail]];
    }
}

@end
