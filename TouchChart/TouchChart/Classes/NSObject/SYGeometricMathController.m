//
//  SYGeometricMathController.m
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 14/05/12.
//  Copyright (c) 2012 Sylion. All rights reserved.
//

#import "SYGeometricMathController.h"
#import "SYGeometry.h"
#import "SYVectorView.h"

@implementation SYGeometricMathController

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
    
    // Calculate angle
    if ([listPoints count] > 5) {
        NSValue *vertexValue = [listPoints objectAtIndex:[listPoints count]-4];        
        CGFloat angle = [self getAngleBetweenVertex:pointA
                                          andPointA:pointB
                                          andPointB:[vertexValue CGPointValue]];
        CGFloat deltaXF = fabs(pointB.x - [vertexValue CGPointValue].x);
        CGFloat deltaYF = fabs(pointB.y - [vertexValue CGPointValue].y);
                
        if (deltaXF > deltaYF) {
            if (!isDeltaX)
                directionChangeCount++;
            isDeltaX = YES;
            isDeltaY = NO;
        }
        else {
            if (!isDeltaY)
                directionChangeCount++;
            isDeltaY = YES;
            isDeltaX = NO;
        }
                        
        if (angle < 2.44346) {
            [listAngles addObject:[NSNumber numberWithFloat:angle]];            
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
    
    return sqrt(dx*dx + dy*dy);
    
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


// Read lists and return the poligons best fit (or nil if the lists don't match)
- (void) getFigurePainted
{
    // Comprueba que el trazo es cerrado
    CGFloat maxDeltaX = maxX.x - minX.x;
    CGFloat maxDeltaY = maxY.y - minY.y;
    CGFloat deltaX = [[listPoints objectAtIndex:0]CGPointValue].x - [[listPoints lastObject]CGPointValue].x;
    CGFloat deltaY = [[listPoints objectAtIndex:0]CGPointValue].y - [[listPoints lastObject]CGPointValue].y;
    CGFloat ratioXClose = deltaX / maxDeltaX; 
    CGFloat ratioYClose = deltaY / maxDeltaY; 
    
    // Si es abierto, no hace nada
    if (fabs(ratioXClose) > 0.75 || fabs(ratioYClose) > 0.75)
        return;

    // Si es cerrado continua analizando el trazo
    else {
        // Calcula el ratio total
        CGFloat ratioYmax = (maxY.x - minX.x) / (maxX.x - minX.x);
        CGFloat ratioYmin = (minY.x - minX.x) / (maxX.x - minX.x);
        
        CGFloat ratioXmax = (maxX.y - minY.y) / (maxY.y - minY.y);
        CGFloat ratioXmin = (minX.y - minY.y) / (maxY.y - minY.y);
                
        // Comprueba que se ha trazado bien
        if ((maxX.x - minX.x) == 0 || (maxY.y - minY.y) == 0 || directionChangeCount < 2)
            return;
        else {
            if (ratioYmax < 0.1 || ratioYmin < 0.1 || ratioXmax < 0.1 || ratioXmin < 0.1) {
                if (angleChangeCount > 7 || directionChangeCount > 5)
                    return;
                else {
                    [self createSquare];
                    return;
                }
            }
            else if (ratioYmax > 0.86 || ratioYmin > 0.86 || ratioXmax > 0.86 || ratioXmin > 0.86) {
                if (angleChangeCount > 7 || directionChangeCount > 5)
                    return;
                else {
                    [self createSquare];
                    return;
                }
            }
            else if (directionChangeCount > 8) {
                if (angleChangeCount > 5 || directionChangeCount > 10)
                    return;
                else {
                    [self createDiamond];
                    return;
                }
            }
            else if (angleChangeCount == 0) {
                [self createCircle];
                return;
            }
            else if (directionChangeCount > 4) {
                [self createDiamond];
                return;
            }
            else if (angleChangeCount < 3) {
                [self createCircle];
                return;
            }
        }
    }
    
    return;
    
}// getFigurePainted



#pragma mark - Geometric calculations

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


-(void) dealloc
{
    [listPoints release];
    [listAngles release];
    
    [super dealloc];
    
}// dealloc

@end