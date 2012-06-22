//
//  SYGeometricMathController.m
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 14/05/12.
//  Copyright (c) 2012 Sylion. All rights reserved.
//

#import "SYGeometricMathController.h"
#import "SYGeometry.h"
#import "SYSegment.h"
#import "SYVectorView.h"

@implementation SYGeometricMathController

@synthesize pointKeyArray;

#define limitDistace 2.99

#pragma mark - Management Operations

// Clean Data
- (void) cleanData
{
    // Init all the data and set ready them
    isDeltaX = NO; isDeltaY = NO;
    angleChangeCount = 0;
    directionChangeCount = 0;
    maxX = CGPointZero;
    maxY = CGPointZero;
    minX = CGPointZero;
    minY = CGPointZero;
    
    // Create new point list
    [listPoints release];
    [listAngles release];
    listPoints = [[NSMutableArray alloc]init];
    listAngles = [[NSMutableArray alloc]init];
    
}// cleanData


- (void) addFirstPoint:(CGPoint) newPoint
{
    NSValue *point = [NSValue valueWithCGPoint:newPoint];
    [listPoints addObject:point];
    
    maxX = newPoint;
    maxY = newPoint;
    minX = newPoint;
    minY = newPoint;
    
    isDeltaXPos = 0;
    isDeltaYPos = 0;
    
    self.pointKeyArray = [[NSMutableArray alloc]init];
    
    // PRIMER PUNTO
    [[self pointKeyArray]addObject:[NSValue valueWithCGPoint:newPoint]];
    
}// addFirstPoint:


