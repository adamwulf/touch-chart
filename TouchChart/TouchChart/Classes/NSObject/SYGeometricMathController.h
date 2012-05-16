//
//  SYGeometricMathController.h
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 14/05/12.
//  Copyright (c) 2012 Sylion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYGeometricMathController : NSObject

// States
@property (nonatomic, readwrite) BOOL isDeltaX;
@property (nonatomic, readwrite) BOOL isDeltaY;

// Cartesian values
@property (nonatomic, readwrite) CGPoint maxX, maxY;
@property (nonatomic, readwrite) CGPoint minX, minY;

// Counters
@property (nonatomic, readwrite) NSUInteger angleChangeCount;
@property (nonatomic, readwrite) NSUInteger directionChangeCount;

// Array Data
@property(nonatomic, retain)    NSMutableArray *listPoints;
@property(nonatomic, retain)    NSMutableArray *listAngles;
@property(nonatomic, retain)    NSMutableArray *listVertex;


// Management Data Operations
- (void) cleanData;
- (void) addFirstPoint:(CGPoint) newPoint;
- (void) addPoint:(CGPoint) pointA andPoint:(CGPoint) pointB;

// Basic Geometric calculations
- (CGFloat) distanceBetweenPoint:(CGPoint) point1 andPoint:(CGPoint) point2;
- (CGFloat) getAngleBetweenVertex:(CGPoint) vertex andPointA:(CGPoint) pointA andPointB:(CGPoint) pointB;

// Analyze and Recognizer Geometry Methods
- (NSString *) getFigurePainted;

@end
