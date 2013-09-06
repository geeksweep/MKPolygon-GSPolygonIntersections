//
//  MKPolygon+MKPolygonIntersections.m
//  TestPolygons
//
//  Created by Chad Saxon on 5/23/13.
//  Copyright (c) 2013 com.geeksweep. All rights reserved.
//

#import "MKPolygon+GSPolygonIntersections.h"

@implementation MKPolygon (GSPolygonIntersections)

/* This method calculates the intersection point between two lines and returns that point as a NSString for storage in a Dictionary
 1. The intersection is computed by calculating the slope of each line then solving the system of linear equations between those slopes.
 2. This method tests for the following special cases:
 2a. Whether both lines are parallel along the x or y-axis which would result in no interesections, even if the lines are infinite.
 2b. Whether the X-Coordinate for either line 1 or line 2 is the same which would result in an undefined slope. Solves for Y(either on line 1 or line 2) based on X-value
 2c. Whether the Y-Coordinate for either line 1 or line 2 is the same. Solves for X(either on line 1 or line 2) based on Y-value
 2d. Tests whether the lines do actually intersect using two different line segment tests. Solving the system of linear equations gives you the intersection
 of two lines assuming that the lines are infinite - that is at some point, if the lines are not parrallel with each other, they will intersect. This causes a problem,
 in that most lines are not infinite in nature and are technically line segments and even though they would intersect in an infinite space, they, in fact on the
 MKMapView, are finite with an ending point that may or may not actually intersect a perpendicular line. These two line segment tests solve this problem.
 3. If there is no intersection this method returns an empty string. */

+(NSString *)calculateIntersectionFrom:(MKMapPoint)line1FirstPoint and:(MKMapPoint)line1SecondPoint andFrom:(MKMapPoint)line2FirstPoint and:(MKMapPoint)line2SecondPoint{
    
    double intersectX;
    double intersectY;
    double line1_x1 = line1FirstPoint.x;
    double line1_y1 = line1FirstPoint.y;
    double line1_x2 = line1SecondPoint.x;
    double line1_y2 = line1SecondPoint.y;
    
    double line2_x1 = line2FirstPoint.x;
    double line2_y1 = line2FirstPoint.y;
    double line2_x2 = line2SecondPoint.x;
    double line2_y2 = line2SecondPoint.y;
    
    //linear equation
    //(y - y1) = slope(x-x1)
    
    double line1_slope = ( (line1_y2 - line1_y1) / (line1_x2 - line1_x1) );
    double line2_slope = ( (line2_y2 - line2_y1) / (line2_x2 - line2_x1) );
    
    double line1Value = (line1_y1 >= 0) ? (line1_slope * (line1_x1 * -1)) + line1_y1 : (line1_slope * line1_x1) - line1_y1;
    double line2Value = (line2_y1 >= 0) ? (line2_slope * (line2_x1 * -1)) + line2_y1 : (line1_slope * line2_x1) - line2_y1;
    
    double equationSlope = line1_slope - line2_slope;
    double equationValue = line2Value - line1Value;
    
    //***testing special cases***//
    if(line1_x1 == line1_x2){
        intersectX = line1_x1;
        if(line2_x1 == line2_x2){
            //lines are parallel along the x-axis, will not intersect
            return @"";
        }
        else{
            //special case for when line 1 X is the same
            intersectY = (line2_slope * intersectX) + line2Value;
        }
    }
    
    else if(line2_x1 == line2_x2){
        //special case for when line 2 X is the same
        intersectX = line2_x1;
        intersectY = (line1_slope * intersectX) + line1Value;
    }
    
    else if(line1_y1 == line1_y2){
        intersectY = line1_y1;
        if(line2_y1 == line2_y2){
            //lines are parallel along the y-axis, will not interesect
            return @"";
        }
        else{
            intersectX = (intersectY + (line2Value * -1)) / line2_slope;
        }
    }
    else{
        //Technically in this case, you dont have to check for division by 0 as this doesnt cause a crash but checking here anyway because I'm a good boy
        //Also you dont want to set X to be equal to 0 in case you have a rare occasion that the (x,y) pair might pass both line segment tests.
        //Setting it to a big negative number instead.
        if(equationSlope != 0){
            intersectX = equationValue / equationSlope;
        }
        else{
            intersectX = -999999;
        }
        intersectY = (line2_slope * intersectX) + line2Value;
    }
    
    if( (intersectX >= MIN(line2_x1, line2_x2)) && (intersectX <= MAX(line2_x1, line2_x2)) && (intersectY >= MIN(line2_y1, line2_y2)) && (intersectY <= MAX(line2_y1, line2_y2))){
        //NSLog(@"passed first line segment test");
        if( (intersectX >= MIN(line1_x1, line1_x2)) && (intersectX <= MAX(line1_x1, line1_x2)) && (intersectY >= MIN(line1_y1, line1_y2)) && (intersectY <= MAX(line1_y1, line1_y2))){
            //NSLog(@"passed second line segment test");
            return [NSString stringWithFormat:@"%f,%f", intersectX, intersectY];
        }
        else{
            return @"";
        }
    }
    else{
        return @"";
    }
}

