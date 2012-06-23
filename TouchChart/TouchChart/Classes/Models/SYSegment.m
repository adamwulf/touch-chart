//
//  SYSegment.m
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 01/06/12.
//  Copyright (c) 2012 Sylion. All rights reserved.
//

#import "SYSegment.h"

@implementation SYSegment 

#define zero 1e-8
#define inf 1e100
#define equal(a,b)  (fabs((a)-(b))<zero)

@synthesize pointSt;
@synthesize pointFn;

- (NSString *) description
{
    return [NSString stringWithFormat:@"StartPoint(%f, %f)     EndPoint(%f, %f)", pointSt.x, pointSt.y, pointFn.x, pointFn.y];
    
}// description


- (id) initWithPoint:(CGPoint) pointA andPoint:(CGPoint) pointB
{
    self = [super init];

    if (self) {

        self.pointSt = pointA;
        self.pointFn = pointB;

    }

    return self;

}// initWithPoint:andPoint:


- (void) dealloc
{
    [super dealloc];

}// dealloc


#pragma mark - Geometric Methods

- (CGFloat) moduleTwo:(CGPoint)puntoA and:(CGPoint)puntoB
{
    return (puntoB.x-puntoA.x)*(puntoB.x-puntoA.x) + (puntoB.y-puntoA.y)*(puntoB.y-puntoA.y);
    
}// moduleTwo:and:


// Distance between two points (2D)
- (CGFloat) distance:(CGPoint)puntoA and:(CGPoint)puntoB
{
    return sqrt([self moduleTwo:puntoA and:puntoB]);

}// distance:and:


// Vector longitude
- (CGFloat) longitude
{
    return sqrt([self moduleTwo:pointSt and:pointFn]);
    
}// longitude


// Distance between point C to segment
- (CGFloat) distanceToPoint:(CGPoint) C
{
    // Punto en el segmento sobre el cual se calculará la distancia
    // iniciamos en uno de los extremos
    CGPoint P = CGPointZero;
    
    // Para prevenir una división por cero se calcula primero el denominador de
    // la división. (Se puede dar si A y B son el mismo punto).
    CGFloat denominator = [self moduleTwo:pointSt and:pointFn];

    if(denominator !=0){

        // The u parameter indicate the position the P point in the segment
        CGFloat u = ((C.x - pointSt.x) * (pointFn.x - pointSt.x) + (C.y - pointSt.y) * (pointFn.y - pointSt.y))/denominator;

        // If u is between interval [0,1], the point P is into the segment
        if(u > 0.0 && u < 1.0) {
            P.x = pointSt.x + u * (pointFn.x - pointSt.x);
            P.y = pointSt.y + u * (pointFn.y - pointSt.y);
        }

        // else we use the final point for calculate distance.
        // If u < 0 we use start point, else if u >=1 we use final point
        else {
            if( u >= 1.0)
                P = pointFn;
            else
                P = pointSt;
        }
    }

    // return the distance between point C and point P
    return [self distance:P and:C];

}// distanceToPoint:


