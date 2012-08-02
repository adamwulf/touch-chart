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
#import "SYBezierController.h"

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
    
}// addPoint:andPoint:


- (void) addLastPoint:(CGPoint) lastPoint
{
    [[self pointKeyArray]addObject:[NSValue valueWithCGPoint:lastPoint]];
    
}// addLastPoint:


#pragma mark - Geometric calculations

// Return shape/curve contour longitude (aprox)
- (CGFloat) lengthFromPointList
{
    // If there isn't enough points, exit
    if ([listPoints count] < 2)
        return .0;
    
    CGFloat longitude = .0;
    for (int i = 1 ; i < [listPoints count] ; i++) {
        CGPoint startSegment = [[listPoints objectAtIndex:i-1]CGPointValue];
        CGPoint endSegment = [[listPoints objectAtIndex:i]CGPointValue];
        
        SYSegment *segment = [[SYSegment alloc]initWithPoint:startSegment andPoint:endSegment];
        longitude += [segment longitude];
        
    }
    
    return longitude;
    
}// lengthFromPointList


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



#pragma mark - Auxiliar calculations

- (NSUInteger) getFactorial:(NSUInteger) intNumber
{
    NSUInteger result = 1;
    
    for (NSUInteger i = 0; i < intNumber ; i++)
        result = result * (intNumber-i);
    
    return result;
    
}// getFactorial:


#pragma mark - Calculate Shapes

- (void) getBezierPathPainted
{
    //TEMPORAL
    vectorView.shapeList = [[NSMutableArray alloc]init];
    
    // Get radius to reduce point cloud
    CGFloat maxDeltaX = maxX.x - minX.x;
    CGFloat maxDeltaY = maxY.y - minY.y;/*
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
    // -------------------------------------------------
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
            NSValue *newPoint = [NSValue valueWithCGPoint:CGPointMake(newCGPoint.x, newCGPoint.y)];
            [finalArray addObject:newPoint];
        }
    }
    self.pointKeyArray = finalArray;
    */
    
    // Is the painted shape closed (almost closed)?
    // --------------------------------------------------------------------------
    SYSegment *near = [[SYSegment alloc]initWithPoint:[[listPoints objectAtIndex:0]CGPointValue]
                                             andPoint:[[listPoints lastObject]CGPointValue]];
    CGFloat ratioClose = [near longitude]/((maxDeltaX + maxDeltaY)*0.5);
    NSLog(@"%f", ratioClose);
    // It's open, do nothing, exit
    if (fabs(ratioClose) > 0.40) {
        
        SYBezierController *bezierController = [[SYBezierController alloc]init];
        //NSArray *curves = [bezierController getCubicBezierPointsForListPoint:listPoints splitIn:8 andConvertFromView:vectorView];
        NSArray *curves = [bezierController getBestCurveForListPoint:listPoints tolerance:2 andConvertFromView:vectorView];
        [bezierController release];
        
        [self createBezierCurveWithPoints:curves];
        
        return;
    }
    else {
        // Get oval axis
        CGFloat axisDistance = .0;
        SYSegment *bigAxisSegment = nil; 
        for (NSValue *pointValue in listPoints) {
            
            CGPoint pointA = [pointValue CGPointValue];
            
            for (int i = 0 ; i < [listPoints count] ; i++) {
                CGPoint pointB = [[listPoints objectAtIndex:i]CGPointValue];
                SYSegment *possibleAxis = [[SYSegment alloc]initWithPoint:pointA andPoint:pointB];
                if (axisDistance < [possibleAxis longitude]) {
                    [bigAxisSegment release];
                    bigAxisSegment = [possibleAxis retain];
                    axisDistance = [possibleAxis longitude];
                }
                [possibleAxis release];
            }
        }
        
        // If horizontal or vertical oval, we don't need rotate it
        float deltaAngle = fabs([bigAxisSegment angleDeg]) - 90.0;
        if (fabs([bigAxisSegment angleDeg]) < 10.0 || fabs(deltaAngle) < 10.0) {
            // Get the points Max, Min for create the CGRect
            minX = [[listPoints objectAtIndex:0]CGPointValue];
            maxX = [[listPoints objectAtIndex:0]CGPointValue];
            minY = [[listPoints objectAtIndex:0]CGPointValue];
            maxY = [[listPoints objectAtIndex:0]CGPointValue];
            for (NSValue *pointValue in listPoints) {
                CGPoint point = [pointValue CGPointValue];
                
                if (point.x > maxX.x)
                    maxX = point;
                if (point.y > maxY.y)
                    maxY = point;
                if (point.x < minX.x)
                    minX = point;
                if (point.y < minY.y)
                    minY = point;
            }
            [self createCircle];
            return;
        }
                
        // Looking for the small axis
        CGPoint center = [bigAxisSegment midPoint];
        SYSegment *smallAxisSegment = nil; CGFloat angleMax = 10000.0;
        
        for (NSValue *pointValue in listPoints) {
            CGPoint pointB = [pointValue CGPointValue];
            SYSegment *possibleAxis = [[SYSegment alloc]initWithPoint:center andPoint:pointB];
            
            // Busca aquel segmento que más se acerque a 90º
            // con respecto al eje mayor.            
            float deltaAngle = fabs([bigAxisSegment angleDeg] - [possibleAxis angleDeg]);
            float angle = fabs(deltaAngle - 90.0);

            if (angle < angleMax) {
                [smallAxisSegment release];
                smallAxisSegment = [possibleAxis retain];
                angleMax = angle;
            }
            [possibleAxis release];
        }
        

        // Maybe it's almost a circle
        float bigAxisLongitude = [bigAxisSegment longitude];
        float smallAxisLongitude = [smallAxisSegment longitude] * 2.0;
                
        if (smallAxisLongitude/bigAxisLongitude > 0.80) {
            
            // Get the points Max, Min for create the CGRect
            minX = [bigAxisSegment pointSt];
            maxX = [bigAxisSegment pointFn];
            minY = [[listPoints objectAtIndex:0]CGPointValue];
            maxY = [[listPoints objectAtIndex:0]CGPointValue];
            
            // Create arc 
            [self createArc:CGPointMake(center.x, vectorView.bounds.size.height - center.y)
                     radius:bigAxisLongitude*0.5
                 startAngle:.0
                   endAngle:360.0
                  clockwise:YES];
            return;
        }
        
        // Get max and min XY
        float angleRad = M_PI_2 - [bigAxisSegment angleRad];
        [bigAxisSegment setMiddlePointToDegree:90.0];
        minY = [bigAxisSegment pointSt];
        maxY = [bigAxisSegment pointFn];
        minX = CGPointMake([bigAxisSegment midPoint].x - smallAxisLongitude * 0.5, [bigAxisSegment midPoint].y);
        maxX = CGPointMake([bigAxisSegment midPoint].x + smallAxisLongitude * 0.5, [bigAxisSegment midPoint].y);
        
        // Transform, rotate a around the midpoint
        CGPoint pivotalPoint = CGPointMake([bigAxisSegment midPoint].x, vectorView.bounds.size.height - [bigAxisSegment midPoint].y);
        CGAffineTransform transform = CGAffineTransformMakeTranslation(pivotalPoint.x, pivotalPoint.y);
        transform = CGAffineTransformRotate(transform, angleRad);
        transform = CGAffineTransformTranslate(transform, - pivotalPoint.x, - pivotalPoint.y);
        [self createCircleWithTransform:transform];
        
        [bigAxisSegment release];
        [smallAxisSegment release];
        
        return;
    }  
    
}// getBezierPathPainted


