//
//  SYGeometry.m
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 16/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SYGeometry.h"
#import "SYBezier.h"

@implementation SYGeometry

@synthesize geometryType;
@synthesize rectGeometry;
@synthesize pointArray;

@synthesize lineWidth;
@synthesize fillColor;
@synthesize strokeColor;

@synthesize transform;

// dealloc


- (NSString *) description
{
    NSMutableString *desc = [NSMutableString string];
    if (self.geometryType == SquareType)
         [desc appendString:@"\nGeometryType: Square"];
    if (self.geometryType == CircleType)
        [desc appendString:@"\nGeometryType: Circle"];
    if (self.geometryType == LinesType)
        [desc appendString:@"\nGeometryType: LinesType"];
    if (self.geometryType == BezierType)
        [desc appendString:@"\nGeometryType: BezierType"];
    if (self.geometryType == ArcType)
        [desc appendString:@"\nGeometryType: ArcType"];
    
    [desc appendFormat:@"\nPoint Array: %@", pointArray];
    [desc appendFormat:@"\nLine Width: %f", lineWidth];
    [desc appendFormat:@"\nColor fill: %@", fillColor];
    [desc appendFormat:@"\nColor Stroke: %@", strokeColor];
    
    return desc;
    
}// description


- (id) init
{
    self = [super init];
    
    if (self) {
        // Draw properties
        lineWidth = 4.0;
        self.fillColor = [UIColor clearColor];
        self.strokeColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
                
        // Transforms
        transform = CGAffineTransformIdentity; 
    }
    
    return self;
    
}// init

#pragma mark - Setter

- (void) setArcParametersWithMidPoint:(CGPoint) midPoint radius:(CGFloat) radius startAngle:(CGFloat) startAngle endAngle:(CGFloat) endAngle andClockWise:(BOOL) clockwise
{
    arcMidPoint = midPoint;
    arcRadius = radius;
    arcStartAngle = startAngle;
    arcEndAngle = endAngle;
    arcClockwise = clockwise;
    
}// setArcParametersWithRadius:startAngle:endAngle:andClockWise:


#pragma mark - Getter

- (CGPoint) midPoint
{
    return arcMidPoint;
    
}// radius


- (CGFloat) radius
{
    return arcRadius;
    
}// radius


- (CGFloat) startAngle
{
    return arcStartAngle;
    
}// radius


- (CGFloat) endAngle
{
    return arcEndAngle;
    
}// radius


- (BOOL) clockwise
{
    return arcClockwise;
    
}// radius

#pragma mark - Bezier Path

-(UIBezierPath*) bezierPath{
    if ([self geometryType] == LinesType) {
        CGPoint pointA = [[[self pointArray]objectAtIndex:0]CGPointValue];
        
        // Drawing code
        UIBezierPath * path = [UIBezierPath bezierPath];
        [path moveToPoint:pointA];
        
        for (int i = 0; i < [[self pointArray]count] ; i++) {
            CGPoint pointB = [[[self pointArray]objectAtIndex:i]CGPointValue];
            [path addLineToPoint:pointB];
        }
        
        [path setLineWidth:[self lineWidth]];
        return path;
    }else if ([self geometryType] == BezierType) {
        
        SYBezier *bezier = [self.pointArray objectAtIndex:0];
        // Bezier lines
        UIBezierPath * path = [UIBezierPath bezierPath];
        [path moveToPoint: bezier.t0Point];
        
        [path addCurveToPoint: bezier.t3Point
                controlPoint1: bezier.cPointA
                controlPoint2: bezier.cPointB];
        
        [path setLineWidth:[self lineWidth]];
        
        
        for (int i = 1 ; i < [self.pointArray count] ; i++) {
            
            SYBezier *bezier = [self.pointArray objectAtIndex:i];
            
            // Bezier lines
            [path moveToPoint: bezier.t0Point];
            [path addCurveToPoint: bezier.t3Point
                    controlPoint1: bezier.cPointA
                    controlPoint2: bezier.cPointB];
        }
        return path;
    }
    else if ([self geometryType] == CircleType) {
        // create a oval bezier path using the rect
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:[self rectGeometry]];
        [path setLineWidth:[self lineWidth]];
        [path applyTransform:[self transform]];
        
        return path;
    }
    else if ([self geometryType] == ArcType) {
        
        // Drawing code
        UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:[self midPoint]
                                                             radius:[self radius]
                                                         startAngle:[self startAngle]
                                                           endAngle:[self endAngle]
                                                          clockwise:[self clockwise]];
        
        [path setLineWidth:[self lineWidth]];
        
//        [path applyTransform:[self transform]];
        
        return path;
    }
    else if ([self geometryType] == SquareType) {
        
        // Drawing code
        UIBezierPath * path = [UIBezierPath bezierPathWithRect:[self rectGeometry]];
        [path setLineWidth:[self lineWidth]];
        
        return path;
    }
    return nil;
}

@end