// Intersect point between the current segment and other
- (CGPoint) pointIntersectWithSegment:(SYSegment *) anotherSegment
{
    // Check if they have equal slope
    float fS1ope1 = (equal(self.pointSt.x, self.pointFn.x)) ? (inf) : ((self.pointFn.y - self.pointSt.y)/(self.pointFn.x - self.pointSt.x));
    float fS1ope2 = (equal(anotherSegment.pointSt.x, anotherSegment.pointFn.x)) ? (inf) : ((anotherSegment.pointFn.y - anotherSegment.pointSt.y)/(anotherSegment.pointFn.x - anotherSegment.pointSt.x));
    
    // If the both slope are equal, never intersect, they're parallels lines
    if (equal(fS1ope1, fS1ope2)) {
        if (equal(self.pointSt.y - fS1ope1 * self.pointSt.x,
                  anotherSegment.pointSt.y - fS1ope2 * anotherSegment.pointSt.x)) {
            NSLog(@"LINE\n");
        }
        else
            NSLog(@"NONE\n");
        
        CGPoint errorPoint = CGPointMake(10000, 10000);
        return errorPoint;
    }

    // else the lines intersect in a point, we calculate this point
    CGPoint ptIntersect = CGPointZero;
    ptIntersect.x = (fS1ope1 * self.pointSt.x - self.pointSt.y - fS1ope2 * anotherSegment.pointSt.x + anotherSegment.pointSt.y)/(fS1ope1 - fS1ope2);
    if (equal(self.pointSt.x, self.pointFn.x))
        ptIntersect.x = self.pointSt.x;
    if (equal(anotherSegment.pointSt.x, anotherSegment.pointFn.x))
        ptIntersect.x = anotherSegment.pointSt.x;
    
    ptIntersect.y = fS1ope1 * (ptIntersect.x - self.pointSt.x) + self.pointSt.y;
    if (equal(self.pointSt.x, self.pointFn.x))
        ptIntersect.y = fS1ope2 * (ptIntersect.x - anotherSegment.pointSt.x) + anotherSegment.pointSt.y;

    return ptIntersect;
    
}// pointIntersectWithSegment:


#pragma mark - Angles Methods

// Segment angle radian
- (CGFloat) angleRad
{
    CGFloat deltaX = pointFn.x - pointSt.x;
    CGFloat deltaY = pointFn.y - pointSt.y;
    
    if (deltaX == .0) {
        if (deltaY > .0)
            return M_PI_2;
        else if (deltaY < .0)
            return -M_PI_2;
    }

    
    if (deltaY == .0) {
        if (deltaX > .0)
            return .0;
        else if (deltaX < .0)
            return -M_PI;
    }
    
    return atanf(deltaY/deltaX);
    
}// angleRad


// Segment angle degrees
- (CGFloat) angleDeg
{
    CGFloat angle = [self angleRad];
    return (angle/M_PI) * 180.0;
    
}// angleDeg


// Snap pivotal around the start point
- (void) setStartPointToDegree:(CGFloat) angle
{
    CGFloat angleRad = (angle/90.0) * M_PI_2;
    
    // sen/cos = tan ----> sen = tan * cos
    if (fabs(angle) == .0 || fabs(angle) == 180.0)
        pointSt.y = pointFn.y;
    if (fabs(angle) == 90.0)
        pointSt.x = pointFn.x;
    else {
        // sen/cos = tan ----> sen = tan * cos
        CGFloat deltaY = (pointSt.x - pointFn.x) * tanf(angleRad);
        pointSt.y = deltaY + pointFn.y;
    }   
    
}// setStartPointToDegree:


// Snap pivotal around the middle point
- (void) setMiddlePointToDegree:(CGFloat) angle
{
    CGFloat angleRad = (angle/90.0) * M_PI_2;
    
    // sen/cos = tan ----> sen = tan * cos
    if (fabs(angle) == .0 || fabs(angle) == 180.0) {
        CGFloat midY = (pointFn.y + pointSt.y) * 0.5;
        pointSt.y = midY;
        pointFn.y = midY;
    }
    if (fabs(angle) == 90.0) {
        CGFloat midX = (pointFn.x + pointSt.x) * 0.5;
        pointSt.x = midX;
        pointFn.x = midX;
    }
    else {
        CGFloat deltaY = (pointFn.x - pointSt.x) * tanf(angleRad);
        pointSt.y = pointSt.y + (deltaY * 0.5);
        pointFn.y = pointFn.y - (deltaY * 0.5);
    }
    
}// setMiddlePointToDegree


// Snap pivotal around the final point
- (void) setFinalPointToDegree:(CGFloat) angle
{
    CGFloat angleRad = (angle/90.0) * M_PI_2;
    
    // sen/cos = tan ----> sen = tan * cos
    if (fabs(angle) == .0 || fabs(angle) == 180.0)
        pointFn.y = pointSt.y;
    if (fabs(angle) == 90.0)
        pointFn.x = pointSt.x;
    else {
        CGFloat deltaY = (pointFn.x - pointSt.x) * tan(angleRad);
        pointFn.y = pointSt.y + deltaY;
    }
    
}// setFinalPointToDegree:


// Check angle to snap
- (void) snapAngleChangingStartPoint
{
    // Si es distinto de .0 o 90.0, y ajusta al punto B
    CGFloat angleDeg = [self angleDeg];
    if ([self isSnapAngle]) {
        if (angleDeg > .0) {
            if (angleDeg < 15.0)
                [self setStartPointToDegree:.0];
            else if (angleDeg < 37.5)
                [self setStartPointToDegree:30.0];
            else if (angleDeg < 52.5)
                [self setStartPointToDegree:45.0];
            else if (angleDeg < 75.0)
                [self setStartPointToDegree:60.0];
            else if (angleDeg < 90.0 + 15.0)
                [self setStartPointToDegree:90.0];
            else if (angleDeg < 90.0 + 37.5)
                [self setStartPointToDegree:90.0 + 30.0];
            else if (angleDeg < 90.0 + 52.5)
                [self setStartPointToDegree:90.0 + 45.0];
            else if (angleDeg < 90.0 + 75.0)
                [self setStartPointToDegree:90.0 + 60.0];
            else
                [self setStartPointToDegree:180.0];
        }
        else {
            if (angleDeg > -15.0)
                [self setStartPointToDegree:.0];
            else if (angleDeg > -37.5)
                [self setStartPointToDegree:-30.0];
            else if (angleDeg > -52.5)
                [self setStartPointToDegree:-45.0];
            else if (angleDeg > -75.0)
                [self setStartPointToDegree:-60.0];
            else if (angleDeg > -90.0 - 15.0)
                [self setStartPointToDegree:-90.0];
            else if (angleDeg > -90.0 - 37.5)
                [self setStartPointToDegree:-90.0 - 30.0];
            else if (angleDeg > -90.0 - 52.5)
                [self setStartPointToDegree:-90.0 - 45.0];
            else if (angleDeg > -90.0 - 75.0)
                [self setStartPointToDegree:-90.0 - 60.0];
            else
                [self setStartPointToDegree:-180.0];
        }
    }
    
}// snapAngleChangingStartPoint


// Check angle to snap
- (void) snapAngleChangingFromMiddlePoint
{
    // Si es distinto de .0 o 90.0, y ajusta al punto B
    CGFloat angleDeg = [self angleDeg];
    if ([self isSnapAngle]) {
        if (angleDeg > .0) {
            if (angleDeg < 15.0)
                [self setMiddlePointToDegree:.0];
            else if (angleDeg < 37.5)
                [self setMiddlePointToDegree:30.0];
            else if (angleDeg < 52.5)
                [self setMiddlePointToDegree:45.0];
            else if (angleDeg < 75.0)
                [self setMiddlePointToDegree:60.0];
            else if (angleDeg < 90.0 + 15.0)
                [self setMiddlePointToDegree:90.0];
            else if (angleDeg < 90.0 + 37.5)
                [self setMiddlePointToDegree:90.0 + 30.0];
            else if (angleDeg < 90.0 + 52.5)
                [self setMiddlePointToDegree:90.0 + 45.0];
            else if (angleDeg < 90.0 + 75.0)
                [self setMiddlePointToDegree:90.0 + 60.0];
            else
                [self setMiddlePointToDegree:180.0];
        }
        else {
            if (angleDeg > -15.0)
                [self setMiddlePointToDegree:.0];
            else if (angleDeg > -37.5)
                [self setMiddlePointToDegree:-30.0];
            else if (angleDeg > -52.5)
                [self setMiddlePointToDegree:-45.0];
            else if (angleDeg > -75.0)
                [self setMiddlePointToDegree:-60.0];
            else if (angleDeg > -90.0 - 15.0)
                [self setMiddlePointToDegree:-90.0];
            else if (angleDeg > -90.0 - 37.5)
                [self setMiddlePointToDegree:-90.0 - 30.0];
            else if (angleDeg > -90.0 - 52.5)
                [self setMiddlePointToDegree:-90.0 - 45.0];
            else if (angleDeg > -90.0 - 75.0)
                [self setMiddlePointToDegree:-90.0 - 60.0];
            else
                [self setMiddlePointToDegree:-180.0];
        }
    }
    
}// snapAngleChangingFromMiddlePoint