- (void) addPoint:(CGPoint) pointA andPoint:(CGPoint) pointB;
{
    // Add points
    NSValue *pointAValue = [NSValue valueWithCGPoint:pointA];
    NSValue *pointBValue = [NSValue valueWithCGPoint:pointB];
    if (![[listPoints lastObject]isEqualToValue:pointAValue]) {
        [listPoints addObject:pointAValue];
        
        // Get Max/Min
        if (pointA.x > maxX.x)
            maxX = pointA;
        if (pointA.x < minX.x)
            minX = pointA;
        if (pointA.y > maxY.y)
            maxY = pointA;
        if (pointA.y < minY.y)
            minY = pointA;
        
    }
    if (![[listPoints lastObject]isEqualToValue:pointBValue]) {
        [listPoints addObject:pointBValue];
        
        // Get Max/Min
        if (pointB.x > maxX.x)
            maxX = pointB;
        if (pointB.x < minX.x)
            minX = pointB;
        if (pointB.y > maxY.y)
            maxY = pointB;
        if (pointB.y < minY.y)
            minY = pointB;
    }
    
    // Calculate keyPoints
    if ([listPoints count] > 3) {
        CGFloat deltaXF = pointB.x - pointA.x;
        CGFloat deltaYF = pointB.y - pointA.y;
                
        // VARIACION SEGUN DELTAX POR RATIOS
        if (previousDeltaX != 0 && fabs(deltaXF/previousDeltaX) > limitDistace)
            [[self pointKeyArray]addObject:[NSValue valueWithCGPoint:pointA]];
        else if (previousDeltaY != 0 && fabs(deltaYF/previousDeltaY) > limitDistace)
            [[self pointKeyArray]addObject:[NSValue valueWithCGPoint:pointA]];
        
        if (deltaXF != 0)
            previousDeltaX = deltaXF;
        if (deltaYF != 0)
            previousDeltaY = deltaYF;
        
        
        // VARIACION X SEGUN CAMBIOS DE DIRECCION
        if (isDeltaXPos == 0) {
            if (deltaXF > limitDistace) {
                isDeltaXPos = 1;
                return;
            }
            else if (deltaXF < -limitDistace) {
                isDeltaXPos = -1;
                return;
            }
            
            if (deltaXF > limitDistace) {
                isDeltaXPos = 1;
                return;
            }
            else if (deltaXF < -limitDistace) {
                isDeltaXPos = -1;
                return;
            }
        }
        else {
            if (deltaXF > limitDistace && isDeltaXPos == -1) {
                [[self pointKeyArray]addObject:[NSValue valueWithCGPoint:pointA]];
                isDeltaXPos = 1;
                return;
            }
            else if (deltaXF < -limitDistace && isDeltaXPos == 1) {
                [[self pointKeyArray]addObject:[NSValue valueWithCGPoint:pointA]];
                isDeltaXPos = -1;
                return;
            }
            
            if (deltaXF > limitDistace && isDeltaXPos == -1) {
                [[self pointKeyArray]addObject:[NSValue valueWithCGPoint:pointA]];
                isDeltaXPos = 1;
                return;
            }
            else if (deltaXF < -limitDistace && isDeltaXPos == 1) {
                [[self pointKeyArray]addObject:[NSValue valueWithCGPoint:pointA]];
                isDeltaXPos = -1;
                return;
            }            
        }
        
        // Variacion Y
        if (isDeltaYPos == 0) {
            if (deltaYF > limitDistace) {
                isDeltaYPos = 1;
                return;
            }
            else if (deltaYF < -limitDistace) {
                isDeltaYPos = -1;
                return;
            }
            
            if (deltaYF > limitDistace) {
                isDeltaYPos = 1;
                return;
            }
            else if (deltaYF < -limitDistace) {
                isDeltaYPos = -1;
                return;
            }
        }
        else {
            if (deltaYF > limitDistace && isDeltaYPos == -1) {
                [[self pointKeyArray]addObject:[NSValue valueWithCGPoint:pointA]];
                isDeltaYPos = 1;
                return;
            }
            else if (deltaYF < -limitDistace && isDeltaYPos == 1) {
                [[self pointKeyArray]addObject:[NSValue valueWithCGPoint:pointA]];
                isDeltaYPos = -1;
                return;
            }
            
            if (deltaYF > limitDistace && isDeltaYPos == -1) {
                [[self pointKeyArray]addObject:[NSValue valueWithCGPoint:pointA]];
                isDeltaYPos = 1;
                return;
            }
            else if (deltaYF < -limitDistace && isDeltaYPos == 1) {
                [[self pointKeyArray]addObject:[NSValue valueWithCGPoint:pointA]];
                isDeltaYPos = -1;
                return;
            }            
        }
        
        // ANGLES
        NSValue *vertexValue = [listPoints objectAtIndex:[listPoints count]-4];        
        CGFloat angle = [self getAngleBetweenVertex:pointA
                                          andPointA:pointB
                                          andPointB:[vertexValue CGPointValue]];
        
        CGFloat angleDeg = (angle / M_PI_2) * 90.0;
        if (angleDeg < 170.0) {
            [[self pointKeyArray]addObject:[NSValue valueWithCGPoint:[vertexValue CGPointValue]]];
            angleChangeCount++;
        }
    }
    
}// addNewPoint


#pragma mark - Geometric calculations

// Rewrite your TCChartView method ObjC native
- (CGFloat) distanceBetweenPoint:(CGPoint) point1 andPoint:(CGPoint) point2
{
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    
    return sqrt(pow(dx,2) + pow(dy,2));
    
}// distanceBetweenPoint:andPoint:


// Rewrite your TCChartView method ObjC native
- (CGFloat) getAngleBetweenVertex:(CGPoint) vertex andPointA:(CGPoint) pointA andPointB:(CGPoint) pointB
{
    // cos-1((P122 + P132 - P232)/(2 * P12 * P13))
    
    CGFloat P12 = [self distanceBetweenPoint:vertex andPoint:pointA];
    CGFloat P13 = [self distanceBetweenPoint:vertex andPoint:pointB];
    CGFloat P23 = [self distanceBetweenPoint:pointA andPoint:pointB];
    
    CGFloat num = P12 * P12 + P13 * P13 - P23 * P23;
    CGFloat den = 2 * P12 * P13;
    CGFloat total = num / den;
    CGFloat ret = acosf(total);
    
    return ret;
    
}// getAngleBetween


