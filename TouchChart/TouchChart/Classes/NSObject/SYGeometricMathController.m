//
//  SYGeometricMathController.m
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 14/05/12.
//  Copyright (c) 2012 Sylion. All rights reserved.
//

#import "SYGeometricMathController.h"

@implementation SYGeometricMathController

// States
@synthesize isDeltaX;
@synthesize isDeltaY;

// Cartesian values
@synthesize maxX, maxY;
@synthesize minX, minY;

// Counters
@synthesize angleChangeCount;
@synthesize directionChangeCount;

// Array Data
@synthesize listPoints;
@synthesize listAngles;
@synthesize listVertex;



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
    self.listPoints = [[NSMutableArray alloc]init];
    self.listAngles = [[NSMutableArray alloc]init];
    
}// cleanData


- (void) addFirstPoint:(CGPoint) newPoint
{
    NSValue *point = [NSValue valueWithCGPoint:newPoint];
    [[self listPoints]addObject:point];
    
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
    if (![[[self listPoints]lastObject]isEqualToValue:pointAValue]) {
        [[self listPoints]addObject:pointAValue];
        
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
    if (![[[self listPoints]lastObject]isEqualToValue:pointBValue]) {
        [[self listPoints]addObject:pointBValue];
        
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
    if ([[self listPoints]count] > 5) {
        NSValue *vertexValue = [[self listPoints]objectAtIndex:[[self listPoints]count]-4];        
        CGFloat angle = [self getAngleBetweenVertex:pointA
                                          andPointA:pointB
                                          andPointB:[vertexValue CGPointValue]];
        CGFloat deltaXF = fabs(pointB.x - [vertexValue CGPointValue].x);
        CGFloat deltaYF = fabs(pointB.y - [vertexValue CGPointValue].y);
        
        if (deltaXF > deltaYF) {
            if (!isDeltaX)
                self.directionChangeCount++;
            isDeltaX = YES;
            isDeltaY = NO;
        }
        else {
            if (!isDeltaY)
                self.directionChangeCount++;
            isDeltaY = YES;
            isDeltaX = NO;
        }
        
        CGFloat angleC = (angle/M_PI) * 180;
        
        if (angleC < 130) {
            [self.listAngles addObject:[NSNumber numberWithFloat:angle]];
            [self.listVertex addObject:vertexValue];
            
            self.angleChangeCount++;
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
- (NSString *) getFigurePainted
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
        return @"Open Line";

    // Si es cerrado continua analizando el trazo
    else {                
        // Calcula el ratio total
        CGFloat ratioYmax = (maxY.x - minX.x) / (maxX.x - minX.x);
        CGFloat ratioYmin = (minY.x - minX.x) / (maxX.x - minX.x);
        
        CGFloat ratioXmax = (maxX.y - minY.y) / (maxY.y - minY.y);
        CGFloat ratioXmin = (minX.y - minY.y) / (maxY.y - minY.y);
        
        // Comprueba que se ha trazado bien
        if ((maxX.x - minX.x) == 0 || (maxY.y - minY.y) == 0 || self.directionChangeCount < 2)
            return @"Wrong figure";
        else {
            if (ratioYmax < 0.1 || ratioYmin < 0.1 || ratioXmax < 0.1 || ratioXmin < 0.1) {
                if (self.angleChangeCount > 7 || self.directionChangeCount > 5)
                    return @"Wrong figure";
                else
                    return [NSString stringWithFormat:@"1. Square. A:%i - D:%i", self.angleChangeCount, self.directionChangeCount];
            }
            else if (ratioYmax > 0.86 || ratioYmin > 0.86 || ratioXmax > 0.86 || ratioXmin > 0.86) {
                if (self.angleChangeCount > 7 || self.directionChangeCount > 5)
                    return @"Wrong figure";
                else
                    return [NSString stringWithFormat:@"2. Square. A:%i - D:%i", self.angleChangeCount, self.directionChangeCount];
            }
            else if (self.directionChangeCount > 8) {
                if (self.angleChangeCount > 5 || self.directionChangeCount > 10)
                    return @"Wrong figure";
                else
                    return [NSString stringWithFormat:@"1. Diamond. A:%i - D:%i", self.angleChangeCount, self.directionChangeCount];
            }
            else if (self.angleChangeCount == 0)
                return [NSString stringWithFormat:@"1. Circle. A:%i - D:%i", self.angleChangeCount, self.directionChangeCount];
            else if (self.directionChangeCount > 4)
                return [NSString stringWithFormat:@"2. Diamond. A:%i - D:%i", self.angleChangeCount, self.directionChangeCount];
            else if (self.angleChangeCount < 3)
                return [NSString stringWithFormat:@"3. Circle. A:%i - D:%i", self.angleChangeCount, self.directionChangeCount];
        }
    }
    
    return @"Unknow figure";
    
}// getFigurePainted

@end