// Read lists and return the poligons best fit (or nil if the lists don't match)
- (void) getFigurePainted
{
    [self getBezierPathPainted];
    return;
    
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
    [finalArray removeLastObject];
    
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
        
        if (isBreak)
            break;        
    }
    
    // Get the final key points
    self.pointKeyArray  = [[NSMutableArray alloc]init];
    SYSegment *segment = [segmentsArray objectAtIndex:0];
    [self.pointKeyArray addObject:[NSValue valueWithCGPoint:[segment pointSt]]];
    
    for (SYSegment *segment in segmentsArray) {
        [self.pointKeyArray addObject:[NSValue valueWithCGPoint:[segment pointFn]]];
        //NSLog(@"%f", [segment angleDeg]);
    }
    
    [self createPolygonal];
 
}// getFigurePainted


#pragma mark - Create Geometric Methods

- (void) createBezierCurveWithPoints:(NSArray *) arrayData
{
    // Draw the resulting shape
    SYGeometry *geometry = [[SYGeometry alloc]init];
    
    // Geometry parameters
    geometry.geometryType = BezierType;
    geometry.pointArray = [NSArray arrayWithArray:arrayData];
    
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor clearColor];
    geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    [[vectorView shapeList]addObject:geometry];
    [vectorView setNeedsDisplay];
    
    [geometry release];
    
}// createBezierCurveWithPoints


- (void) createPolygonal
{
    // Draw the resulting shape
    SYGeometry *geometry = [[SYGeometry alloc]init];
    
    // Geometry parameters
    geometry.geometryType = LinesType;
    
    // Origin XY conversion
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
    
    return;
    
}// createPolygonal