- (CGPoint) midPointBetweenPoint:(CGPoint) pointA andPoint:(CGPoint) pointB
{
    CGFloat xPoint = (pointA.x + pointB.x) / 2;
    CGFloat yPoint = (pointA.y + pointB.y) / 2;
    CGPoint result = CGPointMake(xPoint, yPoint);
    
    return result;
    
}// midPointBetween:andPoint:


- (CGFloat) distanceFrom:(CGPoint) pointTest toLineBuildForPoint:(CGPoint) pointKey andPoint:(CGPoint) pointNextKey
{
    // Calcula pendiente
    CGFloat m = (pointNextKey.y - pointKey.y) / (pointNextKey.x - pointKey.x);
    
    // Calcula termino d
    CGFloat d = pointKey.y - (m * pointKey.x);
    
    // Se calcula distancia
    CGFloat dist = fabsf(pointTest.y - ((m * pointTest.x) + d)) / sqrtf(powf(m, 2) + 1);

    return dist;
    
}// distanceFrom:toLineBuildForPoint:andPoint:


- (BOOL) point:(CGPoint)pointA andPoint:(CGPoint)pointB isAlignedWithPoint:(CGPoint)pointC
{
    // Ecuacion de la recta y = mx + d
    // -------------------------------
    // Se calcula distancia
    float dist = [self distanceFrom:pointC toLineBuildForPoint:pointA andPoint:pointB];
    
    // Si esta alineado responde si
    if (dist == 0)
        return YES;
    
    // Si no NO
    return NO;
    
}// point:andPoint:isAlignedWithPoint:


- (BOOL) point:(CGPoint)pointA andPoint:(CGPoint)pointC isAlignedWithPoint:(CGPoint)pointB withDistance:(float) ratio
{
    // Ecuacion de la recta y = mx + d
    // -------------------------------
    // Se calcula distancia
    float dist = [self distanceFrom:pointC toLineBuildForPoint:pointA andPoint:pointB];
    
    // Si esta alineado responde si
    if (dist < ratio)
        return YES;
    
    // Si no NO
    return NO;
    
}// point:andPoint:isAlignedWithPoint:



#pragma mark - Geometric calculations

