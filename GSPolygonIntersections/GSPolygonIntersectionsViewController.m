//
//  MKPolygonIntersectionsViewController.m
//  MKPolygonIntersections
//
//  Created by Chad Saxon on 6/24/13.
//  Copyright (c) 2013 GeekSweep Studios LLC. All rights reserved.
//

#import "GSPolygonIntersectionsViewController.h"
#import "MKPolygon+GSPolygonIntersections.h"
#import <QuartzCore/QuartzCore.h>


@interface GSPolygonIntersectionsViewController (){
    UITapGestureRecognizer *mapTapRecognizer;
    CLLocationCoordinate2D *coords;
    BOOL addingShape;
    BOOL canAddPoints;
}

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic) float zoomscale;
@property (nonatomic) NSString *currentPolygonTitle;
@property (nonatomic, strong) NSMutableArray *dictionaryOfPolygons;
@property (nonatomic, strong) NSMutableArray *path;
@property (nonatomic, strong) MKCircle *circle;
@property (nonatomic, strong) MKPolyline *polyLine;
@property (nonatomic, strong) MKPolygonView *polygonView;
@property (nonatomic, strong) MKCircleView *pointCircleView;
@property (nonatomic, strong) MKPolylineView *polygonBorderView;
@property (nonatomic, strong) MKPolygonView *intersectedPolygonView;
@property (nonatomic, strong) MKPolygon *myPolygon;
@property (nonatomic, strong) MKPolygon *intersectedPolygon;


-(void)drawCircleWithCoordinate:(CLLocationCoordinate2D)coord;
-(void)drawPolygonBorder;

@end

@implementation GSPolygonIntersectionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [map setShowsUserLocation:NO];
    
    mapTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addCoordinateToList:)];
    [mapTapRecognizer setNumberOfTapsRequired:1];
    [map addGestureRecognizer:mapTapRecognizer];
    
    addingShape = NO;
    addShapeButton.layer.borderWidth = 2.0;
    addShapeButton.layer.cornerRadius = 8.0;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        canAddPoints = NO;
        _coordinate = kCLLocationCoordinate2DInvalid;
        coords = NULL;
        addingShape = NO;
        canAddPoints = NO;
    }
    
    return self;
}

-(NSMutableArray *)dictionaryOfPolygons{
    if(!_dictionaryOfPolygons){
          _dictionaryOfPolygons = [[NSMutableArray alloc] init];
    }
    return _dictionaryOfPolygons;
}

-(NSMutableArray *)path{
    if(!_path){
        _path = [[NSMutableArray alloc] init];
    }
    
    return _path;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    _currentPolygonTitle = [textField text];
    NSLog(@"resigning first responder");
    [textField resignFirstResponder];
    polygonTitle.hidden = YES;
    polygonTitle.text = @"";
    canAddPoints = YES;
    return YES;
}

-(void)addCoordinateToList:(UITapGestureRecognizer*)recognizer{
    
    CGPoint tappedPoint = [recognizer locationInView:map];
    CLLocationCoordinate2D coord = [map convertPoint:tappedPoint toCoordinateFromView:map];
    //NSLog(@"Coordinate tapped: %f,%f", coord.latitude, coord.longitude);
    MKMapPoint mapPoint = MKMapPointForCoordinate(coord);
    NSLog(@"Corresponding MKMapPoint: %f,%f", mapPoint.x, mapPoint.y);
    
    if(canAddPoints){
        CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
        //Extension NSValue new for iOS6
        //[path addObject:[NSValue valueWithMKCoordinate:coord]];
        [self.path addObject:newLocation];
        
        [self drawCircleWithCoordinate:coord];
        [self drawPolygonBorder];
    }
}

-(void)drawCircleWithCoordinate:(CLLocationCoordinate2D)coord{
    
    self.circle = [MKCircle circleWithCenterCoordinate:coord radius:200];
    [map addOverlay:self.circle];
}