- (void) createPolygonalFromSegment:(SYSegment *) segment
{
    // Draw the resulting shape
    SYGeometry *geometry = [[SYGeometry alloc]init];
    
    // Geometry parameters
    geometry.geometryType = LinesType;
    geometry.pointArray = [[NSArray alloc]initWithObjects:[NSValue valueWithCGPoint:CGPointMake([segment pointSt].x, vectorView.bounds.size.height - [segment pointSt].y)],
                                                          [NSValue valueWithCGPoint:CGPointMake([segment pointFn].x, vectorView.bounds.size.height - [segment pointFn].y)], nil];
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor clearColor];
    geometry.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    [[vectorView shapeList]addObject:geometry];
    [vectorView setNeedsDisplay];
    
    [geometry release];
    
    return;
    
}// createPolygonalFromSegment


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
    
    //vectorView.shapeList = [[NSMutableArray alloc]initWithObjects:geometry, nil];
    [[vectorView shapeList]addObject:geometry];
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
    
    //vectorView.shapeList = [[NSMutableArray alloc]initWithObjects:geometry, nil];
    [[vectorView shapeList]addObject:geometry];
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
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor clearColor];
    geometry.strokeColor = [UIColor redColor];//[UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    //vectorView.shapeList = [[NSMutableArray alloc]initWithObjects:geometry, nil];
    [[vectorView shapeList]addObject:geometry];
    [vectorView setNeedsDisplay];
    
    [geometry release];
    
    return;
    
}// createCircle


- (void) createPoint:(CGPoint) point
{
    SYGeometry *geometry = [[SYGeometry alloc]init];
    
    // Geometry parameters
    geometry.geometryType = CircleType;
    geometry.rectGeometry = CGRectMake( point.x - 2.5, vectorView.bounds.size.height - point.y - 2.5, 5.0, 5.0);
    
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor clearColor];
    geometry.strokeColor = [UIColor redColor];//[UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    //vectorView.shapeList = [[NSMutableArray alloc]initWithObjects:geometry, nil];
    [[vectorView shapeList]addObject:geometry];
    [vectorView setNeedsDisplay];
    
    [geometry release];
    
    return;
    
}// createPoint:


- (void) createCircleWithTransform:(CGAffineTransform) transform
{
    SYGeometry *geometry = [[SYGeometry alloc]init];
    
    // Geometry parameters
    geometry.geometryType = CircleType;
    geometry.rectGeometry = CGRectMake( minX.x, vectorView.bounds.size.height - maxY.y, (maxX.x - minX.x), (maxY.y - minY.y));
    
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor clearColor];
    geometry.strokeColor = [UIColor redColor];//[UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    geometry.transform = transform;
    
    //vectorView.shapeList = [[NSMutableArray alloc]initWithObjects:geometry, nil];
    [[vectorView shapeList]addObject:geometry];
    [vectorView setNeedsDisplay];
    
    [geometry release];
    
    return;
    
}// createCircleWithTransform


- (void) createArc:(CGPoint) midPoint radius:(NSUInteger) radius startAngle:(CGFloat) startAngle endAngle:(CGFloat) endAngle clockwise:(BOOL) clockwise
{
    SYGeometry *geometry = [[SYGeometry alloc]init];
    
    // Geometry parameters
    geometry.geometryType = ArcType;
    [geometry setArcParametersWithMidPoint:midPoint
                                    radius:radius
                                startAngle:startAngle
                                  endAngle:endAngle
                              andClockWise:clockwise];
    
    // Draw properties
    geometry.lineWidth = 4.0;
    geometry.fillColor = [UIColor clearColor];
    geometry.strokeColor = [UIColor redColor];//[UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
    
    //vectorView.shapeList = [[NSMutableArray alloc]initWithObjects:geometry, nil];
    [[vectorView shapeList]addObject:geometry];
    [vectorView setNeedsDisplay];
    
    [geometry release];
    
}// createArc:endAngle:


- (void) createTriangle
{    
    
}// createTriangle


-(void) dealloc
{
    [listPoints release];
    [listAngles release];
    
    [super dealloc];
    
}// dealloc