// Read lists and return the poligons best fit (or nil if the lists don't match)
- (void) getFigurePainted
{
    //TEMPORAL
    vectorView.shapeList = [[NSMutableArray alloc]init];
    
    // Get radius to reduce point cloud
    CGFloat maxDeltaX = maxX.x - minX.x;
    CGFloat maxDeltaY = maxY.y - minY.y;
    CGFloat radiusCloud = sqrtf(powf(maxDeltaX, 2) + powf(maxDeltaY, 2)) * 0.10;
    
    
    // Point cloud simplification algorithm (using radiusCloud)
    // --------------------------------------------------------------------------
    NSMutableArray *tempKeyPointsArray = [NSMutableArray arrayWithArray:[self pointKeyArray]];
    for (int i = 0 ; i < [tempKeyPointsArray count] ; i++) {
        // Pilla el primer punto
        id pointID = [tempKeyPointsArray objectAtIndex:i];
        
        if ((NSNull *) pointID != [NSNull null]) {
            CGPoint point = [[tempKeyPointsArray objectAtIndex:i]CGPointValue];
            
            // Compara con los siguientes hasta que no haya proximidad
            for (int j = i+1 ; j < [pointKeyArray count] ; j++) {
                CGPoint nextPoint = [[pointKeyArray objectAtIndex:j]CGPointValue];
                
                CGFloat distance = [self distanceBetweenPoint:point andPoint:nextPoint];
                if (distance < radiusCloud) {
                    [tempKeyPointsArray replaceObjectAtIndex:i withObject:[NSValue valueWithCGPoint:point]];
                    [tempKeyPointsArray replaceObjectAtIndex:j withObject:[NSNull null]];
                }
            }
        }
    }
    
    
    // Clean all NSNull
    self.pointKeyArray = [[NSMutableArray alloc]init];
    for (id keyPoint in tempKeyPointsArray) {
        if ((NSNull *) keyPoint != [NSNull null])
            [pointKeyArray addObject:keyPoint];
    }
    
    
    // Remove points aligned (step A)
    // --------------------------------------------------------------------------
    NSMutableArray *edgePoints = [NSMutableArray array];
    if ([pointKeyArray count] > 0) {
        [edgePoints addObject:[pointKeyArray objectAtIndex:0]];
        
        for (int i = 0 ; i+2 < [pointKeyArray count] ; i++) {
            
            CGPoint pointKeyA = [[pointKeyArray objectAtIndex:i]CGPointValue];
            CGPoint pointKeyB = [[pointKeyArray objectAtIndex:i+1]CGPointValue];
            CGPoint pointKeyC = [[pointKeyArray objectAtIndex:i+2]CGPointValue];
            
            SYSegment *segment = [[SYSegment alloc]initWithPoint:pointKeyA andPoint:pointKeyC];
            CGFloat longitude = [segment longitude];
            
            if ([segment distanceToPoint:pointKeyB] < longitude * 0.12) {
                [pointKeyArray replaceObjectAtIndex:i+1 withObject:[NSNull null]];
                i = i+1;
            }
            
            [segment release];
        }
    }
    
    // Clean all NSNull
    NSMutableArray *finalArray = [NSMutableArray array];
    for (id keyPoint in pointKeyArray) {
        if ((NSNull *) keyPoint != [NSNull null]) {
            CGPoint newCGPoint = [keyPoint CGPointValue];
            NSValue *newPoint = [NSValue valueWithCGPoint:CGPointMake(newCGPoint.x, vectorView.bounds.size.height - newCGPoint.y)];
            [finalArray addObject:newPoint];
        }
    }
    
    
    // Is the painted shape closed (almost closed)?
    // --------------------------------------------------------------------------
    CGFloat deltaX = [[listPoints objectAtIndex:0]CGPointValue].x - [[listPoints lastObject]CGPointValue].x;
    CGFloat deltaY = [[listPoints objectAtIndex:0]CGPointValue].y - [[listPoints lastObject]CGPointValue].y;
    CGFloat ratioXClose = deltaX / maxDeltaX; 
    CGFloat ratioYClose = deltaY / maxDeltaY; 
    
    // It's open, do nothing, exit
    if (fabs(ratioXClose) > 0.25 || fabs(ratioYClose) > 0.25)
        return;
    
    // It's closed (almost closed), do closed perfectly
    CGPoint firstPoint = [[finalArray objectAtIndex:0]CGPointValue];
    CGPoint lastPoint = [[finalArray lastObject]CGPointValue];
    CGPoint midPoint = [self midPointBetweenPoint:firstPoint andPoint:lastPoint];
    [finalArray replaceObjectAtIndex:0 withObject:[NSValue valueWithCGPoint:midPoint]];
    [finalArray replaceObjectAtIndex:[finalArray count]-1 withObject:[NSValue valueWithCGPoint:midPoint]];
    
    // Clean all NSNull
    finalArray = [NSMutableArray array];
    for (id keyPoint in pointKeyArray) {
        if ((NSNull *) keyPoint != [NSNull null]) {
            CGPoint newCGPoint = [keyPoint CGPointValue];
            NSValue *newPoint = [NSValue valueWithCGPoint:CGPointMake(newCGPoint.x, newCGPoint.y)];
            [finalArray addObject:newPoint];
        }
    }
    
    // If the resulting points number is insufficient, exit
    self.pointKeyArray = [[NSMutableArray alloc]initWithArray:finalArray];
    if ([pointKeyArray count] < 2)
        return;
    
    
    // Remove points aligned (step B)
    // -----------------------------------------------------------------------
    NSMutableArray *pointAlign = [NSMutableArray arrayWithArray:pointKeyArray];
    for (int i = 0 ; i < [pointKeyArray count]; i++) {
        
        BOOL isBreak = NO;
        CGPoint pointA = [[pointAlign objectAtIndex:i]CGPointValue];
        CGPoint pointB = [[pointAlign objectAtIndex:i+1]CGPointValue];
        CGPoint pointC = CGPointZero;
        
        // Is it the last point?... take the first
        if (i+2 == [pointAlign count]) {
            pointC = [[pointAlign objectAtIndex:0]CGPointValue];
            isBreak = YES;
        }
        else
            pointC = [[pointAlign objectAtIndex:i+2]CGPointValue];
        
        CGFloat angleRad = fabsf([self getAngleBetweenVertex:pointB andPointA:pointA andPointB:pointC]);

        // Is it aligned
        if (angleRad > 2.4) { // casi 180º grados
            [pointAlign removeObjectAtIndex:i+1];
            i--;
            
            // If the resulting points number is insufficient, exit
            if ([pointAlign count] < 3)
                return;
        }
        
        if (isBreak)
            break;
    }
    
    // Clean all NSNull
    self.pointKeyArray = [[NSMutableArray alloc]init];
    for (id point in pointAlign) {
        if ((NSNull *) point != [NSNull null])
            [pointKeyArray addObject:point];
    }  
    
    
    // Snap Angles
    // ----------------------------------------------------------------
    // Build segment array
    NSMutableArray *segmentsArray  = [NSMutableArray array];
    for (int i = 0 ; i < [pointKeyArray count]; i++) {
        BOOL isBreak = NO;
        CGPoint pointA = [[pointKeyArray objectAtIndex:i]CGPointValue];
        CGPoint pointB = CGPointZero;
        
        // Is it the last point?... take the first
        if (i+1 == [pointKeyArray count]) {
            pointB = [[pointKeyArray objectAtIndex:0]CGPointValue];
            isBreak = YES;
        }
        else
            pointB = [[pointKeyArray objectAtIndex:i+1]CGPointValue];
        
        SYSegment *segment = [[SYSegment alloc]initWithPoint:pointA andPoint:pointB];
        [segmentsArray addObject:segment];
        
        if (isBreak)
            break;
    }
    
    // Snap all the segments
    for (SYSegment *segment in segmentsArray) {
        if ([segment isSnapAngle])
            [segment snapAngleChangingFinalPoint];
    }
    
    
    // Take the intersection between the segments (it will be key points)
    NSMutableArray *pointKeyArrayTemp = [NSMutableArray array];
    BOOL isSnap = YES;
    for (int i = 0 ; i < [segmentsArray count]; i++) {
        BOOL isBreak = NO;
        SYSegment *segmentA = [segmentsArray objectAtIndex:i];
        SYSegment *segmentB = nil;
        
        // Is it the last point?... take the first
        if (i+1 == [segmentsArray count]) {
            segmentB = [segmentsArray objectAtIndex:0];
            isBreak = YES;
        }
        else
            segmentB = [segmentsArray objectAtIndex:i+1];
             
        // Get the intersection point
        CGPoint intersectPoint = [segmentA pointIntersectWithSegment:segmentB];
                
        [segmentA setPointFn:intersectPoint];
        [segmentB setPointSt:intersectPoint];

        // the intersection point is into screen size
        if (fabs(intersectPoint.x) < 1024.0 && fabs(intersectPoint.y) < 745.0)
            [pointKeyArrayTemp addObject:[NSValue valueWithCGPoint:intersectPoint]];
        
        // the intersection point would be far away and don't snap shape
        else {
            isSnap = NO;
            break;
        }
        
        if (isBreak)
            break;        
    }
    
    // If the shape was snapped
    if (isSnap) {
        self.pointKeyArray  = [[NSMutableArray alloc]init];
        SYSegment *segment = [segmentsArray objectAtIndex:0];
        [self.pointKeyArray addObject:[NSValue valueWithCGPoint:[segment pointSt]]];
        
        for (SYSegment *segment in segmentsArray) {
            [self.pointKeyArray addObject:[NSValue valueWithCGPoint:[segment pointFn]]];
            //NSLog(@"%f", [segment angleDeg]);
        }
        
    }

    // Draw the resulting shape
    for (id point in pointKeyArray) {
        
        if ((NSNull *) point != [NSNull null]) {
            SYGeometry *geometry = [[SYGeometry alloc]init];
            
            // Geometry parameters
            geometry.geometryType = LinesType;
            
            NSMutableArray *finalArray = [NSMutableArray array];
            for (id keyPoint in pointKeyArray) {
                if ((NSNull *) keyPoint != [NSNull null]) {
                    CGPoint newCGPoint = [keyPoint CGPointValue];
                    NSValue *newPoint = [NSValue valueWithCGPoint:CGPointMake(newCGPoint.x, vectorView.bounds.size.height - newCGPoint.y)];
                    [finalArray addObject:newPoint];
                }
            }
            
            geometry.pointArray = [[NSArray alloc]initWithArray:finalArray];
            
            // Draw properties
            geometry.lineWidth = 4.0;
            geometry.fillColor = [UIColor clearColor];
            geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
            
            [[vectorView shapeList]addObject:geometry];
            [vectorView setNeedsDisplay];
            
            [geometry release];
        }
    }
    
    return;
    
}// getFigurePainted


