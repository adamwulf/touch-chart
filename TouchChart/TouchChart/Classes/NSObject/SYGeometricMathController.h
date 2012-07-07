//
//  SYGeometricMathController.h
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 14/05/12.
//  Copyright (c) 2012 Sylion. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SYGeometry;
@class SYVectorView;

@interface SYGeometricMathController : NSObject {
    
    IBOutlet SYVectorView *vectorView;
    
    @private
    
    // States
    BOOL isDeltaX;
    BOOL isDeltaY;
    NSInteger isDeltaXPos;
    NSInteger isDeltaYPos;
    
    CGFloat previousDeltaX;
    CGFloat previousDeltaY;
    
    // Cartesian values
    NSMutableArray *pointKeyArray;
    
    // Cartesian values
    CGPoint maxX, maxY;
    CGPoint minX, minY;
    
    // Counters
    NSUInteger angleChangeCount;
    NSUInteger directionChangeCount;
    
    // Array Data
    NSMutableArray *listPoints;
    NSMutableArray *listAngles;
    
}

@property (nonatomic, retain) NSMutableArray *pointKeyArray;

// Management Data Operations
- (void) cleanData;
- (void) addFirstPoint:(CGPoint) newPoint;
- (void) addPoint:(CGPoint) pointA andPoint:(CGPoint) pointB;
- (void) addLastPoint:(CGPoint) lastPoint;

// Basic Geometric calculations
- (CGFloat) distanceFrom:(CGPoint) pointTest toLineBuildForPoint:(CGPoint) pointKey andPoint:(CGPoint) pointNextKey;
- (CGFloat) distanceBetweenPoint:(CGPoint) point1 andPoint:(CGPoint) point2;
- (CGFloat) getAngleBetweenVertex:(CGPoint) vertex andPointA:(CGPoint) pointA andPointB:(CGPoint) pointB;
- (BOOL) point:(CGPoint)pointA andPoint:(CGPoint)pointB isAlignedWithPoint:(CGPoint)pointC;
- (BOOL) point:(CGPoint)pointA andPoint:(CGPoint)pointC isAlignedWithPoint:(CGPoint)pointB withDistance:(float) ratio;

// Analyze and Recognizer Geometry Methods
- (void) getFigurePainted;

// Geometric calculations
- (void) createBezierCurveWithPoints:(NSArray *) arrayData;
- (void) createPolygonal;
- (void) createSquare;
- (void) createDiamond;
- (void) createCircle;
- (void) createCircleWithTransform:(CGAffineTransform) transform;
- (void) createArc:(CGPoint) midPoint radius:(NSUInteger) radius startAngle:(CGFloat) startAngle endAngle:(CGFloat) endAngle clockwise:(BOOL) clockwise;

@end
