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

// Management Data Operations
- (void) cleanData;
- (void) addFirstPoint:(CGPoint) newPoint;
- (void) addPoint:(CGPoint) pointA andPoint:(CGPoint) pointB;

// Basic Geometric calculations
- (CGFloat) distanceBetweenPoint:(CGPoint) point1 andPoint:(CGPoint) point2;
- (CGFloat) getAngleBetweenVertex:(CGPoint) vertex andPointA:(CGPoint) pointA andPointB:(CGPoint) pointB;

// Analyze and Recognizer Geometry Methods
- (void) getFigurePainted;

// Geometric calculations
- (void) createSquare;
- (void) createDiamond;
- (void) createCircle;

@end