-(void)drawPolygonBorder{
    
    NSInteger numberOfCoordinates = [self.path count];

    if (numberOfCoordinates < 2)    // doesn't seem to make sense to draw a polygon with only one point
        return;

    if(coords != NULL)
        free(coords);
    coords = malloc(sizeof(CLLocationCoordinate2D) * numberOfCoordinates);
    
    for(int pathIndex = 0; pathIndex < numberOfCoordinates; pathIndex++){
        CLLocation *location = [self.path objectAtIndex:pathIndex];
        coords[pathIndex] = location.coordinate;
    }
    
    self.polyLine = [MKPolyline polylineWithCoordinates:coords count:numberOfCoordinates];
    [map addOverlay:self.polyLine];
}

-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay{
    
    if([overlay isKindOfClass:[MKCircle class]]){
        self.pointCircleView = [[MKCircleView alloc]initWithOverlay:overlay];
        self.pointCircleView.strokeColor = [UIColor greenColor];
        self.pointCircleView.fillColor = [UIColor redColor];
        self.pointCircleView.lineWidth = 4.0;
        return self.pointCircleView;
    }
    else if([overlay isKindOfClass:[MKPolyline class]]){
        self.polygonBorderView = [[MKPolylineView alloc] initWithPolyline:overlay];
        self.polygonBorderView.strokeColor = [UIColor blackColor];
        self.polygonBorderView.lineWidth = 1.0;
        return self.polygonBorderView;
    }
    else if([overlay isKindOfClass:[MKPolygon class]]){
        
        if([[overlay title] isEqualToString:@"intersectedPolygon"]){
            NSLog(@"drawing intersected polygon");
            self.intersectedPolygonView.strokeColor = [UIColor blackColor];
            self.intersectedPolygonView.lineWidth = 1.5;
            self.intersectedPolygonView.fillColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
            return self.intersectedPolygonView;
        }
        else{
            NSLog(@"drawing regular polygons");
            self.polygonView.strokeColor = [UIColor blackColor];
            self.polygonView.lineWidth = 1.0;
            self.polygonView.fillColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:0.4];
            return self.polygonView;
        }
    }

    return nil;
}

- (IBAction)addNewShape:(id)sender {
    
    if(!addingShape){
        addingShape = YES;
        canAddPoints = YES;
        [addShapeButton setTitle:@"Done" forState:UIControlStateNormal];
        addShapeButton.layer.borderColor = [[UIColor redColor] CGColor];
        
        [self.path removeAllObjects];
        self.path = nil;
        polygonTitle.hidden = NO;
        [polygonTitle becomeFirstResponder];
        
    }
    else{
        addingShape = NO;
        canAddPoints = NO;
        [addShapeButton setTitle:@"Add New Polygon" forState:UIControlStateNormal];
        addShapeButton.layer.borderColor = [[UIColor blackColor] CGColor];
        
        self.myPolygon = [MKPolygon polygonWithCoordinates:coords count:[self.path count]];
        self.myPolygon.title = [self currentPolygonTitle];
        self.polygonView = [[MKPolygonView alloc] initWithPolygon:self.myPolygon];
        [self.dictionaryOfPolygons addObject:self.myPolygon];
        if([self.myPolygon.title isEqual: @""]){
            self.myPolygon.title = @"default";
        }
        if(self.dictionaryOfPolygons.count == 2){
            self.intersectedPolygon = [MKPolygon polygon:[self.dictionaryOfPolygons objectAtIndex:0] intersectedWithSecondPolygon:[self.dictionaryOfPolygons objectAtIndex:1]];
            self.intersectedPolygon.title = @"intersectedPolygon";
            self.intersectedPolygonView = [[MKPolygonView alloc] initWithPolygon:self.intersectedPolygon];
            NSLog(@"intersected polygon has %i points", self.intersectedPolygon.pointCount);
            [map addOverlay:self.intersectedPolygon];
        }
        [map addOverlay:self.myPolygon];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
