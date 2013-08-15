//
//  SYSegment.h
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 01/06/12.
//  Copyright (c) 2012 Sylion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface SYSegment : NSObject {
    // These points define the segment
    CGPoint pointSt;
    CGPoint pointFn;
}

@property (nonatomic) CGPoint pointSt;
@property (nonatomic) CGPoint pointFn;

// Init
- (id) initWithPoint:(CGPoint) pointA andPoint:(CGPoint) pointB;

// Get Special Points Methods
- (CGPoint) startPoint;
- (CGPoint) endPoint;
- (CGPoint) midPoint;
- (CGPoint) pointIntersectWithSegment:(SYSegment *) anotherSegment;

// Distances
- (CGFloat) moduleTwo:(CGPoint)pointA and:(CGPoint)pointB;
- (CGFloat) distance:(CGPoint)pointA and:(CGPoint)pointB;
- (CGFloat) longitude;
- (CGFloat) distanceToPoint:(CGPoint) C;

// Angles Methods
- (CGFloat) angleRad;
- (CGFloat) angleDeg;
- (void) setStartPointToDegree:(CGFloat) angle;
- (void) setMiddlePointToDegree:(CGFloat) angle;
- (void) setFinalPointToDegree:(CGFloat) angle;
- (void) snapAngleChangingFinalPoint;
- (void) snapAngleChangingFromMiddlePoint;
- (void) snapAngleChangingStartPoint;
- (BOOL) isSnapAngle;

@end