//returns a single polygon from the intersection of two polygons
+(MKPolygon *)polygon:(MKPolygon *)poly1 intersectedWithSecondPolygon:(MKPolygon *)poly2{
    
    NSString *newIntersectionPoint;
    NSMutableDictionary *intersectionInfo = [[NSMutableDictionary alloc] init];
    NSMutableArray *finalPolygon = [NSMutableArray array];
    CGMutablePathRef originalPolygon1Path;
    CGMutablePathRef originalPolygon2Path;
    BOOL foundIntersection = NO;
    
    int poly1Count = poly1.pointCount;
    MKMapPoint polygon1Points[poly1Count * 2];
    for(int points1Index = 0; points1Index < poly1Count; points1Index++){
        polygon1Points[points1Index * 2] = poly1.points[points1Index];
        if((points1Index+1) == poly1Count){
            polygon1Points[(points1Index * 2) + 1] = poly1.points[0];
        }
        else{
            polygon1Points[(points1Index * 2) + 1] = poly1.points[points1Index + 1];
        }
    }
    
    MKPolygon *polygon1 = [MKPolygon polygonWithPoints:polygon1Points count:poly1Count * 2];
    
    
    int poly2Count = poly2.pointCount;
    MKMapPoint polygon2Points[poly2Count * 2];
    for(int points2Index = 0; points2Index < poly2.pointCount; points2Index++){
        polygon2Points[points2Index * 2] = poly2.points[points2Index];
        if((points2Index+1) == poly2Count){
            polygon2Points[(points2Index * 2) + 1] = poly2.points[0];
        }
        else{
            polygon2Points[(points2Index * 2) + 1] = poly2.points[points2Index + 1];
        }
    }
    
    MKPolygon *polygon2 = [MKPolygon polygonWithPoints:polygon2Points count:poly2Count * 2];
    
    int MKPolygon1Count = polygon1.pointCount;
    int MKPolygon2Count = polygon2.pointCount;
    
    originalPolygon1Path = CGPathCreateMutable();
    for(int poly1Index = 0; poly1Index < MKPolygon1Count-1; poly1Index++){
        
        if(poly1Index == 0){
            CGPathMoveToPoint(originalPolygon1Path, NULL, polygon1.points[poly1Index].x, polygon1.points[poly1Index].y);
        }
        else{
            CGPathAddLineToPoint(originalPolygon1Path, NULL, polygon1.points[poly1Index].x, polygon1.points[poly1Index].y);
        }
    }
    
    CGPathCloseSubpath(originalPolygon1Path);
    
    
    originalPolygon2Path = CGPathCreateMutable();
    for(int poly2Index = 0; poly2Index < MKPolygon2Count-1; poly2Index++){
        
        if(poly2Index == 0){
            CGPathMoveToPoint(originalPolygon2Path, NULL, polygon2.points[poly2Index].x, polygon2.points[poly2Index].y);
        }
        else{
            CGPathAddLineToPoint(originalPolygon2Path, NULL, polygon2.points[poly2Index].x, polygon2.points[poly2Index].y);
        }
    }
    
    CGPathCloseSubpath(originalPolygon2Path);
    
    
    for(int points1Index = 0; points1Index < MKPolygon1Count; points1Index+=2){
        
        MKMapPoint line1MKFirstPoint = MKMapPointMake(polygon1.points[points1Index].x, polygon1.points[points1Index].y);
        MKMapPoint line1MKSecondPoint = MKMapPointMake(polygon1.points[points1Index+1].x, polygon1.points[points1Index+1].y);
        
        for(int points2Index = 0; points2Index < MKPolygon2Count; points2Index+=2){
            
            MKMapPoint line2MKFirstPoint = MKMapPointMake(polygon2.points[points2Index].x, polygon2.points[points2Index].y);
            MKMapPoint line2MKSecondPoint = MKMapPointMake(polygon2.points[points2Index+1].x, polygon2.points[points2Index+1].y);
            newIntersectionPoint = [self calculateIntersectionFrom:line1MKFirstPoint and:line1MKSecondPoint andFrom:line2MKFirstPoint and:line2MKSecondPoint];
            if(![newIntersectionPoint isEqualToString:@""]){
                NSString *intersectsWithLineAtPoint = [[[NSString stringWithFormat:@"%i", points2Index / 2] stringByAppendingString:@";"] stringByAppendingString:newIntersectionPoint];
                [intersectionInfo setObject:[NSNumber numberWithInt:(points1Index / 2)] forKey:intersectsWithLineAtPoint];
            }
        }
    }
    
    for(int points1Index = 0; points1Index < MKPolygon1Count / 2; points1Index++){
        CGPoint firstpoint;
        CGPoint secondPoint;
        firstpoint.x = polygon1.points[points1Index * 2].x;
        firstpoint.y = polygon1.points[points1Index * 2].y;
        secondPoint.x = polygon1.points[(points1Index * 2) +1].x;
        secondPoint.y = polygon1.points[(points1Index * 2) +1].y;

        //NSLog(@"checking first point %f,%f", firstpoint.x, firstpoint.y);
        if([self isPoint:firstpoint inside:originalPolygon2Path]){
            NSString *pointString = [NSString stringWithFormat:@"%f,%f", firstpoint.x, firstpoint.y];
            if(![finalPolygon containsObject:pointString]){
                [finalPolygon addObject:[NSString stringWithFormat:@"%f,%f", firstpoint.x, firstpoint.y]];
            }
        }
        
        NSArray *intersectionPoints = [self intersectPointsin:intersectionInfo forPointLine:points1Index withFirstPoint:firstpoint andSecondPoint:secondPoint];
        int intersectionCount = intersectionPoints.count;
        
        if(intersectionCount > 0){
            foundIntersection = YES;
        }
        
        for(int intersectionIndex = 0; intersectionIndex < intersectionCount; intersectionIndex++){
            
            int polygonIntersectionLine = [[[[intersectionPoints objectAtIndex:intersectionIndex] componentsSeparatedByString:@";"] objectAtIndex:0] intValue];
            
            CGPoint firstPointForPolygon2Line;
            CGPoint secondPointForPolygon2Line;
            firstPointForPolygon2Line.x = polygon2.points[polygonIntersectionLine * 2].x;
            firstPointForPolygon2Line.y = polygon2.points[polygonIntersectionLine * 2].y;
            secondPointForPolygon2Line.x = polygon2.points[(polygonIntersectionLine * 2) + 1].x;
            secondPointForPolygon2Line.y = polygon2.points[(polygonIntersectionLine * 2) + 1].y;
            
            if([self isPoint:firstPointForPolygon2Line inside:originalPolygon1Path]){
                NSString *pointString = [NSString stringWithFormat:@"%f,%f", firstPointForPolygon2Line.x, firstPointForPolygon2Line.y];
                if(![finalPolygon containsObject:pointString]){
                    [finalPolygon addObject:[NSString stringWithFormat:@"%f,%f", firstPointForPolygon2Line.x, firstPointForPolygon2Line.y]];
                }
            }
            
            //adding intersection point to our final polygon
            if(![finalPolygon containsObject:[[[intersectionPoints objectAtIndex:intersectionIndex] componentsSeparatedByString:@";"] objectAtIndex:1]]){
                [finalPolygon addObject:[[[intersectionPoints objectAtIndex:intersectionIndex] componentsSeparatedByString:@";"] objectAtIndex:1]];
            }
            
            if( ([self isPoint:secondPointForPolygon2Line inside:originalPolygon1Path]) && (![self otherIntersectionsExistForLine:polygonIntersectionLine afterLine:points1Index inDictionary:intersectionInfo]) ){
                NSString *pointString = [NSString stringWithFormat:@"%f,%f", secondPointForPolygon2Line.x, secondPointForPolygon2Line.y];
                if(![finalPolygon containsObject:pointString]){
                    [finalPolygon addObject:[NSString stringWithFormat:@"%f,%f", secondPointForPolygon2Line.x, secondPointForPolygon2Line.y]];
                }
                
                //if the second point of the line in polygon 2 that we intersected is within the polygon 1 path
                //then we want to make sure there are no other immediate lines after this one in polygon 2 that are also inside the polygon 1 path
                //that should be adding to the final polygon array.
                
                BOOL inside = YES;
                int fullLoop = 0;
                int internalIntersectionLine = polygonIntersectionLine+1;
                if(internalIntersectionLine >= MKPolygon2Count / 2){
                    internalIntersectionLine = 0;
                }
                
                while(inside){
                    if([self otherIntersectionsExistForLine:internalIntersectionLine afterLine:points1Index inDictionary:intersectionInfo]){
                        break;
                    }
                    CGPoint firstPointForPolygon2Line;
                    CGPoint secondPointForPolygon2Line;
                    firstPointForPolygon2Line.x = polygon2.points[internalIntersectionLine * 2].x;
                    firstPointForPolygon2Line.y = polygon2.points[internalIntersectionLine * 2].y;
                    secondPointForPolygon2Line.x = polygon2.points[(internalIntersectionLine * 2) + 1].x;
                    secondPointForPolygon2Line.y = polygon2.points[(internalIntersectionLine * 2) + 1].y;
                    
                    if([self isPoint:firstPointForPolygon2Line inside:originalPolygon1Path] && [self isPoint:secondPointForPolygon2Line inside:originalPolygon1Path]){
                        NSString *firstPointString = [NSString stringWithFormat:@"%f,%f", firstPointForPolygon2Line.x, firstPointForPolygon2Line.y];
                        NSString *secondPointString = [NSString stringWithFormat:@"%f,%f", secondPointForPolygon2Line.x, secondPointForPolygon2Line.y];
                        if(![finalPolygon containsObject:firstPointString]){
                            [finalPolygon addObject:firstPointString];
                        }
                        if(![finalPolygon containsObject:secondPointString]){
                            [finalPolygon addObject:secondPointString];
                        }
                        internalIntersectionLine++;
                        if(internalIntersectionLine >= MKPolygon2Count / 2){
                            internalIntersectionLine = 0;
                            fullLoop++;
                        }
                        if(fullLoop == 1){
                            break;
                        }
                    }
                    else{
                        inside = NO;
                    }
                }
            }
            
            if(intersectionIndex+1 != intersectionCount){
                NSLog(@"there are more lines that line %i crosses", points1Index);
            }
            else{
                if([self isPoint:secondPoint inside:originalPolygon2Path]){
                    NSString *pointString = [NSString stringWithFormat:@"%f,%f", secondPoint.x, secondPoint.y];
                    if(![finalPolygon containsObject:pointString]){
                        [finalPolygon addObject:[NSString stringWithFormat:@"%f,%f", secondPoint.x, secondPoint.y]];
                    }
                }
            }
        }
    }
    
    //if we didnt find any intersections at all then we have to check to see if polygon 2 was completely outside polygon 1 or completely inside
    //If the first point of polygon 2 is inside the polygon 1 path we know that polgon 2 is completely inside polygon 1 being that there are no
    //intersections.
    if(!foundIntersection){
        NSLog(@"There were no intersections found, testing for completely inside or outside");
        CGPoint firstPointForPolygon2Line;
        firstPointForPolygon2Line.x = polygon2.points[0].x;
        firstPointForPolygon2Line.y = polygon2.points[0].y;
        
        if([self isPoint:firstPointForPolygon2Line inside:originalPolygon1Path]){
            for(int points2Index = 0; points2Index < MKPolygon2Count / 2; points2Index++){
                NSString *pointString = [NSString stringWithFormat:@"%f,%f", polygon2.points[points2Index * 2].x, polygon2.points[points2Index * 2].y];
                [finalPolygon addObject:pointString];
            }
        }
    }
    
    int count = finalPolygon.count;
    MKMapPoint finalPolygonPoints[count];
    
    for(int index = 0; index < count; index++){
        NSArray *lineSplit = [[finalPolygon objectAtIndex:index] componentsSeparatedByString:@","];
        finalPolygonPoints[index] = MKMapPointMake([[lineSplit objectAtIndex:0] doubleValue], [[lineSplit objectAtIndex:1] doubleValue]);
    }
    
    MKPolygon *finalMKPolygon = [MKPolygon polygonWithPoints:finalPolygonPoints count:count];

    CGPathRelease(originalPolygon1Path);
    CGPathRelease(originalPolygon2Path);

    return finalMKPolygon;
}