- (void) createSquare
{
    SYGeometry *geometry = [[SYGeometry alloc]init];
    
    // Geometry parameters
    geometry.geometryType = SquareType;
    geometry.rectGeometry = CGRectMake( minX.x, vectorView.bounds.size.height - maxY.y, (maxX.x - minX.x), (maxY.y - minY.y));
    
    // Draw properties
    geometry.lineWidth = 2.0;
    geometry.fillColor = [UIColor whiteColor];
    geometry.strokeColor = [UIColor blackColor];
    
    vectorView.shapeList = [[NSMutableArray alloc]initWithObjects:geometry, nil];
    //  [[vectorView shapeList]addObject:geometry];
    [vectorView setNeedsDisplay];
    
    [geometry release];
    
    return;
    
}// createSquare


- (void) createDiamond
{
    SYGeometry *geometry = [[SYGeometry alloc]init];
    
    // Geometry parameters
    geometry.geometryType = DiamondType;
    geometry.rectGeometry = CGRectMake( minX.x, vectorView.bounds.size.height - maxY.y, (maxX.x - minX.x), (maxY.y - minY.y));
    
    // Draw properties
    geometry.lineWidth = 2.0;
    geometry.fillColor = [UIColor whiteColor];
    geometry.strokeColor = [UIColor blackColor];
    
    vectorView.shapeList = [[NSMutableArray alloc]initWithObjects:geometry, nil];
    //  [[vectorView shapeList]addObject:geometry];
    [vectorView setNeedsDisplay];
    
    [geometry release];
    
    return;
    
}// createDiamond


- (void) createCircle
{
    SYGeometry *geometry = [[SYGeometry alloc]init];
    
    // Geometry parameters
    geometry.geometryType = CircleType;
    geometry.rectGeometry = CGRectMake( minX.x, vectorView.bounds.size.height - maxY.y, (maxX.x - minX.x), (maxY.y - minY.y));
    
    // Draw properties
    geometry.lineWidth = 2.0;
    geometry.fillColor = [UIColor whiteColor];
    geometry.strokeColor = [UIColor blackColor];
    
    vectorView.shapeList = [[NSMutableArray alloc]initWithObjects:geometry, nil];
    //  [[vectorView shapeList]addObject:geometry];
    [vectorView setNeedsDisplay];
    
    [geometry release];
    
    return;
    
}// createCircle


- (void) createTriangle
{    
    
}// createTriangle


-(void) dealloc
{
    [listPoints release];
    [listAngles release];
    
    [super dealloc];
    
}// dealloc

@end