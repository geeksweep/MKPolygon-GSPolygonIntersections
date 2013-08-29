//
//  MKPolygon+GSPolygonIntersections.h
//  GSPolygonIntersections
//
//  Created by Chad Saxon on 8/29/13.
//  Copyright (c) 2013 GeekSweep Studios LLC. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKPolygon (GSPolygonIntersections){
    
}
+(MKPolygon *)polygon:(MKPolygon *)poly1 intersectedWithSecondPolygon:(MKPolygon *)poly2;
+(BOOL)polygon:(MKPolygon *)poly1 intersectsPolygon:(MKPolygon *)poly2;

@end