+(BOOL)isPoint:(CGPoint)point inside:(CGPathRef)polygonPath{
    
    if(CGPathContainsPoint(polygonPath, NULL, point, NO)){
        return YES;
    }
    else{
        return NO;
    }
}

+(NSArray *)intersectPointsin:(NSDictionary *)intersectionDictionary forPointLine:(int)polygonPointIndex withFirstPoint:(CGPoint)firstPoint andSecondPoint:(CGPoint)secondPoint{
    
    NSArray *sortedIntersectArray;
    NSArray *intersectArray = [intersectionDictionary allKeysForObject:[NSNumber numberWithInt:polygonPointIndex]];
    
    if(firstPoint.x > secondPoint.x){
        sortedIntersectArray = [intersectArray sortedArrayUsingComparator:^(id string1, id string2){
            NSString *str1 = [(NSString *)string1 substringWithRange:NSMakeRange([string1 rangeOfString:@";"].location, [string1 length] - [string1 rangeOfString:@";"].location)];
            NSString *str2 = [(NSString *)string2 substringWithRange:NSMakeRange([string2 rangeOfString:@";"].location, [string2 length] - [string2 rangeOfString:@";"].location)];
            return [str2 compare:str1 options:NSNumericSearch];
        }];
    }
    else if(firstPoint.x < secondPoint.x){
        sortedIntersectArray = [intersectArray sortedArrayUsingComparator:^(id string1, id string2){
            NSString *str1 = [(NSString *)string1 substringWithRange:NSMakeRange([string1 rangeOfString:@";"].location, [string1 length] - [string1 rangeOfString:@";"].location)];
            NSString *str2 = [(NSString *)string2 substringWithRange:NSMakeRange([string2 rangeOfString:@";"].location, [string2 length] - [string2 rangeOfString:@";"].location)];
            return [str1 compare:str2 options:NSNumericSearch];
        }];
        
    }
    else if(firstPoint.x == secondPoint.x){
        
        if(firstPoint.y > secondPoint.y){
            sortedIntersectArray = [intersectArray sortedArrayUsingComparator:^(id string1, id string2){
                NSString *str1 = [(NSString *)string1 substringWithRange:NSMakeRange([string1 rangeOfString:@","].location, [string1 length] - [string1 rangeOfString:@","].location)];
                NSString *str2 = [(NSString *)string2 substringWithRange:NSMakeRange([string2 rangeOfString:@","].location, [string2 length] - [string2 rangeOfString:@","].location)];
                return [str2 compare:str1 options:NSNumericSearch];
            }];
        }
        else if(firstPoint.y < secondPoint.y){
            sortedIntersectArray = [intersectArray sortedArrayUsingComparator:^(id string1, id string2){
                NSString *str1 = [(NSString *)string1 substringWithRange:NSMakeRange([string1 rangeOfString:@","].location, [string1 length] - [string1 rangeOfString:@","].location)];
                NSString *str2 = [(NSString *)string2 substringWithRange:NSMakeRange([string2 rangeOfString:@","].location, [string2 length] - [string2 rangeOfString:@","].location)];
                return [str1 compare:str2 options:NSNumericSearch];
            }];
        }
    }
    
    return sortedIntersectArray;
    
}

//are there any more lines that cross the current line that we currently interested in?
+(BOOL)otherIntersectionsExistForLine:(int)intersectedLineNumber afterLine:(int)lineNumber inDictionary:(NSDictionary *)intersectionDictionary{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH %@", [[NSString stringWithFormat:@"%i", intersectedLineNumber] stringByAppendingFormat:@";"]];
    NSArray *filteredDictionary = [[intersectionDictionary allKeys] filteredArrayUsingPredicate:predicate];
    NSLog(@"filtered dict: %@", filteredDictionary);
    BOOL found = NO;
    int count = filteredDictionary.count;
    for(int index = 0; index < count; index++){
        if([[intersectionDictionary objectForKey:[filteredDictionary objectAtIndex:index]] intValue] > lineNumber){
            found = YES;
            break;
        }
    }
    return (found) ? YES : NO;
}

//returns YES or NO if
+(BOOL)polygon:(MKPolygon *)poly1 intersectsPolygon:(MKPolygon *)poly2{
    
    
    
    return NO;
}

@end
