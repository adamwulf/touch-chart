//
//  SYSegment.m
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 01/06/12.
//  Copyright (c) 2012 Sylion. All rights reserved.
//

#import "SYSegment.h"

@interface SYSegment ()

// Private Methods
- (CGFloat) normalizeAngleDeg:(CGFloat) angle;
- (CGFloat) normalizeAngleRad:(CGFloat) angle;

@end


@implementation SYSegment 

#define zero 1e-8
#define inf 1e100
#define equal(a,b)  (fabs((a)-(b))<zero)
#define MODE_SNAP_0_90 1 // Snap just 0 and 90 degrees

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


#pragma mark - Get Special Points Methods

- (CGPoint) startPoint
{
    return [self pointSt];
    
}// startPoint


- (CGPoint) endPoint
{
    return [self pointFn];
    
}// startPoint


- (CGPoint) midPoint
{
    CGFloat midX = (pointSt.x + pointFn.x) * 0.5;
    CGFloat midY = (pointSt.y + pointFn.y) * 0.5;
    
    CGPoint midPoint = CGPointMake(midX, midY);
    
    return midPoint;
    
}// startPoint


#pragma mark - Geometric Methods

- (CGFloat) moduleTwo:(CGPoint)pointA and:(CGPoint)pointB
{
    return (pointB.x-pointA.x)*(pointB.x-pointA.x) + (pointB.y-pointA.y)*(pointB.y-pointA.y);
    
}// moduleTwo:and:


- (CGFloat) distance:(CGPoint)pointA and:(CGPoint)pointB
{
    // Distance between two points (2D)
    return sqrt([self moduleTwo:pointA and:pointB]);

}// distance:and:


- (CGFloat) longitude
{
    // Vector longitude
    return sqrt([self moduleTwo:pointSt and:pointFn]);
    
}// longitude


