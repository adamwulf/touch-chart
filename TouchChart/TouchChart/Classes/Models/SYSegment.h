//
//  SYSegment.h
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 01/06/12.
//  Copyright (c) 2012 Sylion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYSegment : NSObject {
    // Puntos que definen el segmento
    CGPoint pointSt;
    CGPoint pointFn;
}

@property (nonatomic) CGPoint pointSt;
@property (nonatomic) CGPoint pointFn;

- (id) initWithPoint:(CGPoint) pointA andPoint:(CGPoint) pointB;
- (CGFloat) moduleTwo:(CGPoint)puntoA and:(CGPoint)puntoB;
- (CGFloat) distance:(CGPoint)puntoA and:(CGPoint)puntoB;
- (CGFloat) longitude;
- (CGFloat) distanceToPoint:(CGPoint) C;
- (CGPoint) pointIntersectWithSegment:(SYSegment *) anotherSegment;

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
