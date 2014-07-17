//
//  Map.h
//  WePray
//
//  Created by BaoAnh on 6/15/14.
//  Copyright (c) 2014 BaoAnh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DisplayMap.h"
#import <CoreLocation/CoreLocation.h>
#import "JPSThumbnail.h"
#import "JPSThumbnailAnnotation.h"

#import "UserManager.h"
#import "AlertViewManager.h"
#import "DatabaseManager.h"

@interface Map : UIViewController<MKMapViewDelegate,MKAnnotation, CLLocationManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>{
    IBOutlet MKMapView *mapView;
    CLLocationManager *locationManager;
    NSMutableArray *dataSource;     //contains list user need to show in map
    NSMutableArray *listCitys;     // store list city of current user
    
    IBOutlet UIPickerView *pickerCity;
    IBOutlet UIView *viewPicker;
    NSString *citySelected;
}

@property NSString *_address;

@end