- (CGFloat) distanceToPoint:(CGPoint) C
{
    // Distance between point C to segment
    
    // Point of the segment used for calculate the distance
    CGPoint P = CGPointZero;
    
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


- (CGPoint) pointIntersectWithSegment:(SYSegment *) anotherSegment
{
    // Intersect point between the current segment and other
    
    // Check if they have equal slope
    float fS1ope1 = (equal(self.pointSt.x, self.pointFn.x)) ? (inf) : ((self.pointFn.y - self.pointSt.y)/(self.pointFn.x - self.pointSt.x));
    float fS1ope2 = (equal(anotherSegment.pointSt.x, anotherSegment.pointFn.x)) ? (inf) : ((anotherSegment.pointFn.y - anotherSegment.pointSt.y)/(anotherSegment.pointFn.x - anotherSegment.pointSt.x));
    
    // If the both slope are equal, never intersect, they're parallels lines
    if (equal(fS1ope1, fS1ope2) || (equal(self.pointSt.x, self.pointFn.x) && equal(anotherSegment.pointSt.x, anotherSegment.pointFn.x))) {
        if (equal(self.pointSt.y - fS1ope1 * self.pointSt.x, anotherSegment.pointSt.y - fS1ope2 * anotherSegment.pointSt.x)) {
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


- (CGFloat) angleRad
{
    // Segment angle radian
    
    CGFloat deltaX = pointFn.x - pointSt.x;
    CGFloat deltaY = pointFn.y - pointSt.y;
    
    if (deltaX == .0) {
        if (deltaY > .0)
            return 3 * M_PI_2;
        else if (deltaY < .0)
            return M_PI_2;
    }
    
    if (deltaY == .0) {
        if (deltaX > .0)
            return .0;
        else if (deltaX < .0)
            return M_PI;
    }
    
    // -/+ (from 0º to 90º)
    if (deltaY < .0 && deltaX > .0)
        return /*(2*M_PI)*/- atanf(deltaY/deltaX);
    
    // -/- (from 90º to 180º)
    if (deltaY < .0 && deltaX < .0)
        return M_PI - atanf(deltaY/deltaX);
    
    // +/- (from 180º to 270º)
    if (deltaY > .0 && deltaX < .0)
        return M_PI - atanf(deltaY/deltaX);
    
    // +/+ (from 180º to 270º)
    if (deltaY > .0 && deltaX > .0)
        return (2*M_PI) - atanf(deltaY/deltaX);

    return atanf(deltaY/deltaX);
    
}// angleRad


- (CGFloat) angleDeg
{
    // Segment angle degrees
    CGFloat angle = [self angleRad];
    return (angle/M_PI) * 180.0;
    
}// angleDeg


- (void) setStartPointToDegree:(CGFloat) angle
{
    // Snap pivotal around the start point
    CGFloat longitude = [self longitude];
    CGFloat angleNormalize = [self normalizeAngleDeg:angle];
    CGFloat angleRad = (angleNormalize/90.0) * M_PI_2;
    
    // sen/cos = tan ----> sen = tan * cos
    if (angleNormalize == .0 || angleNormalize == 360.0) {
        pointSt.y = pointFn.y;
        pointSt.x = pointFn.x - longitude;
    }
    else if (angleNormalize == 180.0) {
        pointSt.y = pointFn.y;
        pointSt.x = pointFn.x + longitude;
    }
    else if (angleNormalize == 90.0) {
        pointSt.x = pointFn.x;
        pointSt.y = pointFn.y - longitude;
    }
    else if (angleNormalize == 270.0) {
        pointSt.x = pointFn.x;
        pointSt.y = pointFn.y + longitude;
    }
    else {
        float tang = tan(angleRad);
        float numX = .0;
        float onePlusTang = 1 + powf(tang,2);
        if (angle > .0 && angle < 90.0) {
            numX = pointFn.x + (pointFn.x * powf(tang, 2))/**/+ sqrtf(powf(longitude, 2)+powf(longitude * tang, 2));
            pointSt.x = numX/onePlusTang;
            pointSt.y = pointFn.y - (pointFn.x * tang) + ((pointFn.x*tang)/onePlusTang) + ((pointFn.x*powf(tang,3))/onePlusTang) /**/+ ((tang * sqrtf(powf(longitude, 2) * onePlusTang))/onePlusTang);
        }
        else if (angle > 90.0 && angle < 180.0) {
            numX = pointFn.x + (pointFn.x * powf(tang, 2)) - sqrtf(powf(longitude, 2)+powf(longitude * tang, 2));
            pointSt.x = numX/onePlusTang;
            pointSt.y = pointFn.y - (pointFn.x * tang) + ((pointFn.x*tang)/onePlusTang) + ((pointFn.x*powf(tang,3))/onePlusTang) - ((tang * sqrtf(powf(longitude, 2) * onePlusTang))/onePlusTang);
        }
        else if (angle > 180.0 && angle < 270.0) {
            numX = pointFn.x + (pointFn.x * powf(tang, 2)) - sqrtf(powf(longitude, 2)+powf(longitude * tang, 2));
            pointSt.x = numX/onePlusTang;
            pointSt.y = pointFn.y - (pointFn.x * tang) + ((pointFn.x*tang)/onePlusTang) + ((pointFn.x*powf(tang,3))/onePlusTang) - ((tang * sqrtf(powf(longitude, 2) * onePlusTang))/onePlusTang);
        }
        else {
            numX = pointFn.x + (pointFn.x * powf(tang, 2)) + sqrtf(powf(longitude, 2)+powf(longitude * tang, 2));
            pointSt.x = numX/onePlusTang;
            pointSt.y = pointFn.y - (pointFn.x * tang) + ((pointFn.x*tang)/onePlusTang) + ((pointFn.x*powf(tang,3))/onePlusTang) + ((tang * sqrtf(powf(longitude, 2) * onePlusTang))/onePlusTang);
        }
    }
    
}// setStartPointToDegree:


- (void) setMiddlePointToDegree:(CGFloat) angle
{
    // Snap pivotal around the middle point
    
    CGFloat angleNormalize = [self normalizeAngleDeg:angle];
    CGFloat angleRad = (angleNormalize/90.0) * M_PI_2;

    CGFloat midLongitude = [self longitude] * 0.5;
    
    // sen/cos = tan ----> sen = tan * cos
    if (angleNormalize == .0 || angleNormalize == 360.0) {
        CGFloat midY = (pointFn.y + pointSt.y) * 0.5;
        CGPoint midPoint = [self midPoint];
        
        if(pointSt.x > pointFn.x) {
            pointSt = CGPointMake(midPoint.x + midLongitude, midY);
            pointFn = CGPointMake(midPoint.x - midLongitude, midY);
        }
        else {
            pointSt = CGPointMake(midPoint.x - midLongitude, midY);
            pointFn = CGPointMake(midPoint.x + midLongitude, midY);
        }
    }
    else if (angleNormalize == 90.0 || angleNormalize == 270.0) {
        CGFloat midX = (pointFn.x + pointSt.x) * 0.5;
        CGPoint midPoint = [self midPoint];
        
        if(pointSt.y > pointFn.y) {
            pointSt = CGPointMake(midX, midPoint.y - midLongitude);
            pointFn = CGPointMake(midX, midPoint.y + midLongitude);
        }
        else {
            pointSt = CGPointMake(midX, midPoint.y - midLongitude);
            pointFn = CGPointMake(midX, midPoint.y + midLongitude);
        }
    }
    else {
        CGFloat deltaY = (pointFn.x - pointSt.x) * tanf(-angleRad);
        pointSt.y = pointSt.y + (deltaY * 0.5);
        pointFn.y = pointFn.y - (deltaY * 0.5);
    }
    
}// setMiddlePointToDegree


- (void) setFinalPointToDegree:(CGFloat) angle
{
    // Snap pivotal around the final point
    CGFloat longitude = [self longitude];
    CGFloat angleNormalize = [self normalizeAngleDeg:angle];
    CGFloat angleRad = (angleNormalize/90.0) * M_PI_2;
    
    // sin/cos = tan ----> sin = tan * cos
    if (angleNormalize == .0 || angleNormalize == 360.0) {
        pointFn.y = pointSt.y;
        pointFn.x = pointSt.x + longitude;
    }
    else if (angleNormalize == 90.0) {
        pointFn.x = pointSt.x;
        pointFn.y = pointSt.y + longitude;
    }
    else if (angleNormalize == 270.0) {
        pointFn.x = pointSt.x;
        pointFn.y = pointSt.y - longitude;
    }
    else {
        float tang = tan(angleRad);
        float numX = .0;
        float onePlusTang = 1 + powf(tang,2);
        if (angle > .0 && angle < 90.0) {
            numX = pointSt.x + (pointSt.x * powf(tang, 2))/**/+ sqrtf(powf(longitude, 2)+powf(longitude * tang, 2));
            pointFn.x = numX/onePlusTang;
            pointFn.y = pointSt.y - (pointSt.x * tang) + ((pointSt.x*tang)/onePlusTang) + ((pointSt.x*powf(tang,3))/onePlusTang) /**/- ((tang * sqrtf(powf(longitude, 2) * onePlusTang))/onePlusTang);
        }
        else if (angle > 90.0 && angle < 180.0) {
            numX = pointSt.x + (pointSt.x * powf(tang, 2)) - sqrtf(powf(longitude, 2)+powf(longitude * tang, 2));
            pointFn.x = numX/onePlusTang;
            pointFn.y = pointSt.y - (pointSt.x * tang) + ((pointSt.x*tang)/onePlusTang) + ((pointSt.x*powf(tang,3))/onePlusTang) + ((tang * sqrtf(powf(longitude, 2) * onePlusTang))/onePlusTang);
        }
        else if (angle > 180.0 && angle < 270.0) {
            numX = pointSt.x + (pointSt.x * powf(tang, 2)) - sqrtf(powf(longitude, 2)+powf(longitude * tang, 2));
            pointFn.x = numX/onePlusTang;
            pointFn.y = pointSt.y - (pointSt.x * tang) + ((pointSt.x*tang)/onePlusTang) + ((pointSt.x*powf(tang,3))/onePlusTang) + ((tang * sqrtf(powf(longitude, 2) * onePlusTang))/onePlusTang);
        }
        else { // CREO QUE BIEN
            numX = pointSt.x + (pointSt.x * powf(tang, 2)) + sqrtf(powf(longitude, 2)+powf(longitude * tang, 2));
            pointFn.x = numX/onePlusTang;
            pointFn.y = pointSt.y - (pointSt.x * tang) + ((pointSt.x*tang)/onePlusTang) + ((pointSt.x*powf(tang,3))/onePlusTang) - ((tang * sqrtf(powf(longitude, 2) * onePlusTang))/onePlusTang);
        }
    }
    
}// setFinalPointToDegree:


- (void) snapAngleChangingStartPoint
{
    // Check angle to snap
    CGFloat angleDeg = [self angleDeg];
    
#if MODE_SNAP_0_90
    if ([self isSnapAngle]) {
        if (angleDeg > .0) {
            if (angleDeg < 15.0)
                [self setStartPointToDegree:.0];
            else if (angleDeg > 75.0 && angleDeg < 90.0 + 15.0)
                [self setStartPointToDegree:90.0];
            else if (angleDeg > 90.0 + 75.0 && angleDeg < 180.0 + 15.0)
                [self setStartPointToDegree:180.0];
            else if (angleDeg > 180.0 + 75.0 && angleDeg < 270.0 + 15.0)
                [self setStartPointToDegree:270.0];
            else if (angleDeg > 270.0 + 75.0)
                [self setStartPointToDegree:360.0];
        }
        else {
            if (angleDeg > -15.0)
                [self setStartPointToDegree:.0];
            else if (angleDeg < -75.0 && angleDeg > -90.0 - 15.0)
                [self setStartPointToDegree:-90.0];
            else if (angleDeg < -90.0 - 75.0 && angleDeg > -180.0 - 15.0)
                [self setStartPointToDegree:-180.0];
            else if (angleDeg < -180.0 - 75.0 && angleDeg > -270.0 - 15.0)
                [self setStartPointToDegree:-270.0];
            else if (angleDeg < -270.0 - 75.0)
                [self setStartPointToDegree:-360.0];
        }
    }
    
#else
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
            else if (angleDeg < 105.0)
                [self setStartPointToDegree:90.0];
            else if (angleDeg < 127.5)
                [self setStartPointToDegree:120.0];
            else if (angleDeg < 142.5)
                [self setStartPointToDegree:135.0];
            else if (angleDeg < 165.0)
                [self setStartPointToDegree:150.0];
            else if (angleDeg < 195.0)
                [self setStartPointToDegree:180.0];
            else if (angleDeg < 217.5)
                [self setStartPointToDegree:210.0];
            else if (angleDeg < 232.5)
                [self setStartPointToDegree:225.0];
            else if (angleDeg < 255.0)
                [self setStartPointToDegree:240.0];
            else if (angleDeg < 285.0)
                [self setStartPointToDegree:270.0];
            else if (angleDeg < 307.5)
                [self setStartPointToDegree:300.0];
            else if (angleDeg < 322.5)
                [self setStartPointToDegree:315.0];
            else if (angleDeg < 345.0)
                [self setStartPointToDegree:330.0];
            else
                [self setStartPointToDegree:360.0];
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
            else if (angleDeg > -105.0)
                [self setStartPointToDegree:-90.0];
            else if (angleDeg > -127.5)
                [self setStartPointToDegree:-120.0];
            else if (angleDeg > -142.5)
                [self setStartPointToDegree:-135.0];
            else if (angleDeg > -165.0)
                [self setStartPointToDegree:-150.0];
            else if (angleDeg > -195.0)
                [self setStartPointToDegree:-180.0];
            else if (angleDeg > -217.5)
                [self setStartPointToDegree:-210.0];
            else if (angleDeg > -232.5)
                [self setStartPointToDegree:-225.0];
            else if (angleDeg > -255.0)
                [self setStartPointToDegree:-240.0];
            else if (angleDeg > -285.0)
                [self setStartPointToDegree:-270.0];
            else if (angleDeg > -307.5)
                [self setStartPointToDegree:-300.0];
            else if (angleDeg > -322.5)
                [self setStartPointToDegree:-315.0];
            else if (angleDeg > -345.0)
                [self setStartPointToDegree:-330.0];
            else
                [self setStartPointToDegree:-360.0];
        }
    }
#endif

}// snapAngleChangingStartPoint


- (void) snapAngleChangingFromMiddlePoint
{
    // Check angle to snap
    CGFloat angleDeg = [self angleDeg];
    
#if MODE_SNAP_0_90
    if ([self isSnapAngle]) {
        if (angleDeg > .0) {
            if (angleDeg < 15.0)
                [self setMiddlePointToDegree:.0];
            else if (angleDeg > 75.0 && angleDeg < 90.0 + 15.0)
                [self setMiddlePointToDegree:90.0];
            else if (angleDeg > 90.0 + 75.0 && angleDeg < 180.0 + 15.0)
                [self setMiddlePointToDegree:180.0];
            else if (angleDeg > 180.0 + 75.0 && angleDeg < 270.0 + 15.0)
                [self setMiddlePointToDegree:270.0];
            else if (angleDeg > 270.0 + 75.0)
                [self setMiddlePointToDegree:360.0];
        }
        else {
            if (angleDeg > -15.0)
                [self setMiddlePointToDegree:.0];
            else if (angleDeg < -75.0 && angleDeg > -90.0 - 15.0)
                [self setMiddlePointToDegree:-90.0];
            else if (angleDeg < -90.0 - 75.0 && angleDeg > -180.0 - 15.0)
                [self setMiddlePointToDegree:-180.0];
            else if (angleDeg < -180.0 - 75.0 && angleDeg > -270.0 - 15.0)
                [self setMiddlePointToDegree:-270.0];
            else if (angleDeg < -270.0 - 75.0)
                [self setMiddlePointToDegree:-360.0];
        }
    }
    
#else
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
            else if (angleDeg < 105.0)
                [self setMiddlePointToDegree:90.0];
            else if (angleDeg < 127.5)
                [self setMiddlePointToDegree:120.0];
            else if (angleDeg < 142.5)
                [self setMiddlePointToDegree:135.0];
            else if (angleDeg < 165.0)
                [self setMiddlePointToDegree:150.0];
            else if (angleDeg < 195.0)
                [self setMiddlePointToDegree:180.0];
            else if (angleDeg < 217.5)
                [self setMiddlePointToDegree:210.0];
            else if (angleDeg < 232.5)
                [self setMiddlePointToDegree:225.0];
            else if (angleDeg < 255.0)
                [self setMiddlePointToDegree:240.0];
            else if (angleDeg < 285.0)
                [self setMiddlePointToDegree:270.0];
            else if (angleDeg < 307.5)
                [self setMiddlePointToDegree:300.0];
            else if (angleDeg < 322.5)
                [self setMiddlePointToDegree:315.0];
            else if (angleDeg < 345.0)
                [self setMiddlePointToDegree:330.0];
            else
                [self setMiddlePointToDegree:360.0];
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
            else if (angleDeg > -105.0)
                [self setMiddlePointToDegree:-90.0];
            else if (angleDeg > -127.5)
                [self setMiddlePointToDegree:-120.0];
            else if (angleDeg > -142.5)
                [self setMiddlePointToDegree:-135.0];
            else if (angleDeg > -165.0)
                [self setMiddlePointToDegree:-150.0];
            else if (angleDeg > -195.0)
                [self setMiddlePointToDegree:-180.0];
            else if (angleDeg > -217.5)
                [self setMiddlePointToDegree:-210.0];
            else if (angleDeg > -232.5)
                [self setMiddlePointToDegree:-225.0];
            else if (angleDeg > -255.0)
                [self setMiddlePointToDegree:-240.0];
            else if (angleDeg > -285.0)
                [self setMiddlePointToDegree:-270.0];
            else if (angleDeg > -307.5)
                [self setMiddlePointToDegree:-300.0];
            else if (angleDeg > -322.5)
                [self setMiddlePointToDegree:-315.0];
            else if (angleDeg > -345.0)
                [self setMiddlePointToDegree:-330.0];
            else
                [self setMiddlePointToDegree:-360.0];
        }
    }
#endif
        
}// snapAngleChangingFromMiddlePoint