// Check angle to snap
- (void) snapAngleChangingFinalPoint
{
    // Si es distinto de .0 o 90.0, y ajusta al punto B
    CGFloat angleDeg = [self angleDeg];
    if ([self isSnapAngle]) {
        if (angleDeg > .0) {
            if (angleDeg < 15.0)
                [self setFinalPointToDegree:.0];
            else if (angleDeg < 37.5)
                [self setFinalPointToDegree:30.0];
            else if (angleDeg < 52.5)
                [self setFinalPointToDegree:45.0];
            else if (angleDeg < 75.0)
                [self setFinalPointToDegree:60.0];
            else if (angleDeg < 90.0 + 15.0)
                [self setFinalPointToDegree:90.0];
            else if (angleDeg < 90.0 + 37.5)
                [self setFinalPointToDegree:90.0 + 30.0];
            else if (angleDeg < 90.0 + 52.5)
                [self setFinalPointToDegree:90.0 + 45.0];
            else if (angleDeg < 90.0 + 75.0)
                [self setFinalPointToDegree:90.0 + 60.0];
            else
                [self setFinalPointToDegree:180.0];
        }
        else {
            if (angleDeg > -15.0)
                [self setFinalPointToDegree:.0];
            else if (angleDeg > -37.5)
                [self setFinalPointToDegree:-30.0];
            else if (angleDeg > -52.5)
                [self setFinalPointToDegree:-45.0];
            else if (angleDeg > -75.0)
                [self setFinalPointToDegree:-60.0];
            else if (angleDeg > -90.0 - 15.0)
                [self setFinalPointToDegree:-90.0];
            else if (angleDeg > -90.0 - 37.5)
                [self setFinalPointToDegree:-90.0 - 30.0];
            else if (angleDeg > -90.0 - 52.5)
                [self setFinalPointToDegree:-90.0 - 45.0];
            else if (angleDeg > -90.0 - 75.0)
                [self setFinalPointToDegree:-90.0 - 60.0];
            else
                [self setFinalPointToDegree:-180.0];
        }
    }
        
}// snapAngleChangingFinalPoint


// do the segment need to snap?
- (BOOL) isSnapAngle
{
    CGFloat angleDeg = [self angleDeg];

    // Si no esta ajustado responde que no
    CGFloat resultAbs = fabsf(angleDeg);

    if (resultAbs < 10.0)
        return YES;
    
    if (resultAbs > 20.0 && resultAbs < 40.0)    // de 20 a 40 grados
        return YES;
    
    if (resultAbs > 35.0 && resultAbs < 55.0)    // de 35 a 55 grados
        return YES;
    
    if (resultAbs > 50.0 && resultAbs < 70.0)    // de 50 a 70 grados
        return YES;
    
    if (resultAbs > 80.0 && resultAbs < 100.0)    // de 80 a 100 grados
        return YES;
    
    if (resultAbs > 110.0 && resultAbs < 130.0)    // de 110 a 130 grados
        return YES;
    
    if (resultAbs > 125.0 && resultAbs < 145.0)    // de 125 a 145 grados
        return YES;
    
    if (resultAbs > 140.0 && resultAbs < 160.0)    // de 140 a 160 grados
        return YES;
    
    if (resultAbs > 170.0 && resultAbs < 190.0)    // de 170 a 190 grados
        return YES;
    
    return NO;
     
}// isSnapAngle

@end