/*
#pragma mark - Temp Bezier

- (float) findDistance:(CGPoint)point lineA:(CGPoint)lineA lineB:(CGPoint)lineB
{
    CGPoint v1 = CGPointMake(lineB.x - lineA.x, lineB.y - lineA.y);
    CGPoint v2 = CGPointMake(point.x - lineA.x, point.y - lineA.y);
    float lenV1 = sqrt(v1.x * v1.x + v1.y * v1.y);
    float lenV2 = sqrt(v2.x * v2.x + v2.y * v2.y);
    float angle = acos((v1.x * v2.x + v1.y * v2.y) / (lenV1 * lenV2));
    return sin(angle) * lenV2;
}


- (NSArray *) douglasPeucker:(NSArray *)points epsilon:(float)epsilon
{
    int count = [points count];
    if(count < 3) {
        return points;
    }
    
    //Find the point with the maximum distance
    float dmax = 0;
    int index = 0;
    for(int i = 1; i < count - 1; i++) {
        CGPoint point = [[points objectAtIndex:i] CGPointValue];
        CGPoint lineA = [[points objectAtIndex:0] CGPointValue];
        CGPoint lineB = [[points objectAtIndex:count - 1] CGPointValue];
        float d = [self findDistance:point lineA:lineA lineB:lineB];
        if(d > dmax) {
            index = i;
            dmax = d;
        }
    }
    
    // If max distance is greater than epsilon, recursively simplify
    NSArray *resultList;
    if(dmax > epsilon) {
        NSArray *recResults1 = [self douglasPeucker:[points subarrayWithRange:NSMakeRange(0, index + 1)] epsilon:epsilon];
        
        NSArray *recResults2 = [self douglasPeucker:[points subarrayWithRange:NSMakeRange(index, count - index)] epsilon:epsilon];
        
        NSMutableArray *tmpList = [NSMutableArray arrayWithArray:recResults1];
        [tmpList removeLastObject];
        [tmpList addObjectsFromArray:recResults2];
        resultList = tmpList;
    }
    else
        resultList = [NSArray arrayWithObjects:[points objectAtIndex:0], [points objectAtIndex:count - 1],nil];
    
    return resultList;
}

- (NSArray *)catmullRomSplineAlgorithmOnPoints:(NSArray *)points segments:(int)segments
{
    int count = [points count];
    if(count < 4) {
        return points;
    }
    
    float b[segments][4];
    {
        // precompute interpolation parameters
        float t = 0.0f;
        float dt = 1.0f/(float)segments;
        for (int i = 0; i < segments; i++, t+=dt) {
            float tt = t*t;
            float ttt = tt * t;
            b[i][0] = 0.5f * (-ttt + 2.0f*tt - t);
            b[i][1] = 0.5f * (3.0f*ttt -5.0f*tt +2.0f);
            b[i][2] = 0.5f * (-3.0f*ttt + 4.0f*tt + t);
            b[i][3] = 0.5f * (ttt - tt);
        }
    }
    
    NSMutableArray *resultArray = [NSMutableArray array];
    
    {
        int i = 0; // first control point
        [resultArray addObject:[points objectAtIndex:0]];
        for (int j = 1; j < segments; j++) {
            CGPoint pointI = [[points objectAtIndex:i] CGPointValue];
            CGPoint pointIp1 = [[points objectAtIndex:(i + 1)] CGPointValue];
            CGPoint pointIp2 = [[points objectAtIndex:(i + 2)] CGPointValue];
            float px = (b[j][0]+b[j][1])*pointI.x + b[j][2]*pointIp1.x + b[j][3]*pointIp2.x;
            float py = (b[j][0]+b[j][1])*pointI.y + b[j][2]*pointIp1.y + b[j][3]*pointIp2.y;
            [resultArray addObject:[NSValue valueWithCGPoint:CGPointMake(px, py)]];
        }
    }
    
    for (int i = 1; i < count-2; i++) {
        // the first interpolated point is always the original control point
        [resultArray addObject:[points objectAtIndex:i]];
        for (int j = 1; j < segments; j++) {
            CGPoint pointIm1 = [[points objectAtIndex:(i - 1)] CGPointValue];
            CGPoint pointI = [[points objectAtIndex:i] CGPointValue];
            CGPoint pointIp1 = [[points objectAtIndex:(i + 1)] CGPointValue];
            CGPoint pointIp2 = [[points objectAtIndex:(i + 2)] CGPointValue];
            float px = b[j][0]*pointIm1.x + b[j][1]*pointI.x + b[j][2]*pointIp1.x + b[j][3]*pointIp2.x;
            float py = b[j][0]*pointIm1.y + b[j][1]*pointI.y + b[j][2]*pointIp1.y + b[j][3]*pointIp2.y;
            [resultArray addObject:[NSValue valueWithCGPoint:CGPointMake(px, py)]];
        }
    }
    
    {
        int i = count-2; // second to last control point
        [resultArray addObject:[points objectAtIndex:i]];
        for (int j = 1; j < segments; j++) {
            CGPoint pointIm1 = [[points objectAtIndex:(i - 1)] CGPointValue];
            CGPoint pointI = [[points objectAtIndex:i] CGPointValue];
            CGPoint pointIp1 = [[points objectAtIndex:(i + 1)] CGPointValue];
            float px = b[j][0]*pointIm1.x + b[j][1]*pointI.x + (b[j][2]+b[j][3])*pointIp1.x;
            float py = b[j][0]*pointIm1.y + b[j][1]*pointI.y + (b[j][2]+b[j][3])*pointIp1.y;
            [resultArray addObject:[NSValue valueWithCGPoint:CGPointMake(px, py)]];
        }
    }
    // the very last interpolated point is the last control point
    [resultArray addObject:[points objectAtIndex:(count - 1)]]; 
    
    return resultArray;
}
*/
@end