- (void) snapAngleChangingFinalPoint
{
    // Check angle to snap
    CGFloat angleDeg = [self angleDeg];
    
#if MODE_SNAP_0_90
    if ([self isSnapAngle]) {
        if (angleDeg > .0) {
            if (angleDeg < 15.0)
                [self setFinalPointToDegree:.0];
            else if (angleDeg > 75.0 && angleDeg < 90.0 + 15.0)
                [self setFinalPointToDegree:90.0];
            else if (angleDeg > 90.0 + 75.0 && angleDeg < 180.0 + 15.0)
                [self setFinalPointToDegree:180.0];
            else if (angleDeg > 180.0 + 75.0 && angleDeg < 270.0 + 15.0)
                [self setFinalPointToDegree:270.0];
            else if (angleDeg > 270.0 + 75.0)
                [self setFinalPointToDegree:360.0];
        }
        else {
            if (angleDeg > -15.0)
                [self setFinalPointToDegree:.0];
            else if (angleDeg < -75.0 && angleDeg > -90.0 - 15.0)
                [self setFinalPointToDegree:-90.0];
            else if (angleDeg < -90.0 - 75.0 && angleDeg > -180.0 - 15.0)
                [self setFinalPointToDegree:-180.0];
            else if (angleDeg < -180.0 - 75.0 && angleDeg > -270.0 - 15.0)
                [self setFinalPointToDegree:-270.0];
            else if (angleDeg < -270.0 - 75.0)
                [self setFinalPointToDegree:-360.0];
        }
    }
    
#else
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
            else if (angleDeg < 105.0)
                [self setFinalPointToDegree:90.0];
            else if (angleDeg < 127.5)
                [self setFinalPointToDegree:120.0];
            else if (angleDeg < 142.5)
                [self setFinalPointToDegree:135.0];
            else if (angleDeg < 165.0)
                [self setFinalPointToDegree:150.0];
            else if (angleDeg < 195.0)
                [self setFinalPointToDegree:180.0];
            else if (angleDeg < 217.5)
                [self setFinalPointToDegree:210.0];
            else if (angleDeg < 232.5)
                [self setFinalPointToDegree:225.0];
            else if (angleDeg < 255.0)
                [self setFinalPointToDegree:240.0];
            else if (angleDeg < 285.0)
                [self setFinalPointToDegree:270.0];
            else if (angleDeg < 307.5)
                [self setFinalPointToDegree:300.0];
            else if (angleDeg < 322.5)
                [self setFinalPointToDegree:315.0];
            else if (angleDeg < 345.0)
                [self setFinalPointToDegree:330.0];
            else
                [self setFinalPointToDegree:360.0];
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
            else if (angleDeg > -105.0)
                [self setFinalPointToDegree:-90.0];
            else if (angleDeg > -127.5)
                [self setFinalPointToDegree:-120.0];
            else if (angleDeg > -142.5)
                [self setFinalPointToDegree:-135.0];
            else if (angleDeg > -165.0)
                [self setFinalPointToDegree:-150.0];
            else if (angleDeg > -195.0)
                [self setFinalPointToDegree:-180.0];
            else if (angleDeg > -217.5)
                [self setFinalPointToDegree:-210.0];
            else if (angleDeg > -232.5)
                [self setFinalPointToDegree:-225.0];
            else if (angleDeg > -255.0)
                [self setFinalPointToDegree:-240.0];
            else if (angleDeg > -285.0)
                [self setFinalPointToDegree:-270.0];
            else if (angleDeg > -307.5)
                [self setFinalPointToDegree:-300.0];
            else if (angleDeg > -322.5)
                [self setFinalPointToDegree:-315.0];
            else if (angleDeg > -345.0)
                [self setFinalPointToDegree:-330.0];
            else
                [self setFinalPointToDegree:-360.0];
        }
    }
