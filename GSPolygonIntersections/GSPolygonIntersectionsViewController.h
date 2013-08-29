//
//  GSPolygonIntersectionsViewController.h
//  GSPolygonIntersections
//
//  Created by Chad Saxon on 8/29/13.
//  Copyright (c) 2013 GeekSweep Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface GSPolygonIntersectionsViewController : UIViewController<CLLocationManagerDelegate, MKMapViewDelegate, MKAnnotation, UITextFieldDelegate>{
    
    
    CLLocationManager *locationManager;
    IBOutlet MKMapView *map;
    IBOutlet UITextField *polygonTitle;
    __weak IBOutlet UIButton *addShapeButton;
}

- (IBAction)addNewShape:(id)sender;

@end
