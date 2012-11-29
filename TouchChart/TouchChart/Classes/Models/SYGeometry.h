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

@property (nonatomic) GeometryType geometryType;
@property (nonatomic) CGRect rectGeometry;
@property (nonatomic, retain) NSArray *pointArray;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic, retain) UIColor *fillColor;
@property (nonatomic, retain) UIColor *strokeColor;
@property (nonatomic) CGAffineTransform transform;

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