#endif
    
}// snapAngleChangingFinalPoint


- (BOOL) isSnapAngle
{
    // do the segment need to snap?
    CGFloat angleDeg = [self angleDeg];

    // Si no esta ajustado responde que no
    CGFloat resultAbs = fabsf(angleDeg);
    if (resultAbs > 180.0)
        resultAbs = resultAbs * 0.5;
    
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


#pragma mark - Private Methods

- (CGFloat) normalizeAngleDeg:(CGFloat) angle
{    
    if (angle > 360.0) {
        NSInteger count = (NSInteger) (angle/360.0);
        return angle - (count * 360.0);
    }
    else if (angle < -360.0) {
        NSInteger count = (NSInteger) (angle/360.0);
        return angle - (count * 360.0);
    }
    
    if (angle < .0)
        return 360.0 + angle;
    
    return angle;
    
}// normalizeAngleDeg


- (CGFloat) normalizeAngleRad:(CGFloat) angle
{
    if (angle > 2 * M_PI) {
        NSInteger count = (NSInteger) (angle/(2 * M_PI));
        return angle - (count * (2 * M_PI));
    }
    else if (angle < -(2 * M_PI)) {
        NSInteger count = (NSInteger) (angle/(2 * M_PI));
        return angle - (count * (2 * M_PI));
    }
    
    if (angle < .0)
        return (2 * M_PI) + angle;
    
    return angle;
    
}// normalizeAngleRad

@end
