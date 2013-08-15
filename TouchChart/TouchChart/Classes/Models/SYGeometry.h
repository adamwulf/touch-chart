//
//  SYGeometry.h
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 16/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SYSegment.h"

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
    NSArray *pointArray;
    
    // Draw properties
    CGFloat lineWidth;
    UIColor *fillColor;
    UIColor *strokeColor;
}

// properties of this geometry
@property (readonly) UIBezierPath* bezierPath;
@property (readonly) GeometryType geometryType;
@property (readonly) NSArray *pointArray;

// drawing and colors
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *strokeColor;


// init
- (id) initWithBezierCurves:(NSArray*)curves;
- (id) initSquareInRect:(CGRect)rect;
- (id) initCircleInRect:(CGRect)rect;
- (id) initCircleInRect:(CGRect)rect andTransform:(CGAffineTransform)transform;
- (id) initWithSegmentFrom:(CGPoint)point1 to:(CGPoint)point2;
- (id) initWithRotatedRectangleFrom:(CGPoint)point1 to:(CGPoint)point2 to:(CGPoint)point3 to:(CGPoint)point4;
- (id) initWithSegment:(SYSegment*) segment;
- (id) initArcWithMidPoint:(CGPoint) midPoint radius:(CGFloat) radius startAngle:(CGFloat) startAngle endAngle:(CGFloat) endAngle andClockWise:(BOOL) clockwise;


-(void) matchDrawingPropertiesOf:(SYGeometry*)geometry;

@end
