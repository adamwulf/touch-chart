//
//  SYGeometry.h
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 16/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	SquareType,
	CircleType,
    TriangleType,
    LinesType,
    BezierType,
    ArcType
} GeometryType;

@interface SYGeometry : NSObject {
    
    GeometryType geometryType;
    
    // Geometry parameters
    CGRect rectGeometry;
    NSArray *pointArray;
    
    // Arc parameters
    CGPoint arcMidPoint;
    CGFloat arcRadius;
    CGFloat arcStartAngle;
    CGFloat arcEndAngle;
    BOOL arcClockwise;
    
    // Draw properties
    CGFloat lineWidth;
    UIColor *fillColor;
    UIColor *strokeColor;
    
    // Transforms
    CGAffineTransform transform;
    
}

// get bezier path output
@property (readonly) UIBezierPath* bezierPath;

// helpers for init
@property (nonatomic) GeometryType geometryType;
@property (nonatomic, strong) NSArray *pointArray;

// drawing and colors
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic) CGAffineTransform transform;


// init
- (id) initSquareInRect:(CGRect)rect;
- (id) initCircleInRect:(CGRect)rect;

// Setter
- (void) setArcParametersWithMidPoint:(CGPoint) midPoint
                               radius:(CGFloat) radius
                           startAngle:(CGFloat) startAngle
                             endAngle:(CGFloat) endAngle
                         andClockWise:(BOOL) clockwise;

// Getter
- (CGPoint) midPoint;
- (CGFloat) radius;
- (CGFloat) startAngle;
- (CGFloat) endAngle;
- (BOOL) clockwise;

@end